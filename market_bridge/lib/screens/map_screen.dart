import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a marker at New Delhi
    final Set<Marker> markers = {
      const Marker(
        markerId: MarkerId("delhi"),
        position: LatLng(28.6139, 77.2090),
        infoWindow: InfoWindow(title: "Marker in Delhi"),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Google Map")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.6139, 77.2090), // New Delhi
          zoom: 12,
        ),
        markers: markers,
      ),
    );
  }
}