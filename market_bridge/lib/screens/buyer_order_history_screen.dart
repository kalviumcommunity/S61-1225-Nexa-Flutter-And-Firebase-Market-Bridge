import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyerOrderHistoryScreen extends StatelessWidget {
  const BuyerOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to view your orders.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('buyerId', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load orders.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                final orders = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final productName = order['crop'] ?? order['productName'] ?? 'Unknown Product';
                    final quantity = order['quantity'] ?? 'N/A';
                    final price = order['price'] ?? order['pricePerUnit'] ?? 0;
                    final status = order['status'] ?? 'pending';
                    final date = order['createdAt'] != null ? (order['createdAt'] as Timestamp).toDate() : null;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Color(0xFF2196F3)),
                        title: Text(productName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: $quantity'),
                            Text('Price: ₹$price'),
                            Text('Status: $status'),
                            if (date != null)
                              Text('Date: 	${date.day}-${date.month}-${date.year}', style: const TextStyle(fontSize: 12)),
                          ],
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
