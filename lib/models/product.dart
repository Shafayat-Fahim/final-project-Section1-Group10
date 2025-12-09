import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  // Factory to convert Firebase data to a Product object
  factory Product.fromSnapshot(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      name: doc['name'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      category: doc['category'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
    );
  }
}
