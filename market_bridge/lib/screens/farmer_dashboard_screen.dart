import 'package:flutter/material.dart';
import '../routes.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final List<Map<String, dynamic>> _myListings = [
    {
      'crop': 'Tomato',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'views': 12,
      'inquiries': 3,
      'status': 'active',
      'icon': 'assets/icons/tomato.png',
      'isAsset': true,
    },
    {
      'crop': 'Onion',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'views': 8,
      'inquiries': 1,
      'status': 'active',
      'icon': 'assets/icons/onion.png',
      'isAsset': true,
    },
  ];

  final List<Map<String, dynamic>> _recentActivity = [
    {'title': 'Buyer interest in Tomatoes', 'badge': '2 new', 'isNew': true},
    {'title': 'Onion listing views', 'badge': '12 views', 'isNew': false},
  ];

  void _deleteListing(int index) {
    setState(() => _myListings.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11823F),
        elevation: 0,
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 28 : 20),
              decoration: const BoxDecoration(
                color: Color(0xFF11823F),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Sales',
                    value: '₹45,000',
                    isTablet: isTablet,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Listings',
                    value: '${_myListings.length}',
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// RECENT ACTIVITY
                  _buildSectionCard(
                    title: 'Recent Activity',
                    child: Column(
                      children: _recentActivity
                          .map(
                            (a) => _buildActivityRow(
                          title: a['title'],
                          badge: a['badge'],
                          isNew: a['isNew'],
                        ),
                      )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// LISTINGS TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Listings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.routePostProduce);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// RESPONSIVE LISTINGS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        /// 📱 Mobile – List
                        return Column(
                          children: _myListings
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildListingCard(
                              listing: entry.value,
                              onDelete: () => _deleteListing(entry.key),
                            ),
                          )
                              .toList(),
                        );
                      } else {
                        /// 📲 Tablet – Grid
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myListings.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.3,
                          ),
                          itemBuilder: (context, index) {
                            return _buildListingCard(
                              listing: _myListings[index],
                              onDelete: () => _deleteListing(index),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// REUSABLE WIDGETS
  /// =======================

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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF11823F)),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Color(0xFF666666))),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          Expanded(child: Text(title)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNew
                  ? const Color(0xFF11823F).withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
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
    required VoidCallback onDelete,
  }) {
    final isAsset = listing['isAsset'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isAsset
                      ? Image.asset(
                    listing['icon'],
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to generic icon if asset fails
                      return const Icon(
                        Icons.emoji_food_beverage,
                        size: 24,
                        color: Colors.orange,
                      );
                    },
                  )
                      : Text(
                    listing['icon'],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  listing['crop'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF11823F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  listing['status'],
                  style: const TextStyle(
                    color: Color(0xFF11823F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            listing['price'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF11823F),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge('${listing['views']} views'),
              const SizedBox(width: 8),
              _buildBadge('${listing['inquiries']} inquiries'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete Listing'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}