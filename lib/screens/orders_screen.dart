import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Filters: 'All', 'Ongoing', 'Completed'
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedFilter == 'All',
                  onSelected: (s) { if (s) setState(() => _selectedFilter = 'All'); },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Ongoing'),
                  selected: _selectedFilter == 'Ongoing',
                  onSelected: (s) { if (s) setState(() => _selectedFilter = 'Ongoing'); },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: _selectedFilter == 'Completed',
                  selectedColor: Colors.green.shade100,
                  onSelected: (s) { if (s) setState(() => _selectedFilter = 'Completed'); },
                ),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return const Center(child: Text("Error loading orders"));

                final allDocs = snapshot.data?.docs ?? [];

                // Client-side Filtering
                final visibleDocs = allDocs.where((doc) {
                  final status = doc['status'] ?? 'Order Placed';
                  if (_selectedFilter == 'All') return true;
                  if (_selectedFilter == 'Ongoing') return status == 'Order Placed';
                  if (_selectedFilter == 'Completed') return status == 'Completed';
                  return false;
                }).toList();

                if (visibleDocs.isEmpty) return const Center(child: Text('No orders found.'));

                return ListView.builder(
                  itemCount: visibleDocs.length,
                  itemBuilder: (ctx, i) {
                    final orderData = visibleDocs[i].data() as Map<String, dynamic>;
                    final status = orderData['status'] ?? 'Placed';
                    DateTime date;
                    try {
                      date = DateTime.parse(orderData['dateTime']);
                    } catch (e) {
                      date = DateTime.now();
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: status == 'Completed' ? Colors.green.shade100 : Colors.orange.shade100,
                              child: Icon(status == 'Completed' ? Icons.check : Icons.local_shipping),
                            ),
                            title: Text(
                              'Order ID: ${visibleDocs[i].id}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            subtitle: Text(
                              '\$${orderData['amount']}  •  ${DateFormat('dd/MM/yyyy hh:mm').format(date)}',
                            ),
                            trailing: Chip(
                              label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: status == 'Completed' ? Colors.green : Colors.orange,
                            ),
                          ),
                          ExpansionTile(
                            title: const Text("View Items"),
                            children: (orderData['products'] as List).map((prod) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(prod['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${prod['quantity']}x \$${prod['price']}'),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}