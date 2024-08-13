// location_utils.dart

import 'package:location/location.dart' as l;
import 'dart:async';

class LocationService {
  final l.Location _location = l.Location();

  Future<bool> isGpsEnabled() async {
    return await _location.serviceEnabled();
  }

  Future<bool> requestEnableGps() async {
    return await _location.requestService();
  }

  Future<bool> isPermissionGranted() async {
    return await _location.hasPermission() == l.PermissionStatus.granted;
  }

  Future<l.PermissionStatus> requestLocationPermission() async {
    return await _location.requestPermission();
  }

  StreamSubscription<l.LocationData> startTracking(
      Function(l.LocationData) onLocation) {
    return _location.onLocationChanged.listen(onLocation);
  }
}
