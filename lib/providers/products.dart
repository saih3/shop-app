import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<Product> _items = [];
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // NOTICE the difference
    // final url = Uri.https('shop-app-course-186c5-default-rtdb.firebaseio.com',
    //     '/products.json', {'auth': '$authToken'});
    final String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-course-186c5-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      if (json.decode(response.body) == null) return;
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      url = Uri.parse(
          'https://shop-app-course-186c5-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-course-186c5-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'creatorId': userId,
            },
          ));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-course-186c5-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));
      _items[productIndex] = product;
    } else {
      print('...');
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-course-186c5-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    final response = await http.delete(url);
    _items.removeAt(existingProductIndex);
    notifyListeners();
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
