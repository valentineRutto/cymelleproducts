import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {

          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      CartItemTile(item: cart.items[i]),
                ),
              ),

              _OrderSummary(cart: cart),
            ],
          );
        },
      ),
    );
  }
}


class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.product.image,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              placeholder: (_, __) => Container(
                width: 64,
                height: 64,
                color: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Row(
            children: [
              _CircleButton(
                icon: item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
                onTap: () => cart.decrement(item.product.id),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _CircleButton(
                icon: Icons.add,
                onTap: () => cart.increment(item.product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cart.itemCount} items'),
              Text(
                '\$${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order placed! Total: \$${cart.total.toStringAsFixed(2)}',
                    ),
                  ),
                );
                cart.clearCart();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Checkout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}