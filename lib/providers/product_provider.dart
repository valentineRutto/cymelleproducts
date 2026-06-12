
import 'package:flutter/foundation.dart';
import 'package:cymelleproducts/repositories/product_repository.dart';
import 'package:cymelleproducts/models/product.dart';

enum LoadingState{
  loading,
  success,
  error,
  idle
}

class ProductProvider extends ChangeNotifier {

  final ProductRepository _repository;

 ProductProvider({ProductRepository? repo})
   : _repository = repo??ProductRepository();

  List<Product> _products = [];
  List<Product> get products => _products;

  LoadingState _state = LoadingState.idle;
  LoadingState get state => _state;

  String _errorMessage = '';

  String get errorMessage => _errorMessage;

  bool get IsLoading => _state == LoadingState.loading;
  bool get HasError => _state == LoadingState.error;
  bool get isEmpty => _state == LoadingState.success && _products.isEmpty;

  Future<void> loadProducts() async {

_state = LoadingState.loading;
_errorMessage = '';
notifyListeners();

try {
      _products = await _repository.fetchProducts();
      _state = LoadingState.success;
    } catch (e) {
      _errorMessage = '$e';
      _state = LoadingState.error;
    }
notifyListeners();
  }
  


}