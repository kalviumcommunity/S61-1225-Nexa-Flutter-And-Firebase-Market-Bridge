// lib/screens/buyer_home_screen.dart
import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  List<Map<String, String>> get produce => [
    {"name": "Tomato", "price": "₹20/kg", "change": "+5%", "icon": "🍅"},
    {"name": "Onion", "price": "₹25/kg", "change": "+2%", "icon": "🧅"},
    {"name": "Potato", "price": "₹12/kg", "change": "-3%", "icon": "🥔"},
    {"name": "Wheat", "price": "₹2400/quintal", "change": "+8%", "icon": "🌾"},
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
        child: LayoutBuilder(builder: (context, constraints) {
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
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // menu
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

                    // title + buyer mode
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
                              const Icon(Icons.shopping_cart,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Buyer Mode',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: subtitleSize,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    // bell
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                    // logout
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.055,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Card
                      Container(
                        padding: const EdgeInsets.all(14),
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
                              child: const Icon(Icons.location_on_outlined,
                                  color: Colors.black54),
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
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                            )
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                )
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
                                        child: Text(
                                          item['icon'] ?? '🥬',
                                          style: const TextStyle(fontSize: 20),
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

                      // Quick Actions - Buyer themed
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
                            )
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.storefront,
                                        color: Colors.black87),
                                    label: const Text(
                                      'Browse Produce',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routes.routeDashboard);
                                    },
                                    icon: const Icon(Icons.receipt_long,
                                        color: Colors.black87),
                                    label: const Text(
                                      'My Orders',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
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
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.agriculture,
                                    color: Colors.green),
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
                          onPressed: () {},
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
                            Navigator.pushNamed(context, Routes.routeMarketPlace);
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

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/scrollable');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Open Scrollable Views',
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    )
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
                      onTap: () {},
                      child: const BottomNavItem(
                        icon: Icons.storefront,
                        label: 'Marketplace',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.routeDashboard);
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
        }),
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