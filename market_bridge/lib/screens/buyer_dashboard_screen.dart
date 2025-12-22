// lib/screens/buyer_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../routes.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  int _selectedIndex = 2; // Dashboard is default

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, Routes.routeHome);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, Routes.routeMarketPlace);
    } else if (index == 2) {
      // Already on Dashboard
    }
  }

  final List<Map<String, dynamic>> _myOrders = [
    {
      'crop': 'Tomato',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'farmer': 'Kumar',
      'status': 'pending',
      'date': '2 days ago',
      'icon': 'assets/icons/tomato.png',
      'isAsset': true,
    },
    {
      'crop': 'Onion',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'farmer': 'Kumar',
      'status': 'confirmed',
      'date': '2 days ago',
      'icon': 'assets/icons/onion.png',
      'isAsset': true,
    },
  ];

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
    final isAsset = order['isAsset'] ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: Color(0xFF2196F3)),
            const SizedBox(width: 8),
            const Text(
              'Track Order',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isAsset
                      ? Image.asset(
                          order['icon'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_food_beverage,
                              size: 40,
                              color: Colors.orange,
                            );
                          },
                        )
                      : Text(
                          order['icon'],
                          style: const TextStyle(fontSize: 50),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Order: ${order['crop']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Quantity: ${order['quantity']}'),
            Text('Farmer: ${order['farmer']}'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    final padding = screenWidth * 0.04;

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
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(padding),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track your orders and interests',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  SizedBox(height: padding),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return isTablet
                          ? Row(
                              children: [
                                _buildStatCard(
                                  icon: Icons.receipt_long,
                                  label: 'Total Orders',
                                  value: '8',
                                  screenWidth: screenWidth,
                                ),
                                SizedBox(width: padding),
                                _buildStatCard(
                                  icon: Icons.attach_money,
                                  label: 'Total Spent',
                                  value: '₹32,000',
                                  screenWidth: screenWidth,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildStatCard(
                                  icon: Icons.receipt_long,
                                  label: 'Total Orders',
                                  value: '8',
                                  screenWidth: screenWidth,
                                ),
                                SizedBox(height: padding),
                                _buildStatCard(
                                  icon: Icons.attach_money,
                                  label: 'Total Spent',
                                  value: '₹32,000',
                                  screenWidth: screenWidth,
                                ),
                              ],
                            );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildSectionCard(
                    title: 'Quick Actions',
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.storefront, size: 20),
                            label: const Text('Browse Produce'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: padding),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications,
                              size: 20,
                              color: Color(0xFF2196F3),
                            ),
                            label: const Text('Set Alerts'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                              side: const BorderSide(color: Color(0xFF2196F3)),
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: padding),

                  // My Orders Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Orders',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
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
                  SizedBox(height: padding / 2),

                  // Orders Grid/List
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (_myOrders.isEmpty) return _buildEmptyState(padding);

                      final crossAxisCount = isTablet ? 2 : 1;

                      return SizedBox(
                        height: 300, // Fix: Give bounded height to GridView
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myOrders.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: padding,
                            mainAxisSpacing: padding,
                            childAspectRatio: isTablet ? 1.5 : 1.8,
                          ),
                          itemBuilder: (context, index) =>
                              _buildOrderCard(order: _myOrders[index]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _onNavTap(0),
                  child: _buildNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isActive: _selectedIndex == 0,
                    onTap: () {},
                  ),
                ),
                GestureDetector(
                  onTap: () => _onNavTap(1),
                  child: _buildNavItem(
                    icon: Icons.store_outlined,
                    label: 'Marketplace',
                    isActive: _selectedIndex == 1,
                    onTap: () {},
                  ),
                ),
                GestureDetector(
                  onTap: () => _onNavTap(2),
                  child: _buildNavItem(
                    icon: Icons.person,
                    label: 'Dashboard',
                    isActive: _selectedIndex == 2,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
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
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2196F3), size: 24),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            SizedBox(height: 4),
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

  Widget _buildOrderCard({required Map<String, dynamic> order}) {
    final isAsset = order['isAsset'] ?? false;

    return Container(
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
          // Header
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
                  child: isAsset
                      ? Image.asset(
                          order['icon'],
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_food_beverage,
                              size: 28,
                              color: Colors.orange,
                            );
                          },
                        )
                      : Text(
                          order['icon'],
                          style: const TextStyle(fontSize: 28),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['crop'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['quantity'],
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
                  color: _getStatusBgColor(order['status']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(order['status']),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            order['price'],
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
                'From: ${order['farmer']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const Spacer(),
              Text(
                order['date'],
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
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
          SizedBox(height: padding / 2),
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
          SizedBox(height: padding),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.routeMarketPlace),
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
