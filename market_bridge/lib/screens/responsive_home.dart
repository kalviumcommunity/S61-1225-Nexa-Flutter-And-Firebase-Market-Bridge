// lib/screens/responsive_home_enhanced.dart
import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResponsiveHomeEnhanced extends StatelessWidget {
  const ResponsiveHomeEnhanced({Key? key}) : super(key: key);

  List<Map<String, String>> get produce => [
    {"name": "Tomato", "price": "₹20/kg", "change": "+5%"},
    {"name": "Onion", "price": "₹25/kg", "change": "+2%"},
    {"name": "Potato", "price": "₹12/kg", "change": "-3%"},
    {"name": "Wheat", "price": "₹2400/quintal", "change": "+8%"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define breakpoints
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            
            // Determine device type
            final DeviceType deviceType = _getDeviceType(width);
            
            // Responsive configurations
            final config = _getResponsiveConfig(deviceType, width, height);

            return Column(
              children: [
                // Header
                _buildHeader(context, config, deviceType),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: config.horizontalPadding,
                      vertical: config.verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLocationCard(config),
                        SizedBox(height: config.sectionSpacing),
                        
                        _buildSectionTitle("Today's Market Prices", config),
                        SizedBox(height: config.itemSpacing),
                        
                        _buildProduceGrid(config, deviceType),
                        SizedBox(height: config.sectionSpacing),
                        
                        _buildQuickActions(context, config),
                        SizedBox(height: config.sectionSpacing),
                        
                        _buildTrendingDemand(config),
                        SizedBox(height: config.sectionSpacing),
                        
                        _buildActionButtons(context, config),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Navigation
                _buildBottomNav(context, config, width, height),
              ],
            );
          },
        ),
      ),
    );
  }

  // Determine device type based on width
  DeviceType _getDeviceType(double width) {
    if (width < 600) return DeviceType.mobile;
    if (width < 900) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Get responsive configuration
  ResponsiveConfig _getResponsiveConfig(DeviceType type, double width, double height) {
    switch (type) {
      case DeviceType.mobile:
        return ResponsiveConfig(
          titleSize: 18,
          subtitleSize: 12,
          cardTitleSize: 14,
          horizontalPadding: width * 0.055,
          verticalPadding: height * 0.02,
          sectionSpacing: 18,
          itemSpacing: 12,
          gridColumns: 2,
          gridAspectRatio: 1.0,
          gridItemHeight: 120,
        );
      
      case DeviceType.tablet:
        return ResponsiveConfig(
          titleSize: 22,
          subtitleSize: 14,
          cardTitleSize: 16,
          horizontalPadding: width * 0.06,
          verticalPadding: height * 0.025,
          sectionSpacing: 24,
          itemSpacing: 16,
          gridColumns: 3,
          gridAspectRatio: 1.0,
          gridItemHeight: 140,
        );
      
      case DeviceType.desktop:
        return ResponsiveConfig(
          titleSize: 26,
          subtitleSize: 16,
          cardTitleSize: 18,
          horizontalPadding: width * 0.08,
          verticalPadding: height * 0.03,
          sectionSpacing: 32,
          itemSpacing: 20,
          gridColumns: 4,
          gridAspectRatio: 1.0,
          gridItemHeight: 160,
        );
    }
  }

  // Header Widget
  Widget _buildHeader(BuildContext context, ResponsiveConfig config, DeviceType type) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: type == DeviceType.mobile ? 14 : 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF11823F),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))
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
                    fontSize: config.titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.agriculture, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Farmer Mode',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: config.subtitleSize,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, Routes.routeSplash);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Location Card
  Widget _buildLocationCard(ResponsiveConfig config) {
    return Container(
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
            child: const Icon(Icons.location_on_outlined, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: config.cardTitleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Today, 10:30 AM',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: config.subtitleSize,
                  ),
                )
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: config.cardTitleSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // Produce Grid
  Widget _buildProduceGrid(ResponsiveConfig config, DeviceType type) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: produce.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.gridColumns,
        mainAxisExtent: config.gridItemHeight,
        crossAxisSpacing: config.itemSpacing,
        mainAxisSpacing: config.itemSpacing,
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
                    child: const Center(
                      child: Icon(
                        Icons.emoji_food_beverage,
                        size: 20,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.08)
                          : Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? Colors.green[700] : Colors.red[700],
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
                  fontSize: config.cardTitleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['price'] ?? '',
                style: TextStyle(
                  fontSize: config.subtitleSize + 1,
                  fontWeight: FontWeight.w800,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Quick Actions
  Widget _buildQuickActions(BuildContext context, ResponsiveConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF11823F),
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
              fontSize: config.cardTitleSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: config.itemSpacing),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.routePostProduce);
                  },
                  icon: const Icon(Icons.add_box, color: Colors.black87),
                  label: const Text(
                    'Post Produce',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                    Navigator.pushNamed(context, Routes.routeDashboard);
                  },
                  icon: const Icon(Icons.list_alt, color: Colors.black87),
                  label: const Text(
                    'My Listings',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }

  // Trending Demand
  Widget _buildTrendingDemand(ResponsiveConfig config) {
    return Container(
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
              const Icon(Icons.trending_up, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                'Trending Demand',
                style: TextStyle(
                  fontSize: config.cardTitleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: config.itemSpacing),
          const DemandRow(name: 'Spinach', status: 'High demand', icon: Icons.spa),
          const DemandRow(
            name: 'Lemon',
            status: 'High demand',
            icon: Icons.emoji_food_beverage,
          ),
          const DemandRow(
            name: 'Paddy',
            status: 'Harvest starting',
            icon: Icons.grass,
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(BuildContext context, ResponsiveConfig config) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E8B57)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'View Market Details',
              style: TextStyle(color: Color(0xFF2E8B57)),
            ),
          ),
        ),
        SizedBox(height: config.itemSpacing),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.routeMarketPlace);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11823F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'See Buyer Demand',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // Bottom Navigation
  Widget _buildBottomNav(
    BuildContext context,
    ResponsiveConfig config,
    double width,
    double height,
  ) {
    return Container(
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
        vertical: height * 0.012,
        horizontal: width * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const BottomNavItem(icon: Icons.home, label: 'Home', active: true),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.routeMarketPlace);
            },
            child: const BottomNavItem(icon: Icons.storefront, label: 'Marketplace'),
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
    );
  }
}

// Device Type Enum
enum DeviceType { mobile, tablet, desktop }

// Responsive Configuration Class
class ResponsiveConfig {
  final double titleSize;
  final double subtitleSize;
  final double cardTitleSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double sectionSpacing;
  final double itemSpacing;
  final int gridColumns;
  final double gridAspectRatio;
  final double gridItemHeight;

  ResponsiveConfig({
    required this.titleSize,
    required this.subtitleSize,
    required this.cardTitleSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.sectionSpacing,
    required this.itemSpacing,
    required this.gridColumns,
    required this.gridAspectRatio,
    required this.gridItemHeight,
  });
}

// Supporting Widgets
class DemandRow extends StatelessWidget {
  final String name;
  final String status;
  final IconData icon;

  const DemandRow({
    Key? key,
    required this.name,
    required this.status,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWarning = status.toLowerCase().contains('harvest');
    final color = isWarning ? Colors.blue : Colors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green[700]),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
    final color = active ? const Color(0xFF11823F) : Colors.black54;
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