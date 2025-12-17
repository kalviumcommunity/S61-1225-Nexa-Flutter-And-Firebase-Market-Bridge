import 'package:flutter/material.dart';
import '../routes.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  const BuyerMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BuyerMarketplaceScreen> createState() =>
      _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState
    extends State<BuyerMarketplaceScreen> {
  final searchController = TextEditingController();

  final List<Map<String, dynamic>> farmerListings = [
    {
      'name': 'Tomato',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'farmer': 'Ramesh',
      'distance': '3km',
      'rating': 4.0,
      'icon': '🍅',
    },
    {
      'name': 'Onion',
      'quantity': '5 quintal',
      'price': '₹24/kg',
      'farmer': 'Ramesh',
      'distance': '3km',
      'rating': 4.0,
      'icon': '🧅',
    },
    {
      'name': 'Potato',
      'quantity': '1 quintal',
      'price': '₹12/kg',
      'farmer': 'Ramesh',
      'distance': '3km',
      'rating': 4.0,
      'icon': '🥔',
    },
    {
      'name': 'Wheat',
      'quantity': '10 quintal',
      'price': '₹2400/quintal',
      'farmer': 'Ramesh',
      'distance': '3km',
      'rating': 4.0,
      'icon': '🌾',
    },
  ];

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
      ),
      body: Column(
        children: [
          // Header + Search
          Container(
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
                  style:
                      TextStyle(fontSize: 14, color: Color(0xFF666666)),
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
          ),

          // Listings
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // 📱 Mobile → List
                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    itemCount: farmerListings.length,
                    itemBuilder: (context, index) {
                      return _buildListingCard(
                        farmerListings[index],
                        isTablet,
                      );
                    },
                  );
                } else {
                  // 📲 Tablet → Grid
                  return GridView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    itemCount: farmerListings.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) {
                      return _buildListingCard(
                        farmerListings[index],
                        isTablet,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),

      // Bottom Nav
      bottomNavigationBar: SafeArea(
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
              _buildNavItem(Icons.home_outlined, 'Home', false,
                  () => Navigator.pop(context)),
              _buildNavItem(Icons.store, 'Marketplace', true, () {}),
              _buildNavItem(
                Icons.person_outline,
                'Dashboard',
                false,
                () => Navigator.pushNamed(
                    context, Routes.routeDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(
      Map<String, dynamic> listing, bool isTablet) {
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(listing['icon'],
                      style: const TextStyle(fontSize: 28)),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            listing['price'],
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Farmer: ${listing['farmer']}',
                style: const TextStyle(fontSize: 13),
              ),
              const Spacer(),
              const Icon(Icons.star,
                  size: 14, color: Color(0xFFFFB800)),
              const SizedBox(width: 2),
              Text('${listing['rating']}'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _showListingDetails(listing),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active
                  ? const Color(0xFF2196F3)
                  : const Color(0xFF999999)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active
                  ? const Color(0xFF2196F3)
                  : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(Map<String, dynamic> listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BuyerListingDetailsScreen(listing: listing),
      ),
    );
  }
}

/* ===================== DETAILS SCREEN ===================== */

class BuyerListingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> listing;

  const BuyerListingDetailsScreen({Key? key, required this.listing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          'Listing Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: isTablet ? 380 : 280,
              alignment: Alignment.center,
              child: Text(
                listing['icon'],
                style: TextStyle(fontSize: isTablet ? 140 : 120),
              ),
            ),
            Padding(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
