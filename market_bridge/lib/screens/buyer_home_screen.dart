// lib/screens/buyer_home_screen.dart - Enhanced with Farmer Dashboard Features
import 'package:flutter/material.dart';
import 'package:market_bridge/screens/buyer_dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buyer_marketplace_screen.dart';
import 'buyer_wishlist_screen.dart';
import '../routes.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _sortBy = 'recent';
  String _filterCategory = 'all';
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  late PageController _pageController;
  int _currentBannerIndex = 0;
  int _notificationCount = 0;
  
  // Dynamic stats variables
  int _orderCount = 0;
  int _wishlistCount = 0;
  int _listingsCount = 0;
  double _avgPrice = 0.0;

  int get orderCount => _orderCount;
  int get newItemsCount => 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startBannerAutoScroll();
    _loadNotificationCount();
    _loadDynamicStats();
  }

  Future<void> _loadNotificationCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();
    
    setState(() {
      _notificationCount = snapshot.docs.length;
    });
  }

  Future<void> _loadDynamicStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load order count
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: user.uid)
          .get();
      
      // Load wishlist count
      final prefs = await SharedPreferences.getInstance();
      final wishlistItems = prefs.getStringList('buyer_favorites') ?? [];
      
      // Load listings count and calculate average price
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      double totalPrice = 0;
      int priceCount = 0;
      
      for (var doc in productsSnapshot.docs) {
        final price = doc['price'] as num?;
        if (price != null) {
          totalPrice += price.toDouble();
          priceCount++;
        }
      }
      
      final avgPrice = priceCount > 0 ? totalPrice / priceCount : 0.0;
      
      setState(() {
        _orderCount = ordersSnapshot.docs.length;
        _wishlistCount = wishlistItems.length;
        _listingsCount = productsSnapshot.docs.length;
        _avgPrice = avgPrice;
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 18) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  Widget _buildBannerCarousel() {
    final banners = [
      {
        'title': '🛒 Fresh Farm Produce',
        'subtitle': 'Direct from farmers in your area',
        'color': const Color(0xFF2196F3),
      },
      {
        'title': '📈 Best Prices',
        'subtitle': 'Compare prices from multiple farmers',
        'color': const Color(0xFFFF9800),
      },
      {
        'title': '🚀 Quality Assured',
        'subtitle': 'Verified farmers & organic options',
        'color': const Color(0xFF4CAF50),
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      banner['color'] as Color,
                      (banner['color'] as Color).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (banner['color'] as Color).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banner['subtitle'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => Container(
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? const Color(0xFF2196F3)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildStatCardRow();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatCardRow(),
          ],
        );
      },
    );
  }

  Widget _buildStatCardRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_cart,
                label: 'Orders',
                value: '$_orderCount',
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                label: 'Wishlist',
                value: '$_wishlistCount',
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.inventory_2,
                label: 'Listings',
                value: '$_listingsCount',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'Avg Price',
                value: '₹${_avgPrice.toStringAsFixed(0)}',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.map,
                      label: 'View Map',
                      onTap: () {
                        Navigator.pushNamed(context, Routes.routeMap);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.storefront,
                      label: 'Browse',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyerMarketplaceScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.shopping_cart,
                      label: 'My Orders',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyerDashboardScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.favorite,
                      label: 'Wishlist',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuyerWishlistScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2196F3), size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketPrices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Market Prices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDefaultPrices(),
      ],
    );
  }

  Widget _buildDefaultPrices() {
    final prices = [
      {'name': 'Tomato', 'price': '₹20/kg', 'change': '+5%', 'icon': '🍅'},
      {'name': 'Onion', 'price': '₹25/kg', 'change': '+2%', 'icon': '🧅'},
      {'name': 'Potato', 'price': '₹12/kg', 'change': '-3%', 'icon': '🥔'},
      {'name': 'Wheat', 'price': '₹2400/quintal', 'change': '+8%', 'icon': '🌾'},
    ];

    return Column(
      children: prices.map((item) {
        return _buildPriceCard(
          name: item['name']!,
          price: item['price']!,
          change: item['change']!,
          icon: item['icon']!,
        );
      }).toList(),
    );
  }

  Widget _buildPriceCard({
    required String name,
    required String price,
    required String change,
    required String icon,
  }) {
    final isPositive = change.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('buyerId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildActivityCard(data);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> data) {
    final productName = data['productName'] ?? 'Unknown';
    final status = data['status'] ?? 'pending';
    final quantity = data['quantity'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getCropEmoji(productName),
              style: const TextStyle(fontSize: 24),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$quantity units • Status: ${status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'completed' 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'completed' ? Colors.green[700] : Colors.orange[700],
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights & Tips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.lightbulb,
          title: 'Best Time to Buy',
          description: 'Early morning at markets gets you freshest produce',
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.trending_down,
          title: 'Price Trends',
          description: 'Vegetable prices drop by 30% during harvest season',
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.verified_user,
          title: 'Quality Verification',
          description: 'All our farmers are verified and follow organic standards',
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toStringAsFixed(0);
  }

  String _getCropIcon(String crop) {
    final c = crop.toLowerCase();
    final icons = {
      'tomato': '🍅', 'onion': '🧅', 'potato': '🥔', 'carrot': '🥕',
      'cabbage': '🥬', 'spinach': '🥬', 'wheat': '🌾', 'rice': '🌾',
      'corn': '🌽', 'cucumber': '🥒', 'eggplant': '🍆', 'pepper': '🌶️',
    };
    return icons[c] ?? '🌱';
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _notificationCount == 0
                    ? Center(
                        child: Text(
                          'No new notifications',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView(
                        children: [
                          _buildNotificationItem(
                            'New Order Status',
                            'Your order #123 has been dispatched',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          _buildNotificationItem(
                            'Price Alert',
                            'Tomato prices dropped by 15%',
                            Icons.trending_down,
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildNotificationItem(
                            'New Farmer',
                            'A new verified farmer joined in your area',
                            Icons.agriculture,
                            Colors.orange,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/splash');
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final active = _selectedIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFF2196F3) : Colors.black54, size: 26),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          color: active ? const Color(0xFF2196F3) : Colors.black54,
          fontSize: 12,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        )),
      ],
    );
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

  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  void _showMarketAnalytics() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();

    int totalListings = snapshot.docs.length;
    int activeListings = 0;
    double avgPrice = 0;
    List<String> crops = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['inStock'] == true) activeListings++;
      avgPrice += (data['price'] ?? 0) as num;
      crops.add(data['crop'] ?? 'Unknown');
    }

    avgPrice = totalListings > 0 ? avgPrice / totalListings : 0;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Market Analytics', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildAnalyticCard('Active Listings', '$activeListings', Icons.list_alt, const Color(0xFF2196F3))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAnalyticCard('Total Produce', '$totalListings', Icons.inventory, Colors.orange)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF2196F3), size: 32),
                    const SizedBox(height: 8),
                    Text('₹${avgPrice.toStringAsFixed(0)}', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                    const Text('Average Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Popular Crops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    ...crops.take(5).toSet().map((crop) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text(_getCropEmoji(crop), style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(crop, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCropEmoji(String crop) {
    final c = crop.toLowerCase();
    final emojis = {
      'tomato': '🍅', 'onion': '🧅', 'potato': '🥔', 'carrot': '🥕',
      'cabbage': '🥬', 'spinach': '🥬', 'wheat': '🌾', 'rice': '🌾',
      'corn': '🌽', 'cucumber': '🥒', 'eggplant': '🍆', 'pepper': '🌶️',
      'broccoli': '🥦', 'lettuce': '🥬', 'pumpkin': '🎃', 'apple': '🍎',
    };
    return emojis[c] ?? '🌱';
  }

  Widget _buildAnalyticCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSortOption('Recent', 'recent'),
            _buildSortOption('Price: Low to High', 'price_low'),
            _buildSortOption('Price: High to Low', 'price_high'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _sortBy == value ? const Icon(Icons.check, color: Color(0xFF2196F3)) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Vegetables', 'vegetables'),
            _buildFilterOption('Grains', 'grains'),
            _buildFilterOption('Fruits', 'fruits'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _filterCategory == value ? const Icon(Icons.check, color: Color(0xFF2196F3)) : null,
      onTap: () {
        setState(() => _filterCategory = value);
        Navigator.pop(context);
      },
    );
  }

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
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final gridCount = width > 900 ? 4 : (width > 600 ? 2 : 2);

            return Column(
              children: [
                // Header - Buyer Blue Theme (Farmer Style)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseAuth.instance.currentUser != null
                                  ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots()
                                  : const Stream.empty(),
                              builder: (context, snapshot) {
                                final userName = snapshot.data?.get('name') ?? 'Buyer';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, $userName! 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.wb_sunny,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getGreeting(),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: _showNotifications,
                                  ),
                                  if (_notificationCount > 0)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          _notificationCount > 9 ? '9+' : '$_notificationCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () => _showLogoutDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: RefreshIndicator(
                      key: _refreshKey,
                      onRefresh: _refreshContent,
                      color: const Color(0xFF2196F3),
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Banner Carousel
                          _buildBannerCarousel(),
                          const SizedBox(height: 20),

                          // Quick Stats Section
                          _buildQuickStats(),
                          const SizedBox(height: 20),

                          // Quick Actions Section
                          _buildQuickActions(context),
                          const SizedBox(height: 20),

                          // Market Prices Section
                          _buildMarketPrices(),
                          const SizedBox(height: 24),

                          // Recent Activity Section
                          _buildRecentActivity(),

                          const SizedBox(height: 24),

                          // Insights & Tips Section
                          _buildInsights(),

                          const SizedBox(height: 24),
                        ],
                      ),
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
                        _buildNavItem(Icons.home, 'Home', 0),
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
                          child: _buildNavItem(Icons.storefront, 'Marketplace', 1),
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
                          child: _buildNavItem(Icons.person_outline, 'Dashboard', 2),
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