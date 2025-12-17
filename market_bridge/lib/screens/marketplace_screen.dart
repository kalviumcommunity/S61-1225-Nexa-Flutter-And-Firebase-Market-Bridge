import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final searchController = TextEditingController();

  final List<Map<String, dynamic>> crops = [
    {
      'name': 'Tomato',
      'quantity': '2 quintal',
      'price': '₹20/kg',
      'buyer': 'Ramesh',
      'distance': '3km',
      'rating': 4,
      'icon': '🍅',
    },
    {
      'name': 'Onion',
      'quantity': '5 quintal',
      'price': '₹24/kg',
      'buyer': 'Ramesh',
      'distance': '3km',
      'rating': 4,
      'icon': '🧅',
    },
    {
      'name': 'Potato',
      'quantity': '1 quintal',
      'price': '₹12/kg',
      'buyer': 'Ramesh',
      'distance': '3km',
      'rating': 4,
      'icon': '🥔',
    },
    {
      'name': 'Wheat',
      'quantity': '10 quintal',
      'price': '₹2400/quintal',
      'buyer': 'Ramesh',
      'distance': '3km',
      'rating': 4,
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
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          /// Header
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
                  'Browse buyer requirements',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search crops...',
                    hintStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: const Color(0xFF999999),
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF999999)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Crop List / Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  /// 📱 Mobile → List
                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      return _buildCropCard(
                          crops[index], screenWidth);
                    },
                  );
                } else {
                  /// 📲 Tablet → Grid
                  return GridView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    itemCount: crops.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      return _buildCropCard(
                          crops[index], screenWidth);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),

      /// Bottom Navigation
      bottomNavigationBar: Container(
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
                _buildNavItem(Icons.home_outlined, 'Home', false),
                _buildNavItem(Icons.store_outlined, 'Marketplace', true),
                _buildNavItem(Icons.person_outline, 'Dashboard', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropCard(
      Map<String, dynamic> crop, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    child: Text(
                      crop['icon'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop['name'],
                        style: TextStyle(
                          fontSize:
                              screenWidth < 600 ? 18 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        crop['quantity'],
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
              crop['price'],
              style: TextStyle(
                fontSize: screenWidth < 600 ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF11823F),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Buyer: ${crop['buyer']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                const Icon(Icons.star,
                    size: 14, color: Color(0xFFFFB800)),
                const SizedBox(width: 4),
                Text('${crop['rating']}'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _showListingDetails(crop),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF11823F),
                ),
                child: const Text('View Requirement'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive
              ? const Color(0xFF11823F)
              : const Color(0xFF999999),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? const Color(0xFF11823F)
                : const Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  void _showListingDetails(Map<String, dynamic> crop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListingDetailsScreen(crop: crop),
      ),
    );
  }
}

/// =====================
/// Listing Details Screen
/// =====================
class ListingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> crop;

  const ListingDetailsScreen({Key? key, required this.crop})
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Listing Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: isTablet ? 380 : 280,
              color: const Color(0xFFF0F0F0),
              child: Center(
                child: Text(
                  crop['icon'],
                  style: const TextStyle(fontSize: 120),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.all(isTablet ? 32 : 20),
              child: Text(
                crop['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
