// lib/screens/farmer_dashboard_screen.dart - Enhanced Production Version
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../routes.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;
  
  // Filters and search
  String _searchQuery = '';
  String _sortBy = 'recent';
  String _filterStatus = 'all';
  Set<String> _selectedListings = {};
  bool _isSelectMode = false;
  
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCropIcon(String crop) {
    final c = crop.toLowerCase();
    final icons = {
      'tomato': '🍅', 'onion': '🧅', 'potato': '🥔', 'carrot': '🥕',
      'cabbage': '🥬', 'spinach': '🥬', 'wheat': '🌾', 'rice': '🌾',
      'corn': '🌽', 'cucumber': '🥒', 'eggplant': '🍆', 'pepper': '🌶️',
      'broccoli': '🥦', 'lettuce': '🥬', 'pumpkin': '🎃', 'apple': '🍎',
    };
    return icons[c] ?? '🌱';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return const Color(0xFF11823F);
      case 'sold': return Colors.blue;
      case 'expired': return Colors.orange;
      case 'deleted': return Colors.red;
      default: return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _filterAndSortListings(List<QueryDocumentSnapshot> docs) {
    List<Map<String, dynamic>> listings = docs.map((doc) {
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    }).toList();

    if (_searchQuery.isNotEmpty) {
      listings = listings.where((item) {
        final crop = (item['crop'] ?? '').toString().toLowerCase();
        return crop.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_filterStatus != 'all') {
      listings = listings.where((item) => 
        (item['status'] ?? 'active').toString().toLowerCase() == _filterStatus
      ).toList();
    }

    switch (_sortBy) {
      case 'price_low':
        listings.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        break;
      case 'price_high':
        listings.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
        break;
      case 'views':
        listings.sort((a, b) => (b['views'] ?? 0).compareTo(a['views'] ?? 0));
        break;
      case 'recent':
      default:
        listings.sort((a, b) {
          final aDate = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bDate = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
    }

    return listings;
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) _selectedListings.clear();
    });
  }

  void _toggleListingSelection(String docId) {
    setState(() {
      if (_selectedListings.contains(docId)) {
        _selectedListings.remove(docId);
      } else {
        _selectedListings.add(docId);
      }
    });
  }

  Future<void> _shareListing(String crop, double price, String unit) async {
    try {
      await Share.share(
        'Check out this fresh $crop for ₹$price per $unit on MarketBridge! 🌾',
        subject: 'Fresh Produce - $crop',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  Future<void> _deleteListing(String docId, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .update({
            'status': 'deleted',
            'deletedAt': FieldValue.serverTimestamp(),
            'inStock': false,
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text('Listing moved to deleted')),
          ]),
          backgroundColor: const Color(0xFF11823F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () => _undoDelete(docId),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _undoDelete(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'status': 'active',
        'deletedAt': FieldValue.delete(),
        'inStock': true,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Listing restored'),
        backgroundColor: Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _markAsSold(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'status': 'sold',
        'soldAt': FieldValue.serverTimestamp(),
        'inStock': false,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Listing marked as sold'),
        backgroundColor: Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _toggleInStock(String docId, bool current) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'inStock': !current,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(!current ? 'Marked as in stock' : 'Marked as out of stock'),
        backgroundColor: const Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _bulkUpdateStatus(String newStatus) async {
    if (_selectedListings.isEmpty) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (String docId in _selectedListings) {
        batch.update(
          FirebaseFirestore.instance.collection('products').doc(docId),
          {'status': newStatus, 'updatedAt': FieldValue.serverTimestamp()},
        );
      }
      await batch.commit();
      setState(() => _selectedListings.clear());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_selectedListings.length} listings updated'),
        backgroundColor: const Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _editListing(String docId, Map<String, dynamic> data) {
    Navigator.pushNamed(context, Routes.routePostProduce, arguments: {
      'editListing': data,
      'listingId': docId,
    });
  }

  void _showListingOptions(String docId, Map<String, dynamic> data) {
    final inStock = data['inStock'] ?? true;
    final status = data['status'] ?? 'active';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11823F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_getCropIcon(data['crop'] ?? ''), style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['crop'] ?? 'Listing', style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold,
                      )),
                      Text('${data['quantity']} ${data['unit'] ?? 'Kg'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildOptionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Listing',
                subtitle: 'Update details',
                onTap: () {
                  Navigator.pop(ctx);
                  _editListing(docId, data);
                },
              ),
              if (status == 'active')
                _buildOptionTile(
                  icon: inStock ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  title: inStock ? 'Mark Out of Stock' : 'Mark In Stock',
                  subtitle: inStock ? 'Hide from marketplace' : 'Show in marketplace',
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleInStock(docId, inStock);
                  },
                ),
              if (status == 'active')
                _buildOptionTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Mark as Sold',
                  subtitle: 'Remove from active',
                  onTap: () {
                    Navigator.pop(ctx);
                    _markAsSold(docId);
                  },
                ),
              _buildOptionTile(
                icon: Icons.share_outlined,
                title: 'Share Listing',
                subtitle: 'Share with buyers',
                onTap: () {
                  Navigator.pop(ctx);
                  _shareListing(data['crop'] ?? '', data['price'] ?? 0.0, data['unit'] ?? 'Kg');
                },
              ),
              const Divider(height: 32),
              _buildOptionTile(
                icon: Icons.delete_outline,
                title: 'Delete Listing',
                subtitle: 'Can restore later',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(docId, data['imageUrl']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF11823F)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF11823F), size: 24),
      ),
      title: Text(title, style: TextStyle(
        color: color ?? Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      )),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(
        fontSize: 12, color: Colors.grey[600],
      )) : null,
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(String docId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text('Delete Listing?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ]),
        content: const Text(
          'This will be moved to deleted items. You can restore it later.',
          style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteListing(docId, imageUrl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.pushReplacementNamed(context, Routes.routeHome);
    else if (index == 1) Navigator.pushReplacementNamed(context, Routes.routeMarketPlace);
  }

  Future<void> _refreshListings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFF11823F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user),
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
                          _buildListingsTab('active', user),
                          _buildListingsTab('sold', user),
                          _buildListingsTab('expired', user),
                          _buildListingsTab('all', user),
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
                if (_selectedListings.isEmpty) return;
                _showBulkActionMenu();
              },
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.done),
              label: Text('${_selectedListings.length} selected'),
            )
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, Routes.routePostProduce),
              backgroundColor: const Color(0xFF11823F),
              icon: const Icon(Icons.add),
              label: const Text('New Listing'),
            ),
    );
  }

  Widget _buildHeader(User? user) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pushReplacementNamed(context, Routes.routeHome),
                ),
                const Text('Dashboard', style: TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                )),
              ]),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white, size: 26),
                  onPressed: () => _showAnalytics(),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance
                    .collection('products')
                    .where('ownerId', isEqualTo: user.uid)
                    .snapshots()
                : const Stream.empty(),
            builder: (context, snap) {
              int active = 0, sold = 0, views = 0;
              double value = 0;
              if (snap.hasData) {
                for (var doc in snap.data!.docs) {
                  final d = doc.data() as Map<String, dynamic>;
                  final inStock = d['inStock'] ?? false;
                  final isSold = d['sold'] == true;
                  if (inStock && !isSold) {
                    active++;
                    value += (d['price'] ?? 0) * (d['quantity'] ?? 0);
                  } else if (isSold) {
                    sold++;
                  }
                  views += (d['views'] ?? 0) as int;
                }
              }
              return Column(children: [
                Row(children: [
                  Expanded(child: _buildStatCard(Icons.inventory_2_outlined, 'Active', '$active')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.shopping_bag_outlined, 'Sold', '$sold')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildStatCard(Icons.trending_up_rounded, 'Total Value', '₹${value.toInt()}')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.visibility_outlined, 'Views', '$views')),
                ]),
              ]);
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
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
          )),
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
              hintText: 'Search crops...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  label: Text(_filterStatus == 'all' ? 'All Status' : _filterStatus.capitalize()),
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
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
              )],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF11823F),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Sold'),
                Tab(text: 'Expired'),
                Tab(text: 'All'),
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
            const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSortOption('Recent', 'recent'),
            _buildSortOption('Price: Low to High', 'price_low'),
            _buildSortOption('Price: High to Low', 'price_high'),
            _buildSortOption('Most Viewed', 'views'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _sortBy == value ? const Icon(Icons.check, color: Color(0xFF11823F)) : null,
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
            const Text('Filter by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Active', 'active'),
            _buildFilterOption('Sold', 'sold'),
            _buildFilterOption('Expired', 'expired'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _filterStatus == value ? const Icon(Icons.check, color: Color(0xFF11823F)) : null,
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
            const Text('Bulk Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Mark as Sold'),
              onTap: () {
                Navigator.pop(ctx);
                _bulkUpdateStatus('sold');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Selected'),
              onTap: () {
                Navigator.pop(ctx);
                _bulkDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bulkDelete() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Multiple Listings?'),
        content: Text('Delete ${_selectedListings.length} listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bulkUpdateStatus('deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch analytics data
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('ownerId', isEqualTo: user.uid)
        .get();

    int totalListings = snapshot.docs.length;
    int activeListings = 0;
    int totalViews = 0;
    int totalInquiries = 0;
    double totalRevenue = 0;
    Map<String, int> topCrops = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['inStock'] == true) activeListings++;
      totalViews += (data['views'] ?? 0) as int;
      totalInquiries += (data['inquiries'] ?? 0) as int;
      if (data['sold'] == true) {
        totalRevenue += (data['price'] ?? 0) * (data['quantity'] ?? 0);
      }
      
      String crop = data['crop'] ?? 'Unknown';
      topCrops[crop] = (topCrops[crop] ?? 0) + 1;
    }

    // Get top 3 crops
    var sortedCrops = topCrops.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var top3 = sortedCrops.take(3).toList();

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
                  const Text('Analytics Dashboard', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  Expanded(child: _buildAnalyticCard('Total Listings', '$totalListings', Icons.inventory, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAnalyticCard('Active', '$activeListings', Icons.check_circle, Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildAnalyticCard('Total Views', '$totalViews', Icons.visibility, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAnalyticCard('Inquiries', '$totalInquiries', Icons.question_answer, Colors.purple)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF11823F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.currency_rupee, color: Color(0xFF11823F), size: 32),
                    const SizedBox(height: 8),
                    Text('₹${totalRevenue.toStringAsFixed(0)}', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF11823F))),
                    const Text('Total Revenue', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Top Crops
              if (top3.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Top Crops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                ...top3.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(_getCropIcon(entry.key), style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF11823F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${entry.value}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
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

  Widget _buildListingsTab(String filter, User? user) {
    if (user == null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('Please log in', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700],
          )),
        ],
      ));
    }

    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true);

    // Filter by tab selection
    if (filter == 'active') {
      query = query.where('inStock', isEqualTo: true);
    } else if (filter == 'sold') {
      query = query.where('sold', isEqualTo: true);
    } else if (filter == 'expired') {
      query = query.where('inStock', isEqualTo: false);
    }

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _refreshListings,
      color: const Color(0xFF11823F),
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Unable to load', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _refreshListings,
                  child: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11823F),
                  ),
                ),
              ],
            ));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF11823F)));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return _buildEmptyState(filter);
          }
          // Data available
          final docs = snap.data!.docs;
          final listings = _filterAndSortListings(docs);
          if (listings.isEmpty) {
            return _buildEmptyState(filter);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: listings.length,
            itemBuilder: (context, idx) {
              final item = listings[idx];
              final docId = item['id'] as String;
              final isSelected = _selectedListings.contains(docId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _isSelectMode
                    ? Stack(
                        children: [
                          _buildListingCard(docId, item),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleListingSelection(docId),
                              checkColor: Colors.white,
                              activeColor: const Color(0xFF11823F),
                            ),
                          ),
                        ],
                      )
                    : _buildListingCard(docId, item),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    final config = {
      'active': [Icons.inventory_2_outlined, 'No active listings', 'Add Listing'],
      'sold': [Icons.shopping_bag_outlined, 'No sold items yet', 'View Active'],
      'expired': [Icons.schedule, 'No expired items', 'View Active'],
      'all': [Icons.inventory_outlined, 'No listings yet', 'Create Listing'],
    };
    final c = config[filter]!;
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(c[0] as IconData, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(c[1] as String, style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700],
          )),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              if (filter == 'sold' || filter == 'expired') {
                _tabController.animateTo(0);
              } else {
                Navigator.pushNamed(context, Routes.routePostProduce);
              }
            },
            icon: Icon(filter == 'active' ? Icons.add : Icons.list),
            label: Text(c[2] as String),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11823F),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildListingCard(String docId, Map<String, dynamic> data) {
    final crop = data['crop'] ?? 'Unknown';
    final qty = data['quantity'] ?? 0;
    final unit = data['unit'] ?? 'Kg';
    final price = data['price'] ?? 0;
    final status = data['status'] ?? 'active';
    final views = data['views'] ?? 0;
    final inquiries = data['inquiries'] ?? 0;
    final inStock = data['inStock'] ?? true;
    final imgUrl = data['imageUrl'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;
    String date = '';
    if (createdAt != null) date = DateFormat('MMM dd, yyyy').format(createdAt.toDate());

    return GestureDetector(
      onLongPress: () => _showListingOptions(docId, data),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF11823F).withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imgUrl != null && imgUrl.isNotEmpty
                        ? Image.network(imgUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(_getCropIcon(crop), style: const TextStyle(fontSize: 32)),
                            ))
                        : Center(child: Text(_getCropIcon(crop), style: const TextStyle(fontSize: 32))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('$qty $unit', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      if (date.isNotEmpty) Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(status.toUpperCase(), style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold,
                      )),
                    ),
                    if (!inStock && status == 'active')
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Out of Stock', style: TextStyle(
                          fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600,
                        )),
                      ),
                  ],
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹$price/$unit', style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF11823F),
                  )),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildStatBadge(Icons.visibility_outlined, '$views', 'views')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatBadge(Icons.chat_bubble_outline, '$inquiries', 'inquiries')),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editListing(docId, data),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF11823F),
                          side: const BorderSide(color: Color(0xFF11823F)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showListingOptions(docId, data),
                      icon: const Icon(Icons.more_vert),
                      style: IconButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        )],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.storefront_rounded, 'Marketplace', 1),
              _buildNavItem(Icons.person_rounded, 'Dashboard', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF11823F) : Colors.grey[400], size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: active ? const Color(0xFF11823F) : Colors.grey[400],
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
