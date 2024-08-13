import 'dart:async';
import 'package:location/location.dart' as l;

class LocationManager {
  final l.Location _location = l.Location();
  late StreamSubscription<l.LocationData> _locationSubscription;

  bool gpsEnabled = false;
  bool permissionGranted = false;
  bool trackingEnabled = false;
  List<l.LocationData> locations = [];

  Future<void> requestEnableGps() async {
    if (!gpsEnabled) {
      gpsEnabled = await _location.requestService();
    }
  }

  Future<void> startTracking(
      void Function(l.LocationData) onLocationUpdate) async {
    if (gpsEnabled && permissionGranted) {
      _locationSubscription =
          _location.onLocationChanged.listen((locationData) {
        locations.insert(0, locationData);
        onLocationUpdate(locationData);
      });
      trackingEnabled = true;
    }
  }

  void stopTracking() {
    if (trackingEnabled) {
      _locationSubscription.cancel();
      trackingEnabled = false;
      locations.clear();
    }
  }

  Future<bool> isGpsEnabled() async {
    return await _location.serviceEnabled();
  }

  Future<bool> isPermissionGranted() async {
    return await _location.hasPermission() == l.PermissionStatus.granted;
  }

  Future<void> requestPermission() async {
    permissionGranted =
        await _location.requestPermission() == l.PermissionStatus.granted;
  }
}
