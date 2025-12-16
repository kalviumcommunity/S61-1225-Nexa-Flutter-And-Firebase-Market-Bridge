// lib/screens/farmer_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../routes.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  // Sample data for listings
  final List<Map<String, dynamic>> _myListings = [
    {
      'crop': 'Tomato',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'views': 12,
      'inquiries': 3,
      'status': 'active',
      'icon': '🍅',
    },
    {
      'crop': 'Onion',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'views': 8,
      'inquiries': 1,
      'status': 'active',
      'icon': '🧅',
    },
  ];

  // Recent activity data
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'title': 'Buyer interest in Tomatoes',
      'badge': '2 new',
      'isNew': true,
    },
    {
      'title': 'Onion listing views',
      'badge': '12 views',
      'isNew': false,
    },
  ];

  void _deleteListing(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Listing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myListings.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing deleted successfully'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editListing(int index) {
    // Navigate to edit screen (can be implemented later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11823F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.agriculture, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Farmer Dashboard',
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
            // Header Section with Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF11823F),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage your produce listings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.attach_money,
                        label: 'Sales this month',
                        value: '₹45,000',
                        isTablet: isTablet,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Active Listings',
                        value: '${_myListings.length}',
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Activity Card
                  _buildSectionCard(
                    title: 'Recent Activity',
                    child: Column(
                      children: _recentActivity
                          .map((activity) => _buildActivityRow(
                        title: activity['title'],
                        badge: activity['badge'],
                        isNew: activity['isNew'],
                      ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // My Listings Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Listings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.routePostProduce);
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: Color(0xFF11823F),
                        ),
                        label: const Text(
                          'Add New',
                          style: TextStyle(
                            color: Color(0xFF11823F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Listings
                  if (_myListings.isEmpty)
                    _buildEmptyState()
                  else
                    ..._myListings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final listing = entry.value;
                      return _buildListingCard(
                        listing: listing,
                        onEdit: () => _editListing(index),
                        onDelete: () => _deleteListing(index),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
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
                    Navigator.pushReplacementNamed(
                        context, Routes.routeMarketPlace);
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
                color: const Color(0xFF11823F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF11823F),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
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

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
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

  Widget _buildActivityRow({
    required String title,
    required String badge,
    required bool isNew,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNew
                  ? const Color(0xFF11823F).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isNew ? const Color(0xFF11823F) : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard({
    required Map<String, dynamic> listing,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
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
          // Header with icon and status
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
                  child: Text(
                    listing['icon'],
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
                      listing['crop'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing['quantity'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF11823F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  listing['status'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF11823F),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Price
          Text(
            listing['price'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF11823F),
            ),
          ),

          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _buildStatBadge(
                '${listing['views']} views',
                Icons.visibility_outlined,
              ),
              const SizedBox(width: 12),
              _buildStatBadge(
                '${listing['inquiries']} inquiries',
                Icons.message_outlined,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF11823F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFF11823F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF666666)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first produce listing',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.routePostProduce);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11823F),
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
            color: isActive ? const Color(0xFF11823F) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
              isActive ? const Color(0xFF11823F) : const Color(0xFF999999),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}