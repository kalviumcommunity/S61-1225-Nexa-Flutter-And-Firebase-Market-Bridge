import 'package:flutter/material.dart';
import '../routes.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  const BuyerMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  final searchController = TextEditingController();
  int _selectedIndex = 1; // Marketplace is default

  final List<Map<String, dynamic>> farmerListings = [
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      // Use the correct route for buyer dashboard, pass role
      Navigator.pushReplacementNamed(
        context,
        Routes.routeBuyerDashboard,
        arguments: {'role': 'buyer'},
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
          Expanded(child: _buildListingsSection(screenWidth, isTablet)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ============== AppBar ==============
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Marketplace',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============== Header with Search ==============
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
              prefixIcon: const Icon(Icons.search),
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
  Widget _buildListingsSection(double screenWidth, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile → List View
          return ListView.builder(
            padding: EdgeInsets.all(screenWidth * 0.04),
            itemCount: farmerListings.length,
            itemBuilder: (context, index) {
              return _buildListingCard(farmerListings[index], isTablet);
            },
          );
        } else {
          // Tablet → Grid View
          return GridView.builder(
            padding: EdgeInsets.all(screenWidth * 0.04),
            itemCount: farmerListings.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              return _buildListingCard(farmerListings[index], isTablet);
            },
          );
        }
      },
    );
  }

  // ============== Listing Card ==============
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
          _buildListingHeader(listing, isAsset, isTablet),
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

  Widget _buildViewDetailsButton(Map<String, dynamic> listing) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () => _showListingDetails(listing),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
        ),
        child: const Text('View Details'),
      ),
    );
  }

  // ============== Bottom Navigation ==============
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

class BuyerListingDetailsScreen extends StatelessWidget {
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
          ],
        ),
      ),
    );
  }

  // ============== AppBar ==============
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.black),
      title: const Text(
        'Listing Details',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  // ============== Image Section ==============
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
                    // TODO: Implement contact farmer (e.g., open chat or call)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact Farmer feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF2196F3)),
                  label: const Text('Contact Farmer', style: TextStyle(color: Color(0xFF2196F3))),
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
                    // TODO: Implement place order logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed! (Demo only)')),
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
