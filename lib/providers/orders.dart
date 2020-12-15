import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  String authToken;
  String userId;
  void update(Auth auth, List<OrderItem> orders) {
    authToken = auth.token;
    userId = auth.userId;
    _orders = orders;
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-app-flutter-74de7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) return;
    extractedData.forEach((key, value) {
      loadedOrders.add(OrderItem(
        id: key,
        amount: value['amount'],
        products: (value['products'] as List<dynamic>)
            .map((e) => CartItem(
                  id: e['id'],
                  price: e['price'],
                  quantity: e['quantity'],
                  title: e['title'],
                ))
            .toList(),
        dateTime: DateTime.parse(value['dateTime']),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://shop-app-flutter-74de7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
