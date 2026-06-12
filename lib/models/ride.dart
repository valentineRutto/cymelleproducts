import 'package:latlong2/latlong.dart';
enum TripStatus {
  driverEnRoute,
  driverArrived,
  inTrip,
  completed,
}
extension TripStatusExtension on TripStatus {
 String get label => switch (this) {
        TripStatus.driverEnRoute => '🚗  Driver en route',
        TripStatus.driverArrived => '📍  Driver arrived',
        TripStatus.inTrip => '🛣️  In trip',
        TripStatus.completed => '✅  Trip completed',
      };

  String get sublabel => switch (this) {
        TripStatus.driverEnRoute => 'Your driver is on the way',
        TripStatus.driverArrived => 'Please head to the pickup point',
        TripStatus.inTrip => 'Enjoy your ride!',
        TripStatus.completed => 'Thanks for riding with us',
      };
}
class Driver {
  final String name;
  final String plate;
  final double rating;
  final String vehicle;

  const Driver({
    required this.name,
    required this.plate,
    required this.rating,
    required this.vehicle,
  });
}

final List<LatLng> mockRoute = [
  LatLng(-1.2841, 36.8155),
  LatLng(-1.2820, 36.8170),
  LatLng(-1.2800, 36.8190),
  LatLng(-1.2775, 36.8210),
  LatLng(-1.2750, 36.8230),
  LatLng(-1.2720, 36.8250),
  LatLng(-1.2695, 36.8270),
  LatLng(-1.2668, 36.8285),
  LatLng(-1.2645, 36.8295),
  LatLng(-1.2617, 36.8300), 
];