 
 
 
  import 'dart:convert';
 import 'package:http/http.dart' as http;
 import 'package:cymelleproducts/models/product.dart';
 
 class ProductRepository {

   static const _url = 'https://fakestoreapi.com/products';

Future<List<Product>> fetchProducts() async {
    try {

      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {

        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
        
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return _mockProducts; 
    }
  }


   

 static final List<Product> _mockProducts = [
    const Product(
      id: 1,
      title: 'Wireless Noise-Cancelling Headphones',
      price: 79.99,
      image: 'https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_.jpg',
      category: 'electronics',
    ),
    const Product(
      id: 2,
      title: 'Slim Fit Cotton T-Shirt',
      price: 22.50,
      image: 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
      category: "men's clothing",
    ),
    const Product(
      id: 3,
      title: 'Leather Tote Bag',
      price: 55.00,
      image: 'https://fakestoreapi.com/img/81fAZal24fL._AC_UY879_.jpg',
      category: "women's clothing",
    ),
    const Product(
      id: 4,
      title: 'Gold Stud Earrings',
      price: 9.99,
      image: 'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_FMwebp_QL65_.jpg',
      category: 'jewelery',
    ),
    const Product(
      id: 5,
      title: 'Mechanical Gaming Keyboard',
      price: 110.00,
      image: 'https://fakestoreapi.com/img/61mtL65D4cL._AC_SX679_.jpg',
      category: 'electronics',
    ),
    const Product(
      id: 6,
      title: 'Running Sneakers',
      price: 64.99,
      image: 'https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_FMwebp_QL65_.jpg',
      category: "men's clothing",
    ),
  ];
  }