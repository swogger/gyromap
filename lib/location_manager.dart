// location_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as l;
import 'utils/location_utils.dart';
import 'utils/permission_utils.dart';

class LocationManager {
  final LocationService _locationService = LocationService();
  final PermissionService _permissionService = PermissionService();

  bool gpsEnabled = false;
  bool permissionGranted = false;
  bool trackingEnabled = false;
  late StreamSubscription<l.LocationData> subscription;
  List<l.LocationData> locations = [];

  Future<void> checkStatus(Function(bool, bool) onStatusChecked) async {
    gpsEnabled = await _permissionService.isGpsEnabled();
    permissionGranted = await _permissionService.isPermissionGranted();
    onStatusChecked(gpsEnabled, permissionGranted);
  }

  Future<void> requestEnableGps(Function(bool) onGpsStatusChanged) async {
    if (!gpsEnabled) {
      gpsEnabled = await _locationService.requestEnableGps();
      onGpsStatusChanged(gpsEnabled);
    }
  }

  Future<void> requestLocationPermission(
      Function(bool) onPermissionChanged) async {
    final status = await _locationService.requestLocationPermission();
    permissionGranted = status == l.PermissionStatus.granted;
    onPermissionChanged(permissionGranted);
  }

  void startTracking(Function(l.LocationData) onLocation) async {
    if (!gpsEnabled || !permissionGranted) return;

    subscription = _locationService.startTracking(onLocation);
    trackingEnabled = true;
  }

  void stopTracking(Function() onTrackingStopped) {
    if (subscription != null) {
      subscription.cancel();
    }
    trackingEnabled = false;
    onTrackingStopped();
  }

  void addLocation(l.LocationData data) {
    locations.insert(0, data);
  }

  void clearLocation() {
    locations.clear();
  }
}
