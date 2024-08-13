import 'package:flutter/material.dart';
import '../location_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationManager _locationManager = LocationManager();

  @override
  void initState() {
    super.initState();
    _locationManager.checkStatus((gpsEnabled, permissionGranted) {
      setState(() {
        _locationManager.gpsEnabled = gpsEnabled;
        _locationManager.permissionGranted = permissionGranted;
      });
    });
  }

  @override
  void dispose() {
    _locationManager.stopTracking(() {
      setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildListTile(
              "GPS",
              _locationManager.gpsEnabled
                  ? const Text("Okey")
                  : ElevatedButton(
                      onPressed: () =>
                          _locationManager.requestEnableGps((gpsEnabled) {
                        setState(() {
                          _locationManager.gpsEnabled = gpsEnabled;
                        });
                      }),
                      child: const Text("Enable Gps"),
                    ),
            ),
            buildListTile(
              "Permission",
              _locationManager.permissionGranted
                  ? const Text("Okey")
                  : ElevatedButton(
                      onPressed: () => _locationManager
                          .requestLocationPermission((permissionGranted) {
                        setState(() {
                          _locationManager.permissionGranted =
                              permissionGranted;
                        });
                      }),
                      child: const Text("Request Permission"),
                    ),
            ),
            buildListTile(
              "Location",
              _locationManager.trackingEnabled
                  ? ElevatedButton(
                      onPressed: () => _locationManager.stopTracking(() {
                        setState(() {});
                      }),
                      child: const Text("Stop"),
                    )
                  : ElevatedButton(
                      onPressed: _locationManager.gpsEnabled &&
                              _locationManager.permissionGranted
                          ? () {
                              _locationManager.startTracking((locationData) {
                                setState(() {
                                  _locationManager.addLocation(locationData);
                                });
                              });
                            }
                          : null,
                      child: const Text("Start"),
                    ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _locationManager.locations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        "${_locationManager.locations[index].latitude} ${_locationManager.locations[index].longitude}"),
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

ListTile buildListTile(String title, Widget? trailing) {
  return ListTile(
    dense: true,
    title: Text(title),
    trailing: trailing,
  );
}
