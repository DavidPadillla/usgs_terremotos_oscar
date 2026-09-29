import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/terremoto.dart';
import '../../logic/providers/earthquake_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'earthquake_detail_screen.dart';

class EarthquakeMapScreen extends StatefulWidget {
  const EarthquakeMapScreen({super.key});

  @override
  State<EarthquakeMapScreen> createState() => _EarthquakeMapScreenState();
}

class _EarthquakeMapScreenState extends State<EarthquakeMapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _centroInicial = LatLng(0, -60);

  void _zoom(double delta) {
    final zoomActual = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, zoomActual + delta);
  }

  void _centrar() {
    _mapController.move(_centroInicial, AppConstants.defaultMapZoom);
  }

  void _mostrarTarjeta(Terremoto terremoto) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      AppColors.colorForMagnitude(terremoto.magnitud)
                          .withValues(alpha: 0.15),
                  child: Text(
                    terremoto.magnitud.toStringAsFixed(1),
                    style: TextStyle(
                      color: AppColors.colorForMagnitude(terremoto.magnitud),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    terremoto.lugar,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context
                      .read<EarthquakeProvider>()
                      .seleccionarTerremoto(terremoto);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          EarthquakeDetailScreen(terremoto: terremoto),
                    ),
                  );
                },
                child: const Text('Ver detalle completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de sismos')),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          if (provider.status == EarthquakeStatus.cargando ||
              provider.status == EarthquakeStatus.inicial) {
            return const LoadingView();
          }
          if (provider.status == EarthquakeStatus.error) {
            return ErrorView(
              mensaje: provider.errorMessage,
              onRetry: provider.cargarTerremotos,
            );
          }

          final marcadores = provider.terremotos.map((t) {
            return Marker(
              point: LatLng(t.latitud, t.longitud),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _mostrarTarjeta(t),
                child: Icon(
                  Icons.location_on,
                  size: 34,
                  color: AppColors.colorForMagnitude(t.magnitud),
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _centroInicial,
                  initialZoom: AppConstants.defaultMapZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: AppConstants.osmTileUrlTemplate,
                    userAgentPackageName: AppConstants.osmUserAgentPackageName,
                  ),
                  MarkerLayer(markers: marcadores),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 24,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoomIn',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      onPressed: () => _zoom(1),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoomOut',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      onPressed: () => _zoom(-1),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'centrar',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      onPressed: _centrar,
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
