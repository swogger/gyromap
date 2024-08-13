import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../managers/location_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationManager _locationManager = LocationManager();
  final List<LatLng> _pathPoints = [];
  final MapController _mapController = MapController();
  bool _mapCentered = false; // Flag to check if the map has been centered

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  Future<void> _initializeLocationTracking() async {
    // Check and request GPS and permission status
    _locationManager.permissionGranted =
        await _locationManager.isPermissionGranted();

    await _locationManager.requestEnableGps();
    await _locationManager.isGpsEnabled();

    await _locationManager.requestPermission();

    // Update UI based on GPS and permission status
    setState(() {});

    // Start tracking if both GPS and permission are granted

    _locationManager.startTracking((locationData) {
      final newPoint =
          LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);

      setState(() {
        _pathPoints.insert(0, newPoint);
      });

      // Center the map on the first location update
      if (!_mapCentered) {
        _mapController.move(
            newPoint, 18.0); // Center and zoom to a comfortable level
        _mapCentered = true; // Prevent further automatic centering
      }
    });
  }

  @override
  void dispose() {
    _locationManager.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('GPS:'),
            Icon(
              _locationManager.trackingEnabled
                  ? Icons.gps_fixed
                  : Icons.gps_off,
            ),
            Text(_pathPoints.length.toString()),
            const Spacer(),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: _mapController, // Assign the map controller
        options: MapOptions(
          center: LatLng(51.509364, -0.128928), // Initial center of the map
          zoom: 2.0, // Initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _pathPoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
