import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';  
import 'package:latlong2/latlong.dart';
import 'package:cymelleproducts/providers/ride_provider.dart';
import 'package:cymelleproducts/models/ride.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().startRide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(ride.driverPosition, 15.0);
          });

          return Stack(
            children: [
              // ── Full-screen map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: ride.driverPosition,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  // OSM tile layer (no API key needed)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.shopapp',
                  ),

                  // Route polyline
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mockRoute,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        strokeWidth: 4,
                      ),
                    ],
                  ),

                  // Driver marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: ride.driverPosition,
                        width: 48,
                        height: 48,
                        child: _DriverMarker(status: ride.status),
                      ),
                      // Destination pin
                      Marker(
                        point: mockRoute.last,
                        width: 36,
                        height: 36,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _TripStatusBar(status: ride.status),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: _DriverCard(ride: ride),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Driver marker on map 
class _DriverMarker extends StatelessWidget {
  final TripStatus status;
  const _DriverMarker({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == TripStatus.inTrip
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.directions_car, color: Colors.white, size: 22),
    );
  }
}

// ── Trip status bar
class _TripStatusBar extends StatelessWidget {
  final TripStatus status;
  const _TripStatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCompleted = status == TripStatus.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted ? colors.primaryContainer : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isCompleted
                  ? colors.onPrimaryContainer
                  : colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status.sublabel,
            style: TextStyle(
              fontSize: 11,
              color: isCompleted
                  ? colors.onPrimaryContainer.withOpacity(0.7)
                  : colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom driver info card 
class _DriverCard extends StatelessWidget {
  final RideProvider ride;
  const _DriverCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final driver = ride.driver;
    final isCompleted = ride.isCompleted;

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              // Driver avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  driver.name.split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Driver details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.vehicle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Plate badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Text(
                            driver.plate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          driver.rating.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Call / message icons
              if (!isCompleted) ...[
                _ActionButton(icon: Icons.message_outlined, onTap: () {}),
                const SizedBox(width: 8),
                _ActionButton(icon: Icons.call_outlined, onTap: () {}),
              ],
            ],
          ),

          if (isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ride.reset(),
                child: const Text('Book again'),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            _ProgressStepper(status: ride.status),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

// ── Step progress indicator
class _ProgressStepper extends StatelessWidget {
  final TripStatus status;
  const _ProgressStepper({required this.status});

  static const _steps = [
    TripStatus.driverEnRoute,
    TripStatus.driverArrived,
    TripStatus.inTrip,
    TripStatus.completed,
  ];

  static const _labels = ['En route', 'Arrived', 'In trip', 'Done'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentIndex = _steps.indexOf(status);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          final active = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: active ? colors.primary : colors.outlineVariant,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex < currentIndex;
        final current = stepIndex == currentIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || current ? colors.primary : colors.outlineVariant,
                border: Border.all(
                  color: current ? colors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : current
                      ? const Icon(Icons.circle, size: 8, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 4),
            Text(
              _labels[stepIndex],
              style: TextStyle(
                fontSize: 9,
                color: done || current
                    ? colors.primary
                    : colors.onSurface.withOpacity(0.4),
                fontWeight:
                    current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}