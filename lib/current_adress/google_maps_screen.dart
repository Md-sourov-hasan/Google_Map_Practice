import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  static const CameraPosition _fallbackCameraPosition = CameraPosition(
    target: LatLng(23.8242, 90.4136),
    zoom: 14.4746,
  );

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String _locationText = 'Fetching your current location...';
  bool _isFetchingLocation = true;
  bool _hasLocationPermission = false;
  bool _mapInitialized = false; // ← Prevent repeated API calls
  bool _isLoadingLocation = false; // ← Prevent concurrent requests

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _moveCameraToCurrentLocation() async {
    final currentLatLng = _currentLatLng;
    final mapController = _mapController;

    if (currentLatLng == null || mapController == null) {
      return;
    }

    await mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng, 16),
    );
  }

  Future<void> _loadCurrentLocation() async {
    // Prevent concurrent requests (API spam)
    if (_isLoadingLocation) {
      debugPrint('⚠️ Location already loading, skipping duplicate request');
      return;
    }

    _isLoadingLocation = true;

    if (mounted) {
      setState(() {
        _isFetchingLocation = true;
        _locationText = 'Fetching your current location...';
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError('Location service is turned off.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setLocationError('Location permission was denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationError(
          'Location permission is permanently denied. Please enable it from settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);
      final locationText =
          'Lat: ${position.latitude.toStringAsFixed(6)}\n'
          'Lng: ${position.longitude.toStringAsFixed(6)}';

      debugPrint('✅ Current location fetched -> $locationText');

      if (!mounted) {
        return;
      }

      setState(() {
        _currentLatLng = currentLatLng;
        _locationText = locationText;
        _isFetchingLocation = false;
        _hasLocationPermission = true;
      });

      await _moveCameraToCurrentLocation();
    } catch (error) {
      _setLocationError('Unable to fetch location: $error');
    } finally {
      _isLoadingLocation = false; // ← Allow next request after this one completes
    }
  }

  void _setLocationError(String message) {
    debugPrint(message);

    if (!mounted) {
      return;
    }

    setState(() {
      _locationText = message;
      _isFetchingLocation = false;
      _hasLocationPermission = false;
    });
  }

  Set<Marker> _buildMarkers() {
    if (_currentLatLng == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLatLng!,
        infoWindow: const InfoWindow(title: 'My current location'),
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text('Current address'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _fallbackCameraPosition,
            markers: _buildMarkers(),
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: _hasLocationPermission,
            onMapCreated: (controller) async {
              // Only initialize once to prevent repeated API calls
              if (_mapInitialized) {
                debugPrint('⚠️ Map already initialized, skipping');
                return;
              }
              
              _mapInitialized = true;
              _mapController = controller;
              debugPrint('✅ Map initialized');
              
              await _moveCameraToCurrentLocation();
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isFetchingLocation)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      const Icon(Icons.my_location, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCurrentLocation,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
