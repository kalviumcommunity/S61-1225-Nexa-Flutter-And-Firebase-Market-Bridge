import 'package:market_bridge/screens/buyer_profile_screen.dart';
import 'package:market_bridge/screens/buyer_order_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buyer_marketplace_screen.dart' show BuyerListingDetailsScreen;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_bridge/screens/buyer_marketplace_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
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

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;

  // Filters and search
  String _searchQuery = '';
  String _sortBy = 'recent';
  String _filterStatus = 'all';
  Set<String> _selectedOrders = {};
  bool _isSelectMode = false;

  // Map product names to asset icon filenames
  String? _getProductIconAsset(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('apple')) return 'assets/icons/apple.png';
    if (name.contains('banana')) return 'assets/icons/bananas.png';
    if (name.contains('bean')) return 'assets/icons/bean.png';
    if (name.contains('bell pepper')) return 'assets/icons/bell-pepper.png';
    if (name.contains('brinjal') || name.contains('eggplant'))
      return 'assets/icons/brinjal.png';
    if (name.contains('brown rice')) return 'assets/icons/brown-rice.png';
    if (name.contains('butter')) return 'assets/icons/butter.png';
    if (name.contains('cabbage')) return 'assets/icons/cabbage.png';
    if (name.contains('carrot')) return 'assets/icons/carrots.png';
    if (name.contains('chili') || name.contains('chili pepper'))
      return 'assets/icons/chili-pepper.png';
    if (name.contains('coriander')) return 'assets/icons/coriander.png';
    if (name.contains('corn')) return 'assets/icons/corn.png';
    if (name.contains('cucumber')) return 'assets/icons/cucumber.png';
    if (name.contains('curd')) return 'assets/icons/curd.png';
    if (name.contains('dragonfruit')) return 'assets/icons/dragonfruit.png';
    if (name.contains('ghee')) return 'assets/icons/ghee.png';
    if (name.contains('grape')) return 'assets/icons/grapes.png';
    if (name.contains('green chili'))
      return 'assets/icons/green-chili-pepper.png';
    if (name.contains('ladyfinger') || name.contains('okra'))
      return 'assets/icons/ladyfinger.png';
    if (name.contains('mango')) return 'assets/icons/mango.png';
    if (name.contains('milk')) return 'assets/icons/milk.png';
    if (name.contains('mint')) return 'assets/icons/mint.png';
    if (name.contains('mushroom')) return 'assets/icons/mushroom.png';
    if (name.contains('oat')) return 'assets/icons/oat.png';
    if (name.contains('onion')) return 'assets/icons/onion.png';
    if (name.contains('orange')) return 'assets/icons/orange.png';
    if (name.contains('papaya')) return 'assets/icons/papaya.png';
    if (name.contains('pea')) return 'assets/icons/peas.png';
    if (name.contains('pineapple')) return 'assets/icons/pineapple.png';
    if (name.contains('pomegranate')) return 'assets/icons/pomegranate.png';
    if (name.contains('potato')) return 'assets/icons/potato.png';
    if (name.contains('pumpkin')) return 'assets/icons/pumpkin.png';
    if (name.contains('quinoa')) return 'assets/icons/quinoa.png';
    if (name.contains('raddish') || name.contains('radish'))
      return 'assets/icons/raddish.png';
    if (name.contains('rice')) return 'assets/icons/rice.png';
    if (name.contains('spinach')) return 'assets/icons/spinach.png';
    if (name.contains('strawberry')) return 'assets/icons/strawberry.png';
    if (name.contains('tomato')) return 'assets/icons/tomato.png';
    if (name.contains('watermelon')) return 'assets/icons/watermelon.png';
    if (name.contains('yogurt')) return 'assets/icons/yogurt.png';
    return null;
  }

  final GlobalKey<RefreshIndicatorState> _refreshKey =
  GlobalKey<RefreshIndicatorState>();

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
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // New helper functions for advanced features
  String _getCropIcon(String crop) {
    final c = crop.toLowerCase();
    final icons = {
      'tomato': '🍅',
      'onion': '🧅',
      'potato': '🥔',
      'carrot': '🥕',
      'cabbage': '🥬',
      'spinach': '🥬',
      'wheat': '🌾',
      'rice': '🌾',
      'corn': '🌽',
      'cucumber': '🥒',
      'eggplant': '🍆',
      'pepper': '🌶️',
      'broccoli': '🥦',
      'lettuce': '🥬',
      'pumpkin': '🎃',
      'apple': '🍎',
    };
    return icons[c] ?? '🌱';
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) _selectedOrders.clear();
    });
  }

  void _toggleOrderSelection(String docId) {
    setState(() {
      if (_selectedOrders.contains(docId)) {
        _selectedOrders.remove(docId);
      } else {
        _selectedOrders.add(docId);
      }
    });
  }

  Future<void> _shareOrder(
      String productName,
      double price,
      String farmerName,
      ) async {
    try {
      await Share.share(
        'I found fresh $productName from $farmerName at ₹$price on MarketBridge! 🌾',
        subject: 'Fresh Produce - $productName',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  List<Map<String, dynamic>> _filterAndSortOrders(
      List<QueryDocumentSnapshot> docs,
      ) {
    List<Map<String, dynamic>> orders = docs.map((doc) {
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    }).toList();

    if (_searchQuery.isNotEmpty) {
      orders = orders.where((item) {
        final crop = (item['crop'] ?? item['productName'] ?? '')
            .toString()
            .toLowerCase();
        final farmer = (item['farmer'] ?? item['farmerName'] ?? '')
            .toString()
            .toLowerCase();
        return crop.contains(_searchQuery.toLowerCase()) ||
            farmer.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_filterStatus != 'all') {
      orders = orders
          .where(
            (item) =>
        (item['status'] ?? 'pending').toString().toLowerCase() ==
            _filterStatus,
      )
          .toList();
    }

    switch (_sortBy) {
      case 'price_low':
        orders.sort(
              (a, b) => (a['totalAmount'] ?? a['price'] ?? 0).compareTo(
            b['totalAmount'] ?? b['price'] ?? 0,
          ),
        );
        break;
      case 'price_high':
        orders.sort(
              (a, b) => (b['totalAmount'] ?? b['price'] ?? 0).compareTo(
            a['totalAmount'] ?? a['price'] ?? 0,
          ),
        );
        break;
      case 'oldest':
        orders.sort((a, b) {
          final aDate =
              (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bDate =
              (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return aDate.compareTo(bDate);
        });
        break;
      case 'recent':
      default:
        orders.sort((a, b) {
          final aDate =
              (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bDate =
              (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
    }

    return orders;
  }

  Future<void> _showAnalytics(User? user) async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .get();

    int totalOrders = snapshot.docs.length;
    int deliveredOrders = 0;
    int pendingOrders = 0;
    double totalSpent = 0;
    int favoriteCount = favoriteListings.length;
    Map<String, int> topFarmers = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] ?? 'pending';
      if (status == 'delivered') {
        deliveredOrders++;
      } else if (status == 'pending') {
        pendingOrders++;
      }
      totalSpent += (data['totalAmount'] ?? 0).toDouble();

      String farmer = data['farmer'] ?? data['farmerName'] ?? 'Unknown';
      topFarmers[farmer] = (topFarmers[farmer] ?? 0) + 1;
    }

    var sortedFarmers = topFarmers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var top3 = sortedFarmers.take(3).toList();

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
                  const Text(
                    'Your Analytics',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticCard(
                      'Total Orders',
                      '$totalOrders',
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnalyticCard(
                      'Delivered',
                      '$deliveredOrders',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticCard(
                      'Pending',
                      '$pendingOrders',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnalyticCard(
                      'Favorites',
                      '$favoriteCount',
                      Icons.favorite,
                      Colors.red,
                    ),
                  ),
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
                    const Icon(
                      Icons.attach_money,
                      color: Color(0xFF2196F3),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const Text(
                      'Total Spent',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Top Farmers
              if (top3.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Top Farmers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                ...top3.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          _getCropIcon(entry.key),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
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
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(currentUser, isTablet),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    _buildSearchAndFilters(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrdersTab('all', currentUser),
                          _buildOrdersTab('delivered', currentUser),
                          _buildOrdersTab('pending', currentUser),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
      floatingActionButton: _isSelectMode
          ? FloatingActionButton.extended(
        onPressed: () {
          if (_selectedOrders.isEmpty) return;
          _showBulkActionMenu();
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.done),
        label: Text('${_selectedOrders.length} selected'),
      )
          : null,
    );
  }

  Widget _buildHeader(User? user, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => _showAnalytics(user),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance
                .collection('orders')
                .where('buyerId', isEqualTo: user.uid)
                .snapshots()
                : const Stream.empty(),
            builder: (context, snap) {
              int pending = 0, delivered = 0;
              double spent = 0;
              if (snap.hasData) {
                for (var doc in snap.data!.docs) {
                  final d = doc.data() as Map<String, dynamic>;
                  final status = d['status'] ?? 'pending';
                  final amount = (d['totalAmount'] ?? 0).toDouble();
                  spent += amount;
                  if (status == 'pending') {
                    pending++;
                  } else if (status == 'delivered') {
                    delivered++;
                  }
                }
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.pending_actions,
                          'Pending',
                          '$pending',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.check_circle,
                          'Delivered',
                          '$delivered',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.attach_money,
                          'Total Spent',
                          '₹${spent.toInt()}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.favorite,
                          'Favorites',
                          '${favoriteListings.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search orders...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _searchQuery = ''),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Filter and Sort chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Sort
                FilterChip(
                  label: const Text('Sort'),
                  avatar: const Icon(Icons.sort),
                  onSelected: (_) => _showSortMenu(),
                ),
                const SizedBox(width: 8),
                // Status filter
                FilterChip(
                  label: Text(
                    _filterStatus == 'all' ? 'All Status' : _filterStatus,
                  ),
                  onSelected: (_) => _showStatusFilterMenu(),
                  selected: _filterStatus != 'all',
                ),
                const SizedBox(width: 8),
                // Select mode
                FilterChip(
                  label: const Text('Select'),
                  avatar: Icon(_isSelectMode ? Icons.check : Icons.list),
                  onSelected: (_) => _toggleSelectMode(),
                  selected: _isSelectMode,
                ),
              ],
            ),
          ),
          // Tabs
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'All Orders'),
                Tab(text: 'Delivered'),
                Tab(text: 'Pending'),
              ],
            ),
          ),
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
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Recent', 'recent'),
            _buildSortOption('Oldest', 'oldest'),
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
      trailing: _sortBy == value
          ? const Icon(Icons.check, color: Color(0xFF2196F3))
          : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  void _showStatusFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Delivered', 'delivered'),
            _buildFilterOption('Pending', 'pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _filterStatus == value
          ? const Icon(Icons.check, color: Color(0xFF2196F3))
          : null,
      onTap: () {
        setState(() => _filterStatus = value);
        Navigator.pop(context);
      },
    );
  }

  void _showBulkActionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bulk Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Selected'),
              onTap: () {
                Navigator.pop(ctx);
                _showBulkShareDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all_outlined),
              title: const Text('Mark as Reviewed'),
              onTap: () {
                Navigator.pop(ctx);
                _bulkMarkAsReviewed();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBulkShareDialog() async {
    if (_selectedOrders.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected orders shared!'),
        backgroundColor: Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _selectedOrders.clear());
  }

  Future<void> _bulkMarkAsReviewed() async {
    if (_selectedOrders.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedOrders.length} orders marked as reviewed'),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _selectedOrders.clear());
  }

  Widget _buildOrdersTab(String filter, User? user) {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Please log in',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true);

    // Filter by tab selection
    if (filter == 'delivered') {
      query = query.where('status', isEqualTo: 'delivered');
    } else if (filter == 'pending') {
      query = query.where('status', isEqualTo: 'pending');
    }

    return RefreshIndicator(
      key: UniqueKey(),
      onRefresh: _refreshOrders,
      color: const Color(0xFF2196F3),
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Unable to load orders', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshOrders,
                    child: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            );
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return _buildEmptyOrdersState(filter);
          }
          // Data available
          final docs = snap.data!.docs;
          final orders = _filterAndSortOrders(docs);
          if (orders.isEmpty) {
            return _buildEmptyOrdersState(filter);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _isSelectMode
                  ? _buildSelectableOrderCard(order)
                  : _buildOrderCard(order: order);
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectableOrderCard(Map<String, dynamic> order) {
    final docId = order['id'] ?? '';
    final isSelected = _selectedOrders.contains(docId);
    return GestureDetector(
      onTap: () => _toggleOrderSelection(docId),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            _buildOrderCard(order: order),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState(String filter) {
    String title = 'No orders yet';
    String message = 'Start browsing fresh produce from farmers';
    IconData icon = Icons.shopping_bag_outlined;

    if (filter == 'delivered') {
      title = 'No delivered orders';
      message = 'Your completed orders will appear here';
    } else if (filter == 'pending') {
      title = 'No pending orders';
      message = 'Your current orders will appear here';
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, Routes.routeMarketPlace);
              },
              icon: const Icon(Icons.storefront),
              label: const Text('Browse Marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
    );
  }

  Widget _buildOrderCard({required Map<String, dynamic> order}) {
    final items = order['items'] as List<dynamic>? ?? [];
    final firstItem = items.isNotEmpty ? items[0] as Map<String, dynamic> : {};
    // Try to get product name from order or item, fallback to crop, then unknown
    String productName =
    (order['productName'] ??
        order['crop'] ??
        firstItem['productName'] ??
        firstItem['crop'] ??
        'Unknown Product')
        .toString();

    int quantity = 0;
    if (firstItem['quantity'] is int) {
      quantity = firstItem['quantity'] as int;
    } else if (firstItem['quantity'] is String) {
      quantity = int.tryParse(firstItem['quantity']) ?? 0;
    } else if (firstItem['quantity'] is double) {
      quantity = (firstItem['quantity'] as double).toInt();
    }
    String quantityStr = quantity.toString();

    int price = 0;
    if (firstItem['price'] is int) {
      price = firstItem['price'] as int;
    } else if (firstItem['price'] is String) {
      price = int.tryParse(firstItem['price']) ?? 0;
    } else if (firstItem['price'] is double) {
      price = (firstItem['price'] as double).toInt();
    }
    String priceStr = price.toString();

    final farmerName = (order['farmer'] ?? order['farmerName'] ?? 'Unknown')
        .toString();
    final status = (order['status'] ?? 'pending').toString();
    final assetIcon = _getProductIconAsset(productName);

    String dateDisplay = 'N/A';
    if (order['date'] != null) {
      dateDisplay = order['date'].toString();
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
                  child: assetIcon != null
                      ? Image.asset(assetIcon, width: 36, height: 36)
                      : Text('🌱', style: const TextStyle(fontSize: 28)),
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
            '₹${order['price'] ?? 0}',
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