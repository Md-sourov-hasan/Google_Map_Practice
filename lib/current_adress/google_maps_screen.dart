import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Current adress'),
      ),
      body:
      GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:CameraPosition(target: LatLng(23.8242, 90.4136),zoom: 14.4746)
        ),
    );
  }
}