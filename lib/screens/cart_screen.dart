import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import './checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    final cartKeys = cart.items.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          // Total Amount Card
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text('\$${cart.totalAmount.toStringAsFixed(2)}'),
                    backgroundColor: Theme.of(context).primaryColorLight,
                  ),
                  TextButton(
                    onPressed: (cart.totalAmount <= 0)
                        ? null // Disable if empty
                        : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const CheckoutScreen()),
                      );
                    },
                    child: const Text('CHECKOUT'),
                  )
                ],
              ),
            ),
          ),

          // List of Items
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => Dismissible(
                key: ValueKey(cartKeys[i]),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  Provider.of<CartProvider>(context, listen: false).removeSingleItem(cartKeys[i]);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: FittedBox(child: Text('\$${cartItems[i].price}')),
                      ),
                    ),
                    title: Text(cartItems[i].name),
                    subtitle: Text('Total: \$${(cartItems[i].price * cartItems[i].quantity).toStringAsFixed(2)}'),

                    // Quantity Controls (+ / -)
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false).removeSingleItem(cartKeys[i]);
                            },
                          ),
                          Text('${cartItems[i].quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false).addItem(cartKeys[i], cartItems[i].price, cartItems[i].name);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}