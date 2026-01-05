// lib/screens/marketplace_screen_enhanced.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes.dart';

class MarketplaceScreenEnhanced extends StatefulWidget {
  const MarketplaceScreenEnhanced({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreenEnhanced> createState() => _MarketplaceScreenEnhancedState();
}

class _MarketplaceScreenEnhancedState extends State<MarketplaceScreenEnhanced> {
  int _selectedIndex = 1;
  final searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'latest'; // latest, price_low, price_high, popular
  RangeValues _priceRange = const RangeValues(0, 10000);
  bool _organicOnly = false;
  bool _negotiableOnly = false;

  final Map<String, IconData> _categoryIcons = {
    'Vegetables': Icons.eco,
    'Fruits': Icons.apple,
    'Grains': Icons.grain,
    'Pulses': Icons.settings_input_component,
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getCropIcon(String crop) {
    final name = crop.toLowerCase();
    if (name.contains('apple')) return 'assets/icons/apple.png';
    if (name.contains('banana')) return 'assets/icons/bananas.png';
    if (name.contains('bean')) return 'assets/icons/bean.png';
    if (name.contains('bell pepper')) return 'assets/icons/bell-pepper.png';
    if (name.contains('brinjal') || name.contains('eggplant')) return 'assets/icons/brinjal.png';
    if (name.contains('brown rice')) return 'assets/icons/brown-rice.png';
    if (name.contains('butter')) return 'assets/icons/butter.png';
    if (name.contains('cabbage')) return 'assets/icons/cabbage.png';
    if (name.contains('carrot')) return 'assets/icons/carrots.png';
    if (name.contains('chili') || name.contains('chili pepper')) return 'assets/icons/chili-pepper.png';
    if (name.contains('coriander')) return 'assets/icons/coriander.png';
    if (name.contains('corn')) return 'assets/icons/corn.png';
    if (name.contains('cucumber')) return 'assets/icons/cucumber.png';
    if (name.contains('curd')) return 'assets/icons/curd.png';
    if (name.contains('dragonfruit')) return 'assets/icons/dragonfruit.png';
    if (name.contains('ghee')) return 'assets/icons/ghee.png';
    if (name.contains('grape')) return 'assets/icons/grapes.png';
    if (name.contains('green chili')) return 'assets/icons/green-chili-pepper.png';
    if (name.contains('ladyfinger') || name.contains('okra')) return 'assets/icons/ladyfinger.png';
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
    if (name.contains('raddish') || name.contains('radish')) return 'assets/icons/raddish.png';
    if (name.contains('rice')) return 'assets/icons/rice.png';
    if (name.contains('spinach')) return 'assets/icons/spinach.png';
    if (name.contains('strawberry')) return 'assets/icons/strawberry.png';
    if (name.contains('tomato')) return 'assets/icons/tomato.png';
    if (name.contains('watermelon')) return 'assets/icons/watermelon.png';
    if (name.contains('yogurt')) return 'assets/icons/yogurt.png';
    return 'assets/icons/default.png';
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

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedCategory = null;
                          _priceRange = const RangeValues(0, 10000);
                          _organicOnly = false;
                          _negotiableOnly = false;
                        });
                        setState(() {});
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category Filter
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categoryIcons.keys.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcons[category],
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(category),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        setState(() {});
                      },
                      selectedColor: const Color(0xFF11823F),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Price Range
                const Text(
                  'Price Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${_priceRange.start.toInt()}'),
                    Text('₹${_priceRange.end.toInt()}'),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: const Color(0xFF11823F),
                  onChanged: (values) {
                    setModalState(() {
                      _priceRange = values;
                    });
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),

                // Quick Filters
                const Text(
                  'Quick Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Organic Only'),
                  value: _organicOnly,
                  onChanged: (value) {
                    setModalState(() {
                      _organicOnly = value!;
                    });
                    setState(() {});
                  },
                  activeColor: const Color(0xFF11823F),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Negotiable Price'),
                  value: _negotiableOnly,
                  onChanged: (value) {
                    setModalState(() {
                      _negotiableOnly = value!;
                    });
                    setState(() {});
                  },
                  activeColor: const Color(0xFF11823F),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11823F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Query<Map<String, dynamic>> _buildQuery() {
    // Simplified query to avoid composite index requirements
    // All filtering and sorting is done client-side for better performance
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('products')
        .where('inStock', isEqualTo: true);

    return query.limit(100); // Fetch more docs for client-side filtering
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterProducts(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
      ) {
    var result = products.where((doc) {
      final data = doc.data();

      // Category filter - check category field case-insensitively
      if (_selectedCategory != null) {
        final docCategory = (data['category'] ?? '').toString().toLowerCase();
        final selectedCat = _selectedCategory!.toLowerCase();
        if (docCategory != selectedCat) {
          return false;
        }
      }

      // Organic filter
      if (_organicOnly && (data['isOrganic'] != true)) {
        return false;
      }

      // Negotiable filter
      if (_negotiableOnly && (data['isNegotiable'] != true)) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = (data['name'] ?? data['crop'] ?? '').toString().toLowerCase();
        if (!name.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Price range filter
      final price = (data['price'] ?? 0).toDouble();
      if (price < _priceRange.start || price > _priceRange.end) {
        return false;
      }

      return true;
    }).toList();

    // Apply client-side sorting
    switch (_sortBy) {
      case 'latest':
        result.sort((a, b) {
          final aDate = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bDate = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
        break;
      case 'price_low':
        result.sort((a, b) {
          final aPrice = (a.data()['price'] ?? 0).toDouble();
          final bPrice = (b.data()['price'] ?? 0).toDouble();
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'price_high':
        result.sort((a, b) {
          final aPrice = (a.data()['price'] ?? 0).toDouble();
          final bPrice = (b.data()['price'] ?? 0).toDouble();
          return bPrice.compareTo(aPrice);
        });
        break;
      case 'popular':
        result.sort((a, b) {
          final aViews = (a.data()['views'] ?? 0).toInt();
          final bViews = (b.data()['views'] ?? 0).toInt();
          return bViews.compareTo(aViews);
        });
        break;
    }

    return result;
  }

  Future<void> _recordView(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error recording view: $e');
    }
  }

  Future<void> _recordInquiry(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'inquiries': FieldValue.increment(1),
      });

      // Also create an inquiry record
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('inquiries').add({
          'productId': productId,
          'buyerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
      }
    } catch (e) {
      debugPrint('Error recording inquiry: $e');
    }
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
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.routeHome),
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
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {
              // Navigate to cart/saved items
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search crops, vegetables, fruits...',
                          hintStyle: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: const Color(0xFF999999),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF999999),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF11823F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: _showFilters,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sort Options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('Latest', 'latest'),
                      const SizedBox(width: 8),
                      _buildSortChip('Price: Low to High', 'price_low'),
                      const SizedBox(width: 8),
                      _buildSortChip('Price: High to Low', 'price_high'),
                      const SizedBox(width: 8),
                      _buildSortChip('Popular', 'popular'),
                    ],
                  ),
                ),

                // Active Filters Display
                if (_selectedCategory != null || _organicOnly || _negotiableOnly)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_selectedCategory != null)
                          _buildActiveFilter(_selectedCategory!, () {
                            setState(() => _selectedCategory = null);
                          }),
                        if (_organicOnly)
                          _buildActiveFilter('Organic', () {
                            setState(() => _organicOnly = false);
                          }),
                        if (_negotiableOnly)
                          _buildActiveFilter('Negotiable', () {
                            setState(() => _negotiableOnly = false);
                          }),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF11823F)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredProducts = _filterProducts(snapshot.data!.docs);

                if (filteredProducts.isEmpty) {
                  return _buildNoResultsState();
                }

                return _buildProductGrid(filteredProducts, isTablet);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: const Color(0xFF11823F),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF11823F) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildActiveFilter(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: const Color(0xFF11823F).withOpacity(0.1),
      labelStyle: const TextStyle(
        color: Color(0xFF11823F),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProductGrid(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
      bool isTablet,
      ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 0.75 : 0.7,
      ),
      itemBuilder: (context, index) {
        final product = products[index].data();
        return _buildProductCard(products[index].id, product);
      },
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> product) {
    final name = product['name'] ?? product['crop'] ?? 'Unknown';
    final price = product['price'] ?? 0;
    final unit = product['unit'] ?? 'Kg';
    final imageUrl = product['imageUrl'] as String?;
    final isOrganic = product['isOrganic'] ?? false;
    final isNegotiable = product['isNegotiable'] ?? false;
    final quality = product['quality'] ?? '';

    return GestureDetector(
      onTap: () {
        _recordView(productId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: productId,
              product: product,
              onInquiry: () => _recordInquiry(productId),
            ),
          ),
        );
      },
      child: Container(
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
            // Image with Crop Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF11823F).withOpacity(0.1),
                          const Color(0xFF11823F).withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        _getCropIcon(product['crop'] ?? ''),
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 64, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                ),
                if (isOrganic)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🌿 Organic',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          _getCropIcon(product['crop'] ?? ''),
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 20, color: Colors.grey);
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (quality.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        quality,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹$price/$unit',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11823F),
                            ),
                          ),
                        ),
                        if (isNegotiable)
                          const Icon(
                            Icons.handshake,
                            size: 16,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new listings',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
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
                icon: Icons.home_rounded,
                label: 'Home',
                active: _selectedIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _buildNavItem(
                icon: Icons.storefront_rounded,
                label: 'Marketplace',
                active: _selectedIndex == 1,
                onTap: () => _onNavTap(1),
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Dashboard',
                active: _selectedIndex == 2,
                onTap: () => _onNavTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF11823F) : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF11823F) : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Product Detail Screen
