import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../managers/location_manager.dart';
import 'package:location/location.dart' as location_package;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationManager _locationManager = LocationManager();
  final List<LatLng> _pathPoints = [];
  final MapController _mapController = MapController();
  bool _mapCentered = false; // Flag to indicate if the map has been centered
  bool _isGpsEnabled = false; // Tracks the current GPS status
  Timer? _gpsStatusCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
    _startGpsStatusCheckTimer();
  }

  Future<void> _initializeLocationTracking() async {
    await _checkAndRequestPermissions();

    if (_isGpsEnabled && _locationManager.permissionGranted) {
      _locationManager.startTracking(_onLocationUpdate);
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    _isGpsEnabled = await _locationManager.isGpsEnabled();
    _locationManager.permissionGranted =
        await _locationManager.isPermissionGranted();

    if (!_isGpsEnabled) {
      await _locationManager.requestEnableGps();
      _isGpsEnabled = await _locationManager.isGpsEnabled();
    }

    if (!_locationManager.permissionGranted) {
      await _locationManager.requestPermission();
      _locationManager.permissionGranted =
          await _locationManager.isPermissionGranted();
    }

    setState(() {}); // Update UI based on GPS and permission status
  }

  void _onLocationUpdate(location_package.LocationData locationData) {
    final newPoint = LatLng(
      locationData.latitude ?? 0.0,
      locationData.longitude ?? 0.0,
    );

    setState(() {
      _pathPoints.insert(0, newPoint);
    });

    if (!_mapCentered) {
      _centerMapOnLocation(newPoint);
      _mapCentered = true;
    }
  }

  void _centerMapOnLocation(LatLng location) {
    _mapController.move(
        location, 18.0); // Center the map and set a comfortable zoom level
  }

  void _startGpsStatusCheckTimer() {
    _gpsStatusCheckTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      bool gpsEnabled = await _locationManager.isGpsEnabled();
      if (gpsEnabled != _isGpsEnabled) {
        setState(() {
          _isGpsEnabled = gpsEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationManager.stopTracking();
    _gpsStatusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Updates:'),
            Text(_pathPoints.length.toString()),
            const Spacer(),
            const Text('GPS:'),
            Icon(
              _isGpsEnabled && _locationManager.trackingEnabled
                  ? Icons.gps_fixed
                  : Icons.gps_off,
            ),
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
