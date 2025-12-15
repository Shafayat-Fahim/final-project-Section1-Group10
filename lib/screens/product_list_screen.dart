import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import './cart_screen.dart';
import './product_detail_screen.dart';
import './orders_screen.dart';
import './profile_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANCHOR SPORTS'),
        actions: [
          // Profile
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ProfileScreen())),
          ),
          // History
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const OrdersScreen())),
          ),
          // Cart
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(label: Text(cart.itemCount.toString()), child: ch),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CartScreen())),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No products found"));

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, i) {
              Product product = Product.fromSnapshot(docs[i]);
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => ProductDetailScreen(product: product)),
                ),
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black87,
                    title: Text(product.name, textAlign: TextAlign.center),
                    trailing: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      color: Colors.orange,
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(product.id, product.price, product.name);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)));
                      },
                    ),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) => const Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}