import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
// lib/screens/buyer_marketplace_screen.dart
import 'package:flutter/material.dart';

import 'buyer_home_screen.dart';
import 'buyer_dashboard_screen.dart';
import '../routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  const BuyerMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  // Filter/sort state
  String? _selectedCropType;
  double _minRating = 0;
  String _sortBy = 'None';
  Set<String> favoriteIds = {};
  @override
  void initState() {
    super.initState();
    filteredListings = List.from(farmerListings);
    searchController.addListener(_onSearchChanged);
    _simulateLoading();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds = prefs.getStringList('buyer_favorites')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteIds.contains(name)) {
        favoriteIds.remove(name);
      } else {
        favoriteIds.add(name);
      }
      prefs.setStringList('buyer_favorites', favoriteIds.toList());
    });
  }

  final searchController = TextEditingController();
  int _selectedIndex = 1; // Marketplace is default
  bool _isLoading = false;
  List<Map<String, dynamic>> farmerListings = [
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
  List<Map<String, dynamic>> filteredListings = [];

  // Pull-to-refresh handler (move above build for reference)

  // Empty state widget for no results (move above build for reference)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchController.text.isEmpty
                  ? 'No listings available'
                  : 'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchController.text.isEmpty
                  ? 'Check back later for new produce.'
                  : 'Try a different search.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Simulate loading for demonstration
  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  // Filter and sort listings based on search, filters, and sort
  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    List<Map<String, dynamic>> results = farmerListings.where((listing) {
      final matchesQuery = listing['name'].toString().toLowerCase().contains(
        query,
      );
      final matchesCrop =
          _selectedCropType == null || listing['name'] == _selectedCropType;
      final matchesRating = (listing['rating'] ?? 0) >= _minRating;
      return matchesQuery && matchesCrop && matchesRating;
    }).toList();
    // Sort
    if (_sortBy == 'Price: Low to High') {
      results.sort(
        (a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])),
      );
    } else if (_sortBy == 'Price: High to Low') {
      results.sort(
        (a, b) => _parsePrice(b['price']).compareTo(_parsePrice(a['price'])),
      );
    } else if (_sortBy == 'Rating') {
      results.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    }
    setState(() {
      filteredListings = results;
    });
  }

  // Helper to parse price string (e.g., '₹20/kg' or '₹2400/quintal')
  int _parsePrice(dynamic price) {
    if (price is int) return price;
    if (price is String) {
      final digits = RegExp(
        r'\d+',
      ).allMatches(price).map((m) => m.group(0)).toList();
      if (digits.isNotEmpty) return int.tryParse(digits.first ?? '0') ?? 0;
    }
    return 0;
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // Navigate to buyer home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BuyerHomeScreen()),
        (route) => false,
      );
    } else if (index == 2) {
      // Navigate to buyer dashboard
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BuyerDashboardScreen()),
      );
    }
    // index == 1 means already on Marketplace
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(screenWidth),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    )
                  : filteredListings.isEmpty
                  ? _buildEmptyState()
                  : _buildListingsSection(screenWidth, isTablet),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Pull-to-refresh handler (moved outside build)
  Future<void> _onRefresh() async {
    await _simulateLoading();
    // In real app, fetch new data here
    setState(() {
      filteredListings = List.from(farmerListings);
      searchController.clear();
    });
  }

  // ============== AppBar ==============
  /// Builds the top app bar for the marketplace screen.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2196F3),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          tooltip: 'Filter & Sort',
          onPressed: _showFilterSortModal,
        ),
      ],
    );
  }

  // Show filter/sort modal
  void _showFilterSortModal() {
    final cropTypes = farmerListings
        .map((l) => l['name'] as String)
        .toSet()
        .toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? tempCrop = _selectedCropType;
        double tempRating = _minRating;
        String tempSort = _sortBy;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Crop type filter
                  DropdownButtonFormField<String>(
                    value: tempCrop,
                    hint: const Text('Crop Type'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Crops'),
                      ),
                      ...cropTypes
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                    ],
                    onChanged: (val) => setModalState(() => tempCrop = val),
                  ),
                  const SizedBox(height: 16),
                  // Rating filter
                  Row(
                    children: [
                      const Text('Min Rating:'),
                      Expanded(
                        child: Slider(
                          value: tempRating,
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: tempRating == 0
                              ? 'Any'
                              : tempRating.toString(),
                          onChanged: (v) => setModalState(() => tempRating = v),
                        ),
                      ),
                      Text(tempRating == 0 ? 'Any' : tempRating.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sort by
                  DropdownButtonFormField<String>(
                    value: tempSort,
                    items:
                        [
                              'None',
                              'Price: Low to High',
                              'Price: High to Low',
                              'Rating',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) =>
                        setModalState(() => tempSort = val ?? 'None'),
                    decoration: const InputDecoration(labelText: 'Sort By'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCropType = tempCrop;
                            _minRating = tempRating;
                            _sortBy = tempSort;
                          });
                          _onSearchChanged();
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============== Header with Search ==============
  /// Builds the header section with a search bar.
  Widget _buildHeader(double screenWidth) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fresh produce from farmers',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search crops...',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============== Listings Section ==============
  /// Builds the main listings section, responsive to device size.
  Widget _buildListingsSection(double screenWidth, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile → List View
          return ListView.builder(
            padding: EdgeInsets.all(screenWidth * 0.04),
            itemCount: filteredListings.length,
            itemBuilder: (context, index) {
              return _buildListingCard(filteredListings[index], isTablet);
            },
          );
        } else {
          // Tablet → Grid View
          return GridView.builder(
            padding: EdgeInsets.all(screenWidth * 0.04),
            itemCount: filteredListings.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              return _buildListingCard(filteredListings[index], isTablet);
            },
          );
        }
      },
    );
    // Empty state widget for no results
    Widget _buildEmptyState() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_mall_directory,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                searchController.text.isEmpty
                    ? 'No listings available'
                    : 'No results found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchController.text.isEmpty
                    ? 'Check back later for new produce.'
                    : 'Try a different search.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  // ============== Listing Card ==============
  /// Builds a card for each produce listing.
  Widget _buildListingCard(Map<String, dynamic> listing, bool isTablet) {
    final isAsset = listing['isAsset'] ?? false;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildListingHeader(listing, isAsset, isTablet)),
              IconButton(
                icon: Icon(
                  favoriteIds.contains(listing['name'])
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoriteIds.contains(listing['name'])
                      ? Colors.red
                      : Colors.grey,
                ),
                tooltip: favoriteIds.contains(listing['name'])
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: () => _toggleFavorite(listing['name']),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildListingPrice(listing, isTablet),
          const SizedBox(height: 12),
          _buildListingInfo(listing),
          const SizedBox(height: 16),
          _buildViewDetailsButton(listing),
        ],
      ),
    );
  }

  /// Builds the header row for a listing card, including icon and name.
  Widget _buildListingHeader(
    Map<String, dynamic> listing,
    bool isAsset,
    bool isTablet,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isAsset
                ? Image.asset(
                    listing['icon'],
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.emoji_food_beverage,
                        size: 28,
                        color: Colors.orange,
                      );
                    },
                  )
                : Text(listing['icon'], style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing['name'],
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                listing['quantity'],
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Displays the price for a listing.
  Widget _buildListingPrice(Map<String, dynamic> listing, bool isTablet) {
    return Text(
      listing['price'],
      style: TextStyle(
        fontSize: isTablet ? 22 : 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2196F3),
      ),
    );
  }

  /// Displays farmer, rating, and other info for a listing.
  Widget _buildListingInfo(Map<String, dynamic> listing) {
    return Row(
      children: [
        Text(
          'Farmer: ${listing['farmer']}',
          style: const TextStyle(fontSize: 13),
        ),
        const Spacer(),
        const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
        const SizedBox(width: 2),
        Text('${listing['rating']}'),
      ],
    );
  }

  /// Button to view details for a listing, with accessibility label.
  Widget _buildViewDetailsButton(Map<String, dynamic> listing) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Semantics(
        button: true,
        label: 'View details for ${listing['name']}',
        child: ElevatedButton(
          onPressed: () => _showListingDetails(listing),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'View Details',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ============== Bottom Navigation ==============
  /// Builds the bottom navigation bar for the buyer screens.
  Widget _buildBottomNav() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _onNavTap(0),
              child: _buildNavItem(
                Icons.home_outlined,
                'Home',
                _selectedIndex == 0,
              ),
            ),
            GestureDetector(
              onTap: () => _onNavTap(1),
              child: _buildNavItem(
                Icons.store,
                'Marketplace',
                _selectedIndex == 1,
              ),
            ),
            GestureDetector(
              onTap: () => _onNavTap(2),
              child: _buildNavItem(
                Icons.person_outline,
                'Dashboard',
                _selectedIndex == 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a navigation item for the bottom nav bar.
  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFF2196F3) : const Color(0xFF999999),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? const Color(0xFF2196F3) : const Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  /// Navigates to the details screen for a listing.
  void _showListingDetails(Map<String, dynamic> listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerListingDetailsScreen(listing: listing),
      ),
    );
  }
}

