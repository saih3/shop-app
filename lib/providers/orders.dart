import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final DateTime dateTime;
  final List<CartItem> products;
  final double amount;

  OrderItem({
    required this.id,
    required this.dateTime,
    required this.products,
    required this.amount,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
        'shop-app-course-186c5-default-rtdb.firebaseio.com', '/orders.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) return;
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  title: item['title'],
                  quantity: item['quantity']))
              .toList(),
          amount: orderData['amount']));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'shop-app-course-186c5-default-rtdb.firebaseio.com', '/orders.json');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.quantity,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        dateTime: DateTime.now(),
        products: cartProducts,
        amount: total,
      ),
    );
    notifyListeners();
  }
}
