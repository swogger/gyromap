import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerManager {
  List<AccelerometerEvent> accelerometerValues = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  void startTracking(void Function(AccelerometerEvent) onAccelerometerUpdate) {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      accelerometerValues = [event];
      onAccelerometerUpdate(event);
    });
  }

  void stopTracking() {
    _accelerometerSubscription.cancel();
    accelerometerValues.clear();
  }
}
