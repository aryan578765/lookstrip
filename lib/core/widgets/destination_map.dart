import 'package:flutter/material.dart';
import 'package:lookstrip/core/services/app_config.dart';
import 'package:lookstrip/core/services/geocoding_service.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Interactive Mapbox map widget for destinations.
class DestinationMapWidget extends StatefulWidget {
  final String destinationName;
  final double? latitude;
  final double? longitude;
  final double zoom;
  final double height;
  final bool interactive;

  const DestinationMapWidget({
    super.key,
    required this.destinationName,
    this.latitude,
    this.longitude,
    this.zoom = 10.0,
    this.height = 200,
    this.interactive = true,
  });

  @override
  State<DestinationMapWidget> createState() => _DestinationMapWidgetState();
}

class _DestinationMapWidgetState extends State<DestinationMapWidget> {
  late Future<(double, double)?> _coordsFuture;

  @override
  void initState() {
    super.initState();
    _coordsFuture = _resolveCoords();
  }

  @override
  void didUpdateWidget(covariant DestinationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationName != widget.destinationName ||
        oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _coordsFuture = _resolveCoords();
    }
  }

  Future<(double, double)?> _resolveCoords() async {
    if (widget.latitude != null && widget.longitude != null) {
      return (widget.latitude!, widget.longitude!);
    }
    return GeocodingService.instance.resolve(widget.destinationName);
  }

  void _onMapCreated(MapboxMap map, (double, double) coords) {
    map.annotations.createPointAnnotationManager().then((manager) {
      manager.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(coords.$2, coords.$1)),
          iconSize: 1.5,
          textField: widget.destinationName,
          textOffset: [0, 1.5],
          textColor: Colors.white.toARGB32(),
          textHaloColor: Colors.black.toARGB32(),
          textHaloWidth: 1.0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasMapboxConfig) {
      return _UnavailableMap(
        height: widget.height,
        message: 'Mapbox is not configured',
      );
    }

    return FutureBuilder<(double, double)?>(
      future: _coordsFuture,
      builder: (context, snapshot) {
        final coords = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: widget.height,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (coords == null) {
          return _UnavailableMap(
            height: widget.height,
            message: 'Map unavailable for ${widget.destinationName}',
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          child: SizedBox(
            height: widget.height,
            child: MapWidget(
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(coords.$2, coords.$1)),
                zoom: widget.zoom,
              ),
              styleUri: MapboxStyles.DARK,
              onMapCreated: (map) => _onMapCreated(map, coords),
            ),
          ),
        );
      },
    );
  }
}

class _UnavailableMap extends StatelessWidget {
  final double height;
  final String message;

  const _UnavailableMap({required this.height, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              color: AppColors.onSurfaceMuted,
              size: 32,
            ),
            const SizedBox(height: AppShapes.spaceXs),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}
