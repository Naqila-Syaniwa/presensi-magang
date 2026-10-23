import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 
class MapTestScreen extends StatelessWidget {
  const MapTestScreen({super.key});
 
  static const LatLng _kantor = LatLng(-6.20887304652298, 106.799595943019);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Peta')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: _kantor, zoom: 16),
        markers: {
          const Marker(markerId: MarkerId('kantor'), position: _kantor),
        },
      ),
    );
  }
}
 