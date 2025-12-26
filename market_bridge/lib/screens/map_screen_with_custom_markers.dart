// lib/screens/map_screen_with_custom_markers.dart
// OPTIONAL ENHANCEMENT: Shows how to add custom marker icons

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreenWithCustomMarkers extends StatefulWidget {
  const MapScreenWithCustomMarkers({super.key});

  @override
  State<MapScreenWithCustomMarkers> createState() => _MapScreenWithCustomMarkersState();
}

class _MapScreenWithCustomMarkersState extends State<MapScreenWithCustomMarkers> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customMarkerIcon;

  static const LatLng _defaultLocation = LatLng(13.6288, 79.4192);

  // Sample farmer locations near Tirupati
  final List<Map<String, dynamic>> _farmerLocations = [
    {
      'name': 'Farmer Market - North',
      'lat': 13.6488,
      'lng': 79.4192,
      'produce': 'Tomatoes, Onions',
    },
    {
      'name': 'Farmer Market - South',
      'lat': 13.6088,
      'lng': 79.4292,
      'produce': 'Wheat, Rice',
    },
    {
      'name': 'Organic Farm',
      'lat': 13.6288,
      'lng': 79.4392,
      'produce': 'Vegetables',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // Load custom marker icon
    await _loadCustomMarkerIcon();

    // Get user location
    final hasPermission = await _handleLocationPermission();
    if (hasPermission) {
      await _getCurrentLocation();
    } else {
      setState(() {
        _isLoading = false;
      });
      _addFarmerMarkers();
    }
  }

  /// Load custom marker icon from assets
  /// LESSON REFERENCE: Step 7 in documentation
  Future<void> _loadCustomMarkerIcon() async {
    try {
      // Create custom marker from asset
      // First, add a location_pin.png to assets/ folder
      _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/tomato.png', // Using existing asset
      );
      debugPrint('✅ Custom marker icon loaded');
    } catch (e) {
      debugPrint('⚠️ Failed to load custom marker icon: $e');
      // Will use default marker if custom icon fails
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions permanently denied');
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _addUserLocationMarker(position);
      _addFarmerMarkers();
      _moveCameraToPosition(LatLng(position.latitude, position.longitude));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _addFarmerMarkers();
    }
  }

  void _addUserLocationMarker(Position position) {
    final marker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(
        title: '📍 You are here',
        snippet: 'Your current location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  /// Add markers for farmer locations with custom icons
  void _addFarmerMarkers() {
    for (int i = 0; i < _farmerLocations.length; i++) {
      final location = _farmerLocations[i];

      final marker = Marker(
        markerId: MarkerId('farmer_$i'),
        position: LatLng(location['lat'], location['lng']),
        infoWindow: InfoWindow(
          title: '🧺 ${location['name']}',
          snippet: location['produce'],
        ),
        // Use custom icon if loaded, otherwise use default red marker
        icon: _customMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => _onMarkerTapped(location),
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  void _onMarkerTapped(Map<String, dynamic> location) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11823F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Color(0xFF11823F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Available: ${location['produce']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${location['lat']}, ${location['lng']}'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _moveCameraToPosition(
                        LatLng(location['lat'], location['lng']),
                      );
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11823F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackBar('Contact feature coming soon!');
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF11823F),
                      side: const BorderSide(color: Color(0xFF11823F)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11823F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Farmer Locations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers, color: Colors.white),
            onPressed: () {
              // Toggle map type
              _showSnackBar('Map type toggle coming soon');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultLocation,
              zoom: 13,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFF11823F),
                    ),
                  ),
                ),
              ),
            ),

          // Farmer count badge
          if (!_isLoading)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.agriculture,
                        color: Color(0xFF11823F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_farmerLocations.length} Farmers Nearby',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF11823F),
        onPressed: () {
          _moveCameraToPosition(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          );
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      )
          : null,
    );
  }
}