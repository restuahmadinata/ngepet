import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPickerView extends StatefulWidget {
  final GeoPoint? initialLocation;

  const LocationPickerView({super.key, this.initialLocation});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  late MapController _mapController;
  LatLng _selectedLocation = const LatLng(-6.2088, 106.8456); // Default: Jakarta
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error',
          'Location services are disabled. Please enable location.',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Location permission denied',
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      _mapController.move(_selectedLocation, 15.0);
    } catch (e) {
      print('Error getting location: $e');
      Get.snackbar(
        'Error',
        'Failed to get current location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => _isLoading = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    final geoPoint = GeoPoint(
      _selectedLocation.latitude,
      _selectedLocation.longitude,
    );
    Get.back(result: geoPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmLocation,
            tooltip: 'Confirm Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ngepet',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Info card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Location:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap on the map to choose location',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location, size: 18),
                            label: const Text('My Location'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _confirmLocation,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Confirm'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