class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> product;
  final VoidCallback onInquiry;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
    required this.product,
    required this.onInquiry,
  }) : super(key: key);

  void _showPhoneNumber(BuildContext context, String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seller Phone: $phoneNumber'),
        backgroundColor: const Color(0xFF11823F),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Copy',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: phoneNumber));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone number copied!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? product['crop'] ?? 'Unknown';
    final price = product['price'] ?? 0;
    final unit = product['unit'] ?? 'Kg';
    final quantity = product['quantity'] ?? 0;
    final location = product['location'] ?? 'N/A';
    final description = product['description'] ?? '';
    final quality = product['quality'] ?? '';
    final isOrganic = product['isOrganic'] ?? false;
    final isNegotiable = product['isNegotiable'] ?? false;
    final minOrder = product['minOrder'];
    final imageUrl = product['imageUrl'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Share product
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // Save product
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 80),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 80),
              ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.handshake, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                'Negotiable',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Location
                  Container(
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
                            color: const Color(0xFF11823F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF11823F),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Minimum Order
                  if (minOrder != null)
                    Container(
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
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Minimum Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  '$minOrder $unit',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Get seller's phone number
                    try {
                      final sellerDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(product['ownerId'])
                          .get();
                      
                      if (sellerDoc.exists) {
                        final phoneNumber = sellerDoc.data()?['phoneNumber'] ?? 
                                          sellerDoc.data()?['phone'] ?? 
                                          '';
                        if (phoneNumber.isNotEmpty) {
                          // Try to launch phone dialer
                          final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
                          try {
                            if (await canLaunchUrl(phoneUri)) {
                              await launchUrl(phoneUri);
                            } else {
                              // Fallback: show phone number in snackbar
                              _showPhoneNumber(context, phoneNumber);
                            }
                          } catch (e) {
                            // On emulator, show phone number instead
                            _showPhoneNumber(context, phoneNumber);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Phone number not available'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to get seller contact'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF11823F),
                    side: const BorderSide(color: Color(0xFF11823F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    onInquiry();
                    
                    // Create inquiry in Firestore
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await FirebaseFirestore.instance.collection('inquiries').add({
                          'productId': productId,
                          'productName': product['crop'] ?? 'Unknown',
                          'buyerId': user.uid,
                          'sellerId': product['ownerId'],
                          'status': 'pending',
                          'createdAt': FieldValue.serverTimestamp(),
                          'price': product['price'],
                          'unit': product['unit'],
                        });
                        
                        // Update product inquiry count
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(productId)
                            .update({
                          'inquiries': FieldValue.increment(1),
                        });
                      } catch (e) {
                        debugPrint('Error creating inquiry: $e');
                      }
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Inquiry sent! Seller will contact you soon.'),
                          backgroundColor: Color(0xFF11823F),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Inquiry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11823F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}