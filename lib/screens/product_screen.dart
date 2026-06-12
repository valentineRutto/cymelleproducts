import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load products',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: provider.loadProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No products available'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.products.length,
            itemBuilder: (_, i) =>
                ProductCard(product: provider.products[i]),
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: product.image,
              fit: BoxFit.contain,
              width: double.infinity,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                final inCart = cart.isInCart(product.id);
                final qty = cart.quantityOf(product.id);

                return inCart
                    ? _QuantityControl(productId: product.id, quantity: qty)
                    : SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () => cart.addToCart(product),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Add to cart'),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int productId;
  final int quantity;

  const _QuantityControl({
    required this.productId,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              quantity <= 1 ? Icons.delete_outline : Icons.remove,
              size: 18,
              color: colors.primary,
            ),
            onPressed: () => cart.decrement(productId),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 18, color: colors.primary),
            onPressed: () => cart.increment(productId),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}