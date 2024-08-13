import 'package:flutter/material.dart';
import '../managers/location_manager.dart';
import '../managers/accelerometer_manager.dart';
import '../utils/permission_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationManager _locationManager = LocationManager();
  final AccelerometerManager _accelerometerManager = AccelerometerManager();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializeAccelerometer();
  }

  @override
  void dispose() {
    _locationManager.stopTracking();
    _accelerometerManager.stopTracking();
    super.dispose();
  }

  void _initializeLocation() async {
    _locationManager.gpsEnabled = await PermissionUtils.isGpsEnabled();
    _locationManager.permissionGranted =
        await PermissionUtils.isLocationPermissionGranted();

    setState(() {});

    if (_locationManager.gpsEnabled && _locationManager.permissionGranted) {
      _locationManager.startTracking((locationData) {
        setState(() {});
      });
    }
  }

  void _initializeAccelerometer() {
    _accelerometerManager.startTracking((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Accelerometer App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UIUtils.buildListTile(
              "GPS",
              _locationManager.gpsEnabled
                  ? const Text("Okey")
                  : ElevatedButton(
                      onPressed: _locationManager.requestEnableGps,
                      child: const Text("Enable GPS")),
            ),
            UIUtils.buildListTile(
              "Permission",
              _locationManager.permissionGranted
                  ? const Text("Okey")
                  : ElevatedButton(
                      onPressed: () async {
                        _locationManager.permissionGranted =
                            await PermissionUtils.requestLocationPermission();
                        setState(() {});
                      },
                      child: const Text("Request Permission")),
            ),
            UIUtils.buildListTile(
              "Location",
              _locationManager.trackingEnabled
                  ? ElevatedButton(
                      onPressed: _locationManager.stopTracking,
                      child: const Text("Stop"))
                  : ElevatedButton(
                      onPressed: _locationManager.gpsEnabled &&
                              _locationManager.permissionGranted
                          ? () {
                              _locationManager.startTracking((locationData) {
                                setState(() {});
                              });
                            }
                          : null,
                      child: const Text("Start")),
            ),
            const SizedBox(height: 20),
            const Text(
              'Accelerometer Data:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            if (_accelerometerManager.accelerometerValues.isNotEmpty)
              Text(
                'X: ${_accelerometerManager.accelerometerValues[0].x.toStringAsFixed(2)}, '
                'Y: ${_accelerometerManager.accelerometerValues[0].y.toStringAsFixed(2)}, '
                'Z: ${_accelerometerManager.accelerometerValues[0].z.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              )
            else
              const Text('No data available', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text(
              'Location Data:',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _locationManager.locations.length,
                itemBuilder: (context, index) {
                  final location = _locationManager.locations[index];
                  return ListTile(
                    title: Text(
                        "Lat: ${location.latitude}, Lng: ${location.longitude}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UIUtils {
  static ListTile buildListTile(String title, Widget? trailing) {
    return ListTile(
      dense: true,
      title: Text(title),
      trailing: trailing,
    );
  }
}
