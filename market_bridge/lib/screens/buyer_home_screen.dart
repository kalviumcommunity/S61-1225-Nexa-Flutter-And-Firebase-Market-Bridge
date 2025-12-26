// lib/screens/buyer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:market_bridge/screens/buyer_dashboard_screen.dart';
import '../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buyer_marketplace_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  int get orderCount => 3;
  int get newItemsCount => 2;

  const BuyerHomeScreen({Key? key}) : super(key: key);

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  List<Map<String, dynamic>> get produce => [
    {
      "name": "Tomato",
      "price": "₹20/kg",
      "change": "+5%",
      "icon": "assets/icons/tomato.png",
      "isAsset": true,
    },
    {
      "name": "Onion",
      "price": "₹25/kg",
      "change": "+2%",
      "icon": "assets/icons/onion.png",
      "isAsset": true,
    },
    {
      "name": "Potato",
      "price": "₹12/kg",
      "change": "-3%",
      "icon": "assets/icons/potato.png",
      "isAsset": true,
    },
    {
      "name": "Wheat",
      "price": "₹2400/quintal",
      "change": "+8%",
      "icon": "assets/icons/rice.png",
      "isAsset": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isTablet = screenWidth > 600;

    double titleSize = isTablet ? 22 : 18;
    double subtitleSize = isTablet ? 14 : 12;
    double cardTitleSize = isTablet ? 16 : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final gridCount = width > 900 ? 4 : (width > 600 ? 2 : 2);

            return Column(
              children: [
                // Header - Buyer Blue Theme
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 18 : 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                          color: Colors.white10,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Market Bridge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Buyer Mode',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: subtitleSize,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          tooltip: 'Logout',
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Location Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 6, bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: cardTitleSize,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Today, 10:30 AM',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: subtitleSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ),

                        // Today's Market Prices heading
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            "Today's Market Prices",
                            style: TextStyle(
                              fontSize: cardTitleSize,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        // Produce Grid
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: produce.length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            mainAxisExtent: isTablet ? 140 : 120,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final item = produce[index];
                            final change = item['change'] ?? '';
                            final isPositive = change.startsWith('+');
                            final isAsset = item['isAsset'] ?? false;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F7F7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: isAsset
                                              ? Image.asset(
                                            item['icon'],
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.emoji_food_beverage,
                                                size: 20,
                                                color: Colors.orange,
                                              );
                                            },
                                          )
                                              : Text(
                                            item['icon'] ?? '🥬',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPositive
                                              ? Colors.green.withOpacity(0.08)
                                              : Colors.red.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          change,
                                          style: TextStyle(
                                            color: isPositive
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: cardTitleSize,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['price'] ?? '',
                                    style: TextStyle(
                                      fontSize: subtitleSize + 1,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // Quick Actions - Buyer themed (contextual)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: cardTitleSize,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // FIXED: Navigate to buyer marketplace
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const BuyerMarketplaceScreen(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.storefront,
                                            color: Colors.black87,
                                          ),
                                          label: Text(
                                            'Browse Produce${newItemsCount > 0 ? '  (+$newItemsCount new)' : ''}',
                                            style: const TextStyle(color: Colors.black87),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        if (newItemsCount > 0)
                                          Positioned(
                                            right: 12,
                                            top: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '+$newItemsCount',
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Navigate to buyer dashboard
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const BuyerDashboardScreen(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.receipt_long,
                                            color: Colors.black87,
                                          ),
                                          label: Text(
                                            'My Orders${orderCount > 0 ? '  ($orderCount)' : ''}',
                                            style: const TextStyle(color: Colors.black87),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        if (orderCount > 0)
                                          Positioned(
                                            right: 12,
                                            top: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '$orderCount',
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Fresh from Farmers section
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.agriculture,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Fresh produce from farmers',
                                    style: TextStyle(
                                      fontSize: cardTitleSize,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const AvailabilityRow(
                                name: 'Tomato',
                                subtitle: '2 quintal',
                                icon: Icons.local_shipping,
                              ),
                              const AvailabilityRow(
                                name: 'Onion',
                                subtitle: '5 quintal',
                                icon: Icons.local_shipping,
                              ),
                              const AvailabilityRow(
                                name: 'Wheat',
                                subtitle: '10 quintal',
                                icon: Icons.local_shipping,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Action buttons
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              _showMarketDetailsBottomSheet(
                                context,
                                cardTitleSize,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2196F3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'View Market Details',
                              style: TextStyle(color: Color(0xFF2196F3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const BuyerMarketplaceScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Browse Available Produce',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                // Bottom navigation
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.012,
                    horizontal: width * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const BottomNavItem(
                        icon: Icons.home,
                        label: 'Home',
                        active: true,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const BuyerMarketplaceScreen(),
                            ),
                          );
                        },
                        child: const BottomNavItem(
                          icon: Icons.storefront,
                          label: 'Marketplace',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BuyerDashboardScreen(),
                            ),
                          );
                        },
                        child: const BottomNavItem(
                          icon: Icons.person_outline,
                          label: 'Dashboard',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Market Details Bottom Sheet
  void _showMarketDetailsBottomSheet(
      BuildContext context,
      double cardTitleSize,
      ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Color(0xFF2196F3),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Market Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMarketStat(
              'Active Listings',
              '245',
              Icons.list_alt,
              const Color(0xFF2196F3),
            ),
            _buildMarketStat('Total Farmers', '89', Icons.people, Colors.green),
            _buildMarketStat(
              'Available Produce',
              '1,450 quintals',
              Icons.inventory,
              Colors.orange,
            ),
            _buildMarketStat(
              'Average Price Change',
              '+3.2%',
              Icons.trending_up,
              Colors.teal,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuyerMarketplaceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Explore Marketplace',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStat(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AvailabilityRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  const AvailabilityRow({
    Key? key,
    required this.name,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2196F3) : Colors.black54;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}