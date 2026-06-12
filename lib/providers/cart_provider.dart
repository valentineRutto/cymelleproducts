import 'package:flutter/foundation.dart';
import 'package:cymelleproducts/models/cart_item.dart';
import 'package:cymelleproducts/models/product.dart';

class CartProvider extends ChangeNotifier {
  
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  double get total => _items.values.fold(0.0, (sum, i) => sum + i.totalPrice);

    bool isInCart(int productId) => _items.containsKey(productId);

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  void addToCart(Product product) {

    if(_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.remove(product.id);
      notifyListeners();
    }
  
  void increment(int product ){
    if(_items.containsKey(product)){
      _items[product]!.quantity++;
      notifyListeners();
    }
  }

  void decrement(int productId){
        final item = _items[productId];
    if (item == null) return;

    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      item.quantity--;
    }
      notifyListeners();
    }

    void clearCart() {
      _items.clear();
      notifyListeners();
  }
}