// =====================================================
// ============== LISTING DETAILS SCREEN ==============
// =====================================================

/// Details screen for a single produce listing.
class BuyerListingDetailsScreen extends StatelessWidget {
  Future<List<Map<String, String>>> _getReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = 'review_${listing['name']}_${listing['farmer']}';
    // For demo, only one review per user/order, so just check this key
    final review = prefs.getStringList(keyPrefix);
    if (review != null && review.length == 2) {
      return [
        {'rating': review[0], 'review': review[1]},
      ];
    }
    return [];
  }

  final Map<String, dynamic> listing;

  const BuyerListingDetailsScreen({Key? key, required this.listing})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isAsset = listing['isAsset'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageSection(isAsset, isTablet),
            _buildDetailsSection(context, isTablet),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
              child: FutureBuilder<List<Map<String, String>>>(
                future: _getReviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Text(
                      'No reviews yet.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  final avgRating =
                      reviews
                          .map((r) => double.tryParse(r['rating'] ?? '0') ?? 0)
                          .fold<double>(0, (a, b) => a + b) /
                      reviews.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${reviews.length} review${reviews.length > 1 ? 's' : ''})',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...reviews.map(
                        (r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFB800),
                                  size: 18,
                                ),
                                const SizedBox(width: 2),
                                Text(r['rating'] ?? ''),
                              ],
                            ),
                            subtitle: Text(r['review'] ?? ''),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== AppBar ==============
  /// Builds the app bar for the details screen.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2196F3),
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      title: const Text(
        'Listing Details',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // ============== Image Section ==============
  /// Displays the main image or icon for the listing.
  Widget _buildImageSection(bool isAsset, bool isTablet) {
    return Container(
      height: isTablet ? 380 : 280,
      color: const Color(0xFFF0F0F0),
      alignment: Alignment.center,
      child: isAsset
          ? Image.asset(
              listing['icon'],
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.emoji_food_beverage,
                  size: 120,
                  color: Colors.orange,
                );
              },
            )
          : Text(
              listing['icon'],
              style: TextStyle(fontSize: isTablet ? 140 : 120),
            ),
    );
  }

  // ============== Details Section ==============
  /// Builds the details section with all listing info and actions.
  Widget _buildDetailsSection(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing['name'],
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text('Quantity: ${listing['quantity']}'),
          const SizedBox(height: 12),
          Text(
            listing['price'],
            style: TextStyle(
              fontSize: isTablet ? 28 : 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Farmer: ${listing['farmer']}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Distance: ${listing['distance']}'),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.star,
            'Rating: ${listing['rating']}/5',
            iconColor: const Color(0xFFFFB800),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          farmerName: listing['farmer'] ?? 'Farmer',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF2196F3)),
                  label: const Text(
                    'Contact Farmer',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order placed! (Demo only)'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper for info rows in the details section.
  Widget _buildInfoRow(
    IconData icon,
    String text, {
    Color iconColor = const Color(0xFF666666),
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
