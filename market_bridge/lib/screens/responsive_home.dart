// lib/screens/responsive_home.dart
import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({Key? key}) : super(key: key);

  // simple data model for produce cards
  List<Map<String, String>> get produce => [
    {"name": "Tomato", "price": "₹20/kg", "change": "+5%"},
    {"name": "Onion", "price": "₹25/kg", "change": "+2%"},
    {"name": "Potato", "price": "₹12/kg", "change": "-3%"},
    {"name": "Wheat", "price": "₹2400/quintal", "change": "+8%"},
  ];

  @override
  Widget build(BuildContext context) {
    // screen sizes and breakpoints
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isTablet = screenWidth > 600;
    final isLarge = screenWidth > 900;

    // responsive text sizes
    double titleSize = isTablet ? 20 : 18;
    double subtitleSize = isTablet ? 14 : 12;
    double cardTitleSize = isTablet ? 16 : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Use LayoutBuilder width if you want more precise decisions
          final width = constraints.maxWidth;
          final gridCount = width > 900 ? 4 : (width > 600 ? 2 : 1);

          return Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: screenHeight * 0.015),
                decoration: const BoxDecoration(
                  color: Color(0xFF11823F), // Market-bridge green
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(6)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {},
                    ),
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
                          SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.agriculture,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Farmer Mode',
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
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // content area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.045, vertical: screenHeight * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Card
                      Container(
                        padding: EdgeInsets.all(width * 0.03),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 6,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.black54),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Location',
                                style: TextStyle(
                                    fontSize: cardTitleSize,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              'Today, 10:30 AM',
                              style: TextStyle(
                                  fontSize: subtitleSize, color: Colors.black54),
                            )
                          ],
                        ),
                      ),

                      // "Today's Market Prices" heading
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          "Today's Market Prices",
                          style: TextStyle(
                              fontSize: cardTitleSize, fontWeight: FontWeight.w700),
                        ),
                      ),

                      // Produce Grid - responsive columns
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: produce.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                          mainAxisExtent: isTablet ? 120 : 110,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: (width / gridCount) /
                              (isTablet ? 120 : 110),
                        ),
                        itemBuilder: (context, index) {
                          final item = produce[index];
                          final change = item['change'] ?? '';
                          final isPositive = change.startsWith('+');

                          return Container(
                            padding: EdgeInsets.all(width * 0.035),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x10000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // simple circular icon for product
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F3F3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.emoji_food_beverage,
                                          size: 20, color: Colors.orange)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: TextStyle(
                                            fontSize: cardTitleSize,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        item['price'] ?? '',
                                        style: TextStyle(
                                          fontSize: subtitleSize + 1,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        change,
                                        style: TextStyle(
                                            fontSize: subtitleSize,
                                            fontWeight: FontWeight.w700,
                                            color: isPositive
                                                ? Colors.green
                                                : Colors.red),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // Quick Actions
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.035, vertical: screenHeight * 0.015),
                        decoration: BoxDecoration(
                          color: const Color(0xFF11823F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: cardTitleSize,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  backgroundColor: Colors.white,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add_box, size: 16),
                                      SizedBox(width: 6),
                                      Text('Post Produce'),
                                    ],
                                  ),
                                ),
                                Chip(
                                  backgroundColor: Colors.white,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.list_alt, size: 16),
                                      SizedBox(width: 6),
                                      Text('My Listings'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Trending Demand card
                      Container(
                        padding: EdgeInsets.all(width * 0.035),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 6,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trending_up, color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Trending Demand',
                                  style: TextStyle(
                                      fontSize: cardTitleSize, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // demand items
                            Column(
                              children: const [
                                DemandRow(name: 'Spinach', status: 'High demand'),
                                DemandRow(name: 'Lemon', status: 'High demand'),
                                DemandRow(name: 'Paddy', status: 'Harvest starting'),
                              ],
                            )
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
                              side: const BorderSide(color: Color(0xFF2E8B57)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Colors.white),
                          child: const Text('View Market Details',
                              style: TextStyle(color: Color(0xFF2E8B57))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11823F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('See Buyer Demand'),
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // Bottom navigation (simple)
              Container(
                color: Colors.white,
                padding:
                EdgeInsets.symmetric(vertical: screenHeight * 0.012, horizontal: width * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const BottomNavItem(icon: Icons.home, label: 'Home', active: true),
                    const BottomNavItem(icon: Icons.storefront, label: 'Marketplace'),
                    const BottomNavItem(icon: Icons.person_outline, label: 'Dashboard'),
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

class DemandRow extends StatelessWidget {
  final String name;
  final String status;
  const DemandRow({Key? key, required this.name, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWarning = status.toLowerCase().contains('harvest');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('  •  $name', style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(status,
              style: TextStyle(
                  color: isWarning ? Colors.blue : Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const BottomNavItem(
      {Key? key, required this.icon, required this.label, this.active = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF11823F) : Colors.black54;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
