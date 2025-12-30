// lib/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedIndex = 1; // Marketplace is selected
  final searchController = TextEditingController();
  String _searchQuery = '';

  // ===================== NEW =====================
  // Category filter state
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
  ];
  String _selectedCategory = 'All';

  // Sort options
  String _sortOption = 'Newest';

  // Favorites (local only)
  final Set<String> _favoriteIds = {};
  // ===================== NEW =====================

  // Get asset icon path for crop
  String _getAssetIconForCrop(String name) {
    switch (name.toLowerCase()) {
      case 'tomato':
        return 'assets/icons/tomato.png';
      case 'onion':
        return 'assets/icons/onion.png';
      case 'potato':
        return 'assets/icons/potato.png';
      case 'wheat':
      case 'rice':
        return 'assets/icons/rice.png';
      case 'cabbage':
        return 'assets/icons/cabbage.png';
      case 'carrot':
      case 'carrots':
        return 'assets/icons/carrots.png';
      case 'spinach':
        return 'assets/icons/spinach.png';
      default:
        return 'assets/icons/default.png';
    }
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, Routes.routeHome);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, Routes.routeDashboard);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, Routes.routeHome),
        ),
        title: const Text(
          'Marketplace',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // ===================== NEW =====================
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: (value) {
              setState(() => _sortOption = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Newest', child: Text('Newest')),
              PopupMenuItem(value: 'PriceLow', child: Text('Price: Low → High')),
              PopupMenuItem(value: 'PriceHigh', child: Text('Price: High → Low')),
              PopupMenuItem(value: 'Quantity', child: Text('Quantity')),
            ],
          ),
          // ===================== NEW =====================
        ],
      ),
      body: Column(
        children: [
          // Header with search
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              screenWidth * 0.04,
              8,
              screenWidth * 0.04,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse available produce',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search crops...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // ===================== NEW =====================
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _selectedCategory;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor:
                        const Color(0xFF11823F).withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFF11823F)
                              : Colors.black,
                        ),
                      );
                    },
                  ),
                ),
                // ===================== NEW =====================
              ],
            ),
          ),

          // Products List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('inStock', isEqualTo: true)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ===================== NEW =====================
                List<QueryDocumentSnapshot> products =
                snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                  (data['name'] ?? '').toString().toLowerCase();
                  final category =
                  (data['category'] ?? '').toString();

                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery);
                  final matchesCategory = _selectedCategory == 'All' ||
                      category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                // Sorting
                if (_sortOption == 'PriceLow') {
                  products.sort((a, b) =>
                      (a['price'] ?? 0).compareTo(b['price'] ?? 0));
                } else if (_sortOption == 'PriceHigh') {
                  products.sort((a, b) =>
                      (b['price'] ?? 0).compareTo(a['price'] ?? 0));
                } else if (_sortOption == 'Quantity') {
                  products.sort((a, b) =>
                      (b['quantity'] ?? 0).compareTo(a['quantity'] ?? 0));
                }
                // ===================== NEW =====================

                return ListView.builder(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final data =
                    products[index].data() as Map<String, dynamic>;
                    return _buildCropCard(
                      data,
                      products[index].id, // NEW
                      screenWidth,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation (UNCHANGED)
      bottomNavigationBar: /* unchanged */,
    );
  }

  // ===================== UPDATED (INSERT ONLY) =====================
  Widget _buildCropCard(
      Map<String, dynamic> crop,
      String docId, // NEW
      double screenWidth,
      ) {
    final isFavorite = _favoriteIds.contains(docId);

    return Stack(
      children: [
        // EXISTING CARD UI (unchanged)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: /* your existing card content */,
        ),

        // ===================== NEW =====================
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isFavorite) {
                  _favoriteIds.remove(docId);
                } else {
                  _favoriteIds.add(docId);
                }
              });
            },
            child: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite
                  ? const Color(0xFF11823F)
                  : Colors.grey,
            ),
          ),
        ),
        // ===================== NEW =====================
      ],
    );
  }
}
