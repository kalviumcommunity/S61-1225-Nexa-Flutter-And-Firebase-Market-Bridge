// lib/screens/buyer_marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'chat_screen.dart';
import 'buyer_home_screen.dart';
import 'buyer_dashboard_screen.dart';
// import 'buyer_listing_detail_screen.dart';  // Will be shown as generic detail screen
import '../routes.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  const BuyerMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  // Filter/sort state
  String? _selectedCategory;
  String _sortBy = 'latest';
  RangeValues _priceRange = const RangeValues(0, 10000);
  bool _organicOnly = false;
  bool _negotiableOnly = false;
  Set<String> favoriteIds = {};
  final searchController = TextEditingController();
  int _selectedIndex = 1; // Marketplace is default
  bool _isLoading = false;

  // Cart state
  Map<String, Map<String, dynamic>> cartItems =
      {}; // productId -> {product data, quantity}
  int cartCount = 0;
  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
    _loadFavorites();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('buyer_cart');
    if (cartJson != null) {
      try {
        final decoded = jsonDecode(cartJson) as Map<String, dynamic>;
        setState(() {
          cartItems = decoded.map(
            (key, value) => MapEntry(key, {
              'productId': value['productId'],
              'name': value['name'],
              'price': value['price'],
              'unit': value['unit'],
              'farmerName': value['farmerName'],
              'farmerPhone': value['farmerPhone'],
              'quantity': value['quantity'],
            }),
          );
          cartCount = cartItems.values.fold(
            0,
            (sum, item) => sum + (item['quantity'] as int),
          );
        });
      } catch (e) {
        debugPrint('Error loading cart: $e');
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buyer_cart', jsonEncode(cartItems));
  }

  Future<Map<String, dynamic>> _getFarmerDetails(String ownerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .get();
      if (doc.exists) {
        return {
          'farmerName':
              doc.data()?['name'] ??
              'Unknown Farmer',
          'farmerPhone':
              doc.data()?['phone'] ??
              '+91-XXXXXXXXXX',
          'farmerRating': (doc.data()?['rating'] ?? 4.5).toDouble(),
        };
      }
    } catch (e) {
      debugPrint('Error fetching farmer details: $e');
    }
    return {
      'farmerName': 'Unknown Farmer',
      'farmerPhone': '+91-XXXXXXXXXX',
      'farmerRating': 4.5,
    };
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

  // Crop image asset helper
  String _getCropAsset(String crop) {
    final cropLower = crop.toLowerCase();
    // Map crop names to asset filenames (add more as needed)
    const assetMap = {
      'tomato': 'assets/icons/tomato.png',
      'onion': 'assets/icons/onion.png',
      'potato': 'assets/icons/potato.png',
      'rice': 'assets/icons/rice.png',
      'wheat': 'assets/icons/wheat.png',
      'carrot': 'assets/icons/carrot.png',
      'brinjal': 'assets/icons/brinjal.png',
      'cabbage': 'assets/icons/cabbage.png',
      'corn': 'assets/icons/corn.png',
      'pumpkin': 'assets/icons/pumpkin.png',
      'pomegranate': 'assets/icons/pomegranate.png',
      'grapes': 'assets/icons/grapes.png',
      'mango': 'assets/icons/mango.png',
      'pineapple': 'assets/icons/pineapple.png',
      'orange': 'assets/icons/orange.png',
      'papaya': 'assets/icons/papaya.png',
      'peas': 'assets/icons/peas.png',
      'mint': 'assets/icons/mint.png',
      'mushroom': 'assets/icons/mushroom.png',
      'milk': 'assets/icons/milk.png',
      'ladyfinger': 'assets/icons/ladyfinger.png',
      'green chilli': 'assets/icons/green-chili-pepper.png',
      'oat': 'assets/icons/oat.png',
      'quinoa': 'assets/icons/quinoa.png',
      'raddish': 'assets/icons/raddish.png',
      'spinach': 'assets/icons/spinach.png',
      'cucumber': 'assets/icons/cucumber.png',
      'cauliflower': 'assets/icons/cauliflower.png',
      'coriander': 'assets/icons/coriander.png',
      'apple': 'assets/icons/apple.png',
      'banana': 'assets/icons/banana.png',
      'chilli': 'assets/icons/green-chili-pepper.png',
      'green-chili-pepper': 'assets/icons/green-chili-pepper.png',
      'lady finger': 'assets/icons/ladyfinger.png',
      'sweet potato': 'assets/icons/potato.png',
      'beetroot': 'assets/icons/beetroot.png',
      'turnip': 'assets/icons/turnip.png',
      'lettuce': 'assets/icons/lettuce.png',
      'broccoli': 'assets/icons/broccoli.png',
      'garlic': 'assets/icons/garlic.png',
      'ginger': 'assets/icons/ginger.png',
      'lemon': 'assets/icons/lemon.png',
      'watermelon': 'assets/icons/watermelon.png',
      'strawberry': 'assets/icons/strawberry.png',
      'coconut': 'assets/icons/coconut.png',
      'jackfruit': 'assets/icons/jackfruit.png',
      'sapota': 'assets/icons/sapota.png',
      'guava': 'assets/icons/guava.png',
      'pear': 'assets/icons/pear.png',
      'plum': 'assets/icons/plum.png',
      'fig': 'assets/icons/fig.png',
      'apricot': 'assets/icons/apricot.png',
      'peach': 'assets/icons/peach.png',
      'lychee': 'assets/icons/lychee.png',
      'custard apple': 'assets/icons/custard_apple.png',
      // Add more mappings as needed
    };
    // Try direct match, then fallback to a generic image
    return assetMap[cropLower] ??
        'assets/icons/fruit.png'; // fallback to a generic icon
  }

  // Build Firestore query
  Query<Map<String, dynamic>> _buildQuery() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('inStock', isEqualTo: true)
        .limit(100);
  }

  // Crop to Category Mapping
  static const Map<String, String> cropCategoryMap = {
    'Tomato': 'Vegetables',
    'Onion': 'Vegetables',
    'Potato': 'Vegetables',
    'Carrot': 'Vegetables',
    'Cabbage': 'Vegetables',
    'Spinach': 'Vegetables',
    'Cucumber': 'Vegetables',
    'Cauliflower': 'Vegetables',
    'Brinjal': 'Vegetables',
    'Ladyfinger': 'Vegetables',
    'Lady Finger': 'Vegetables',
    'Green Chilli': 'Vegetables',
    'Green Chilli Pepper': 'Vegetables',
    'Chilli': 'Vegetables',
    'Coriander': 'Vegetables',
    'Mint': 'Vegetables',
    'Oat': 'Grains',
    'Quinoa': 'Grains',
    'Raddish': 'Vegetables',
    'Radish': 'Vegetables',
    'Peas': 'Vegetables',
    'Pumpkin': 'Vegetables',
    'Beetroot': 'Vegetables',
    'Turnip': 'Vegetables',
    'Lettuce': 'Vegetables',
    'Broccoli': 'Vegetables',
    'Garlic': 'Vegetables',
    'Ginger': 'Vegetables',
    'Lemon': 'Fruits',
    'Apple': 'Fruits',
    'Banana': 'Fruits',
    'Grapes': 'Fruits',
    'Mango': 'Fruits',
    'Pineapple': 'Fruits',
    'Orange': 'Fruits',
    'Papaya': 'Fruits',
    'Pomegranate': 'Fruits',
    'Milk': 'Dairy',
    'Mushroom': 'Vegetables',
    'Corn': 'Vegetables',
    'Pear': 'Fruits',
    'Plum': 'Fruits',
    'Fig': 'Fruits',
    'Apricot': 'Fruits',
    'Peach': 'Fruits',
    'Lychee': 'Fruits',
    'Custard Apple': 'Fruits',
    'Coconut': 'Fruits',
    'Jackfruit': 'Fruits',
    'Sapota': 'Fruits',
    'Guava': 'Fruits',
    'Strawberry': 'Fruits',
    'Watermelon': 'Fruits',
    'Wheat': 'Grains',
    'Rice': 'Grains',
    // Add more as needed
  };

  String _getCropCategory(String crop) {
    return cropCategoryMap[crop] ?? 'Vegetables';
  }

  // Filter products client-side
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
  ) {
    final query = searchController.text.toLowerCase();

    var result = products.where((doc) {
      final data = doc.data();

      // Category filter - map crop to category
      if (_selectedCategory != null) {
        final cropName = (data['name'] ?? data['crop'] ?? '').toString();
        final docCategory = _getCropCategory(cropName);
        if (docCategory != _selectedCategory!) return false;
      }

      // Organic filter
      if (_organicOnly && (data['isOrganic'] != true)) return false;

      // Negotiable filter
      if (_negotiableOnly && (data['isNegotiable'] != true)) return false;

      // Search filter
      if (query.isNotEmpty) {
        final name = (data['name'] ?? data['crop'] ?? '')
            .toString()
            .toLowerCase();
        if (!name.contains(query)) return false;
      }

      // Price range filter
      final price = (data['price'] ?? 0).toDouble();
      if (price < _priceRange.start || price > _priceRange.end) return false;

      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'latest':
        result.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
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
          final aViews = (a.data()['views'] ?? 0) as int;
          final bViews = (b.data()['views'] ?? 0) as int;
          return bViews.compareTo(aViews);
        });
        break;
    }

    return result;
  }

  // Record product view
  Future<void> _recordView(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'views': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error recording view: $e');
    }
  }

  // Show product details with farmer info and order placement
  void _showProductDetails(
    BuildContext context,
    String productId,
    String name,
    dynamic price,
    String unit,
    String quality,
    String ownerId,
    bool isOrganic,
    bool isNegotiable,
  ) async {
    int quantity = 1;
    final farmerDetails = await _getFarmerDetails(ownerId);
    final farmerName = farmerDetails['farmerName'] ?? 'Unknown Farmer';
    final farmerRating = farmerDetails['farmerRating'] ?? 4.5;
    final farmerPhone = farmerDetails['farmerPhone'] ?? '+91-XXXXXXXXXX';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Product name and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Product icon
                      Center(
                        child: Image.asset(
                          _getCropAsset(name),
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹$price/$unit',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            if (isNegotiable)
                              const Chip(
                                label: Text('💰 Negotiable'),
                                backgroundColor: Colors.orange,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Badges
                      if (isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🌿 100% Organic Product',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (quality.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Quality: $quality',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Farmer Information Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.05),
                          border: Border.all(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Farmer Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '👨‍🌾',
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        farmerName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$farmerRating / 5.0',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 18,
                                  color: Color(0xFF2196F3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  farmerPhone,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quantity selector
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: quantity > 1
                                  ? () => setModalState(() => quantity--)
                                  : null,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '$quantity $unit',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setModalState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Total price
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${price * quantity}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Place Order button
                      Row(
                        children: [
                          // Add to Cart button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _addToCart(
                                  productId: productId,
                                  name: name,
                                  price: price,
                                  unit: unit,
                                  farmerName: farmerName,
                                  farmerPhone: farmerPhone,
                                  quantity: quantity,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Order Now button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _placeOrder(
                                  productId: productId,
                                  productName: name,
                                  quantity: quantity,
                                  price: price as int,
                                  unit: unit,
                                  farmerName: farmerName,
                                  farmerPhone: farmerPhone,
                                  totalAmount: price * quantity,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              icon: const Icon(Icons.check_circle),
                              label: const Text(
                                'Order Now',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
      },
    );
  }

  Future<void> _addToCart({
    required String productId,
    required String name,
    required dynamic price,
    required String unit,
    required String farmerName,
    required String farmerPhone,
    required int quantity,
  }) async {
    final priceInt = (price is String)
        ? int.parse(price)
        : (price as num).toInt();

    setState(() {
      if (cartItems.containsKey(productId)) {
        cartItems[productId]!['quantity'] += quantity;
      } else {
        cartItems[productId] = {
          'productId': productId,
          'name': name,
          'price': priceInt,
          'unit': unit,
          'farmerName': farmerName,
          'farmerPhone': farmerPhone,
          'quantity': quantity,
        };
      }
      cartCount = cartItems.values.fold(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );
    });

    await _saveCart();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $quantity $unit of $name added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showCart() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cartItems.length} items',
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cart items
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems.values.elementAt(index);
                    final productId = cartItems.keys.elementAt(index);
                    final total =
                        (item['price'] as int) * (item['quantity'] as int);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '₹${item['price']} per ${item['unit']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Farmer: ${item['farmerName']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Quantity controls
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2196F3),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => setState(() {
                                    if ((item['quantity'] as int) > 1) {
                                      item['quantity']--;
                                      cartCount--;
                                      _saveCart();
                                    }
                                  }),
                                  child: const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Center(
                                      child: Text(
                                        '-',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color(0xFF2196F3),
                                ),
                                SizedBox(
                                  width: 32,
                                  height: 28,
                                  child: Center(
                                    child: Text(
                                      '${item['quantity']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color(0xFF2196F3),
                                ),
                                InkWell(
                                  onTap: () => setState(() {
                                    item['quantity']++;
                                    cartCount++;
                                    _saveCart();
                                  }),
                                  child: const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Center(
                                      child: Text(
                                        '+',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹$total',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() {
                                  cartCount -= (item['quantity'] as int);
                                  cartItems.remove(productId);
                                  _saveCart();
                                }),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Total and checkout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${cartItems.values.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['quantity'] as int)))}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _checkoutCart(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Future<void> _checkoutCart() async {
    if (cartItems.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please login to place orders'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create separate orders for each product from different farmers
      final groupedByFarmer = <String, List<Map<String, dynamic>>>{};
      for (var item in cartItems.values) {
        final farmerName = item['farmerName'] as String;
        if (!groupedByFarmer.containsKey(farmerName)) {
          groupedByFarmer[farmerName] = [];
        }
        groupedByFarmer[farmerName]!.add(item);
      }

      // Save orders to Firebase
      for (var farmerName in groupedByFarmer.keys) {
        final farmerItems = groupedByFarmer[farmerName]!;
        final totalAmount = farmerItems.fold(
          0,
          (sum, item) =>
              sum + ((item['price'] as int) * (item['quantity'] as int)),
        );

        await FirebaseFirestore.instance.collection('orders').add({
          'buyerId': user.uid,
          'items': farmerItems
              .map(
                (item) => {
                  'productId': item['productId'],
                  'productName': item['name'],
                  'quantity': item['quantity'],
                  'unit': item['unit'],
                  'price': item['price'],
                  'totalItemAmount':
                      (item['price'] as int) * (item['quantity'] as int),
                },
              )
              .toList(),
          'totalAmount': totalAmount,
          'farmer': farmerName,
          'farmerName': farmerName,
          'farmerPhone': farmerItems[0]['farmerPhone'],
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'buyerEmail': user.email,
          'buyerPhone': user.phoneNumber ?? 'N/A',
        });
      }

      // Clear cart
      setState(() {
        cartItems.clear();
        cartCount = 0;
      });
      await _saveCart();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${groupedByFarmer.length} order(s) placed successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error placing orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Place order and save to Firebase
  Future<void> _placeOrder({
    required String productId,
    required String productName,
    required int quantity,
    required int price,
    required String unit,
    required String farmerName,
    required String farmerPhone,
    required int totalAmount,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place orders')),
        );
        return;
      }

      // Create order in Firebase
      await FirebaseFirestore.instance.collection('orders').add({
        'buyerId': user.uid,
        'productId': productId,
        'productName': productName,
        'crop': productName,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'pricePerUnit': price,
        'totalAmount': totalAmount,
        'farmer': farmerName,
        'farmerName': farmerName,
        'farmerPhone': farmerPhone,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'buyerEmail': user.email,
        'buyerPhone': user.phoneNumber ?? 'N/A',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    }
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

  @override
  void dispose() {
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
          // Search and filter header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar with filter button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2196F3),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: _showFilterModal,
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
                if (_selectedCategory != null ||
                    _organicOnly ||
                    _negotiableOnly)
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

          // Products Grid with StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2196F3)),
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
      selectedColor: const Color(0xFF2196F3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildActiveFilter(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
      labelStyle: const TextStyle(
        color: Color(0xFF2196F3),
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
    final isOrganic = product['isOrganic'] ?? false;
    final isNegotiable = product['isNegotiable'] ?? false;
    final quality = product['quality'] ?? '';
    final ownerId = product['ownerId'] ?? '';

    return GestureDetector(
      onTap: () {
        _recordView(productId);
        if (mounted) {
          _showProductDetails(
            context,
            productId,
            name,
            price,
            unit,
            quality,
            ownerId,
            isOrganic,
            isNegotiable,
          );
        }
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
            // Image with Crop Icon and Organic Badge
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
                          const Color(0xFF2196F3).withOpacity(0.1),
                          const Color(0xFF2196F3).withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        _getCropAsset(product['crop'] ?? ''),
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                ),
                if (isOrganic)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          _getCropAsset(product['crop'] ?? ''),
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported,
                                size: 20,
                                color: Colors.grey,
                              ),
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
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
                              color: Color(0xFF2196F3),
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

  // Pull-to-refresh handler
  Future<void> _onRefresh() async {
    setState(() {});
  }

  // ============== AppBar ==============
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
    );
  }

  // Show filter modal
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? tempCategory = _selectedCategory;
        RangeValues tempPriceRange = _priceRange;
        bool tempOrganic = _organicOnly;
        bool tempNegotiable = _negotiableOnly;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category Filter
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip('Vegetables', tempCategory, (val) {
                            setModalState(() => tempCategory = val);
                          }),
                          _buildCategoryChip('Fruits', tempCategory, (val) {
                            setModalState(() => tempCategory = val);
                          }),
                          _buildCategoryChip('Grains', tempCategory, (val) {
                            setModalState(() => tempCategory = val);
                          }),
                          _buildCategoryChip('Dairy', tempCategory, (val) {
                            setModalState(() => tempCategory = val);
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price Range
                      const Text(
                        'Price Range (₹)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RangeSlider(
                        values: tempPriceRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        activeColor: const Color(0xFF2196F3),
                        labels: RangeLabels(
                          '₹${tempPriceRange.start.round()}',
                          '₹${tempPriceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setModalState(() => tempPriceRange = values);
                        },
                      ),
                      Text(
                        '₹${tempPriceRange.start.round()} - ₹${tempPriceRange.end.round()}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      // Organic Only
                      CheckboxListTile(
                        title: const Text('Organic Products Only'),
                        value: tempOrganic,
                        activeColor: const Color(0xFF2196F3),
                        onChanged: (val) {
                          setModalState(() => tempOrganic = val ?? false);
                        },
                      ),

                      // Negotiable Only
                      CheckboxListTile(
                        title: const Text('Negotiable Prices Only'),
                        value: tempNegotiable,
                        activeColor: const Color(0xFF2196F3),
                        onChanged: (val) {
                          setModalState(() => tempNegotiable = val ?? false);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = null;
                                  _priceRange = const RangeValues(0, 10000);
                                  _organicOnly = false;
                                  _negotiableOnly = false;
                                });
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2196F3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Color(0xFF2196F3)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = tempCategory;
                                  _priceRange = tempPriceRange;
                                  _organicOnly = tempOrganic;
                                  _negotiableOnly = tempNegotiable;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
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
      },
    );
  }

  Widget _buildCategoryChip(
    String category,
    String? selected,
    Function(String?) onSelect,
  ) {
    final isSelected = selected == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (val) {
        onSelect(val ? category : null);
      },
      selectedColor: const Color(0xFF2196F3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ============== Bottom Navigation ==============
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
              Stack(
                children: [
                  _buildNavItem(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Cart',
                    active: false,
                    onTap: _showCart,
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF2196F3) : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? const Color(0xFF2196F3) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
