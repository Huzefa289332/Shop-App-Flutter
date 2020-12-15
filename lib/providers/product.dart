import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.description,
    @required this.id,
    @required this.imageUrl,
    @required this.price,
    @required this.title,
    this.isFavourite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    final url =
        'https://shop-app-flutter-74de7-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavourite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}
