import 'package:market_bridge/screens/buyer_profile_screen.dart';
import 'package:market_bridge/screens/buyer_order_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buyer_marketplace_screen.dart' show BuyerListingDetailsScreen;
// lib/screens/buyer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_bridge/screens/buyer_marketplace_screen.dart';
import '../routes.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/theme_helper.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  // For demo: store reviews as a map in shared_preferences
  Future<void> _showReviewDialog(Map<String, dynamic> order) async {
    final TextEditingController reviewController = TextEditingController();
    double rating = 5;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Rating:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toString(),
                      onChanged: (v) {
                        rating = v;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ),
                  Text(rating.toStringAsFixed(1)),
                ],
              ),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: 'Write your review...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final key =
                    'review_${order['crop'] ?? order['productName'] ?? order['name'] ?? ''}_${order['farmer'] ?? order['farmerName'] ?? ''}';
                await prefs.setStringList(key, [
                  rating.toString(),
                  reviewController.text,
                ]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review submitted!')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> favoriteListings = [];
  bool _loadingFavorites = true;
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loadingFavorites = true);
    final prefs = await SharedPreferences.getInstance();
    final favNames = prefs.getStringList('buyer_favorites') ?? [];
    // Use the same static listings as in marketplace for demo
    final allListings = [
      {
        'name': 'Tomato',
        'quantity': '2 quintal',
        'price': '₹20/kg',
        'farmer': 'Ramesh',
        'distance': '3km',
        'rating': 4.0,
        'icon': 'assets/icons/tomato.png',
        'isAsset': true,
      },
      {
        'name': 'Onion',
        'quantity': '5 quintal',
        'price': '₹24/kg',
        'farmer': 'Ramesh',
        'distance': '3km',
        'rating': 4.0,
        'icon': 'assets/icons/onion.png',
        'isAsset': true,
      },
      {
        'name': 'Potato',
        'quantity': '1 quintal',
        'price': '₹12/kg',
        'farmer': 'Ramesh',
        'distance': '3km',
        'rating': 4.0,
        'icon': 'assets/icons/potato.png',
        'isAsset': true,
      },
      {
        'name': 'Wheat',
        'quantity': '10 quintal',
        'price': '₹2400/quintal',
        'farmer': 'Ramesh',
        'distance': '3km',
        'rating': 4.0,
        'icon': 'assets/icons/rice.png',
        'isAsset': true,
      },
    ];
    setState(() {
      favoriteListings = allListings
          .where((l) => favNames.contains(l['name']))
          .toList();
      _loadingFavorites = false;
    });
  }

  // Pull-to-refresh for orders
  Future<void> _onRefresh() async {
    setState(() {}); // Triggers StreamBuilder to reload
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'delivered':
        return 'blue';
      default:
        return 'grey';
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.withOpacity(0.1);
      case 'pending':
        return Colors.orange.withOpacity(0.1);
      case 'delivered':
        return Colors.blue.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green[700]!;
      case 'pending':
        return Colors.orange[700]!;
      case 'delivered':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  void _trackOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.local_shipping, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('Track Order', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order: ${order['crop'] ?? order['productName'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Quantity: ${order['quantity'] ?? 'N/A'}'),
            Text('Farmer: ${order['farmerName'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text(
              'Tracking information will be available soon.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.width > 600;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.shopping_bag, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Buyer Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyerProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to view your dashboard',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _onRefresh();
                await _loadFavorites();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Stats
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Track your orders and interests',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('buyerId', isEqualTo: currentUser.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int totalOrders = 0;
                              double totalSpent = 0;

                              if (snapshot.hasData) {
                                totalOrders = snapshot.data!.docs.length;
                                for (var doc in snapshot.data!.docs) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final total = (data['totalAmount'] ?? 0)
                                      .toDouble();
                                  totalSpent += total;
                                }
                              }

                              return Row(
                                children: [
                                  _buildStatCard(
                                    icon: Icons.receipt_long,
                                    label: 'Total Orders',
                                    value: '$totalOrders',
                                    isTablet: isTablet,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    icon: Icons.attach_money,
                                    label: 'Total Spent',
                                    value: '₹${totalSpent.toStringAsFixed(0)}',
                                    isTablet: isTablet,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // My Favorites Section
                    Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Favorites',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _loadingFavorites
                              ? const Center(child: CircularProgressIndicator())
                              : favoriteListings.isEmpty
                              ? const Text('No favorites yet.')
                              : Column(
                                  children: favoriteListings.map((listing) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                BuyerListingDetailsScreen(
                                                  listing: listing,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        child: ListTile(
                                          leading: listing['isAsset'] == true
                                              ? Image.asset(
                                                  listing['icon'],
                                                  width: 40,
                                                  height: 40,
                                                )
                                              : null,
                                          title: Text(listing['name']),
                                          subtitle: Text(listing['price']),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),

                    // My Orders Section
                    Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Orders',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const BuyerOrderHistoryScreen(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      'View all',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Orders List
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('buyerId', isEqualTo: currentUser.uid)
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Unable to load orders',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () => setState(() {}),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return _buildEmptyState();
                              }

                              final orders = snapshot.data!.docs;
                              return Column(
                                children: orders.map((doc) {
                                  final order =
                                      doc.data() as Map<String, dynamic>;
                                  return _buildOrderCard(order: order);
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isActive: false,
                  onTap: () => Navigator.pop(context),
                ),
                _buildNavItem(
                  icon: Icons.store_outlined,
                  label: 'Marketplace',
                  isActive: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyerMarketplaceScreen(),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Dashboard',
                  isActive: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a stat card for dashboard header.
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2196F3), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section card with title and child widget.
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Builds a card for a single order.
  Widget _buildOrderCard({required Map<String, dynamic> order}) {
    final productName =
        order['crop'] ?? order['productName'] ?? 'Unknown Product';
    final quantity = order['quantity'] ?? 'N/A';
    final price = order['price'] ?? order['pricePerUnit'] ?? 0;
    final farmerName = order['farmer'] ?? order['farmerName'] ?? 'Unknown';
    final status = order['status'] ?? 'pending';
    final icon = order['icon'] ?? '🌱';

    String dateDisplay = 'N/A';
    if (order['date'] != null) {
      dateDisplay = order['date'];
    } else if (order['createdAt'] != null) {
      final timestamp = order['createdAt'] as Timestamp;
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        dateDisplay = 'Today';
      } else if (difference.inDays == 1) {
        dateDisplay = '1 day ago';
      } else if (difference.inDays < 7) {
        dateDisplay = '${difference.inDays} days ago';
      } else {
        dateDisplay = '${(difference.inDays / 7).floor()} weeks ago';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(status),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          Text(
            order['price'] != null ? order['price'] : '₹$price',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2196F3),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'From: $farmerName',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const Spacer(),
              Text(
                dateDisplay,
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _trackOrder(order),
                  icon: const Icon(Icons.local_shipping, size: 18),
                  label: const Text('Track Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReviewDialog(order),
                  icon: const Icon(Icons.rate_review, color: Color(0xFF2196F3)),
                  label: const Text(
                    'Leave a Review',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Empty state widget for when there are no orders.
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start browsing fresh produce from farmers',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.routeMarketPlace);
            },
            icon: const Icon(Icons.storefront),
            label: const Text('Browse Marketplace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a navigation item for the bottom nav bar.
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF2196F3) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? const Color(0xFF2196F3)
                  : const Color(0xFF999999),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
