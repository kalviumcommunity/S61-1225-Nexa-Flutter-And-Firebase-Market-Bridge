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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(
            color: Color(0xFF11823F),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
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
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Sales this month',
                    value: '₹45,000',
                    isTablet: isTablet,
                  ),
                  const SizedBox(width: 16),
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
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
                vertical: 24,
              ),
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
                  const SizedBox(height: 28),

                  /// LISTINGS TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Listings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.routePostProduce);
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF11823F)),
                        label: const Text(
                          'Add New',
                          style: TextStyle(
                            color: Color(0xFF11823F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF11823F),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                                (entry) => Column(
                                  children: [
                                    _buildListingCard(
                                      listing: entry.value,
                                      onDelete: () => _deleteListing(entry.key),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
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
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
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
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 24 : 18,
          horizontal: isTablet ? 22 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF11823F),
              size: isTablet ? 36 : 30,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11823F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 14),
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isNew
                  ? const Color(0xFF11823F).withOpacity(0.13)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: isNew ? const Color(0xFF11823F) : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isAsset
                      ? Image.asset(
                          listing['icon'],
                          width: 34,
                          height: 34,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to generic icon if asset fails
                            return const Icon(
                              Icons.emoji_food_beverage,
                              size: 28,
                              color: Colors.orange,
                            );
                          },
                        )
                      : Text(
                          listing['icon'],
                          style: const TextStyle(fontSize: 32),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  listing['crop'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF11823F).withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  listing['status'],
                  style: const TextStyle(
                    color: Color(0xFF11823F),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Text(
            listing['price'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11823F),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildBadge('${listing['views']} views'),
              const SizedBox(width: 10),
              _buildBadge('${listing['inquiries']} inquiries'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text(
                'Delete Listing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF11823F),
                side: const BorderSide(color: Color(0xFF11823F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF666666),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
