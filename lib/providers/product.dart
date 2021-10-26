import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String? token) async {
    final url = Uri.parse(
        'https://shop-app-course-186c5-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    isFavorite = !isFavorite;
    notifyListeners();
    await http.patch(url, body: json.encode({'isFavorite': isFavorite}));
  }
}
