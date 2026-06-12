import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cymelleproducts/models/ride.dart';

class RideProvider extends ChangeNotifier {
  static const _tickInterval = Duration(seconds: 2);

  final driver = const Driver(
    name: 'John Kamau',
    plate: 'KAA 123A',
    rating: 4.8,
    vehicle: 'Toyota Prius',
  );

  int _routeIndex = 0;
  TripStatus _status = TripStatus.driverEnRoute;
  Timer? _timer;
  bool _started = false;

  LatLng get driverPosition => mockRoute[_routeIndex];
  TripStatus get status => _status;
  bool get isCompleted => _status == TripStatus.completed;

  LatLng get focusPoint => mockRoute[_routeIndex];

  void startRide() {
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _tick() {
    if (_routeIndex < mockRoute.length - 1) {
      _routeIndex++;
    }

    final progress = _routeIndex / (mockRoute.length - 1);

    if (progress < 0.30) {
      _status = TripStatus.driverEnRoute;
    } else if (progress < 0.40) {
      _status = TripStatus.driverArrived;
    } else if (progress < 1.0) {
      _status = TripStatus.inTrip;
    } else {
      _status = TripStatus.completed;
      _timer?.cancel();
    }
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _routeIndex = 0;
    _status = TripStatus.driverEnRoute;
    _started = false;
    notifyListeners();
    startRide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
