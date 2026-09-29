import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/terremoto.dart';
import '../../logic/utils/date_formatter.dart';
import '../widgets/magnitude_badge.dart';

class EarthquakeDetailScreen extends StatefulWidget {
  final Terremoto terremoto;

  const EarthquakeDetailScreen({super.key, required this.terremoto});

  @override
  State<EarthquakeDetailScreen> createState() =>
      _EarthquakeDetailScreenState();
}

class _EarthquakeDetailScreenState extends State<EarthquakeDetailScreen> {
  final MapController _mapController = MapController();

  Terremoto get terremoto => widget.terremoto;

  void _zoom(double delta) {
    final zoomActual = _mapController.camera.zoom;
    final nuevoZoom = (zoomActual + delta).clamp(2.0, 18.0);
    _mapController.move(_mapController.camera.center, nuevoZoom);
  }

  void _recentrar() {
    final punto = LatLng(terremoto.latitud, terremoto.longitud);
    _mapController.move(punto, AppConstants.detailMapZoom);
  }

  Widget _fila(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(etiqueta,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _botonMapa({required IconData icono, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icono, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final punto = LatLng(terremoto.latitud, terremoto.longitud);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del sismo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MagnitudeBadge(magnitud: terremoto.magnitud, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terremoto.lugar,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatterUtil.fechaHora(terremoto.fecha),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      DateFormatterUtil.tiempoTranscurrido(terremoto.fecha),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _fila(Icons.place_outlined, 'Ubicacion',
                      '${terremoto.latitud.toStringAsFixed(3)}, ${terremoto.longitud.toStringAsFixed(3)}'),
                  const Divider(height: 1),
                  _fila(Icons.vertical_align_bottom, 'Profundidad',
                      '${terremoto.profundidad.toStringAsFixed(1)} km'),
                  const Divider(height: 1),
                  _fila(Icons.bolt_outlined, 'Tipo', terremoto.tipo),
                  const Divider(height: 1),
                  _fila(Icons.fact_check_outlined, 'Revision',
                      terremoto.revisiones),
                  const Divider(height: 1),
                  _fila(Icons.satellite_alt_outlined, 'Fuente',
                      terremoto.fuente.toUpperCase()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mapa · Ubicacion',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 240,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: punto,
                      initialZoom: AppConstants.detailMapZoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.drag |
                            InteractiveFlag.doubleTapZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConstants.osmTileUrlTemplate,
                        userAgentPackageName:
                            AppConstants.osmUserAgentPackageName,
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: punto,
                          width: 44,
                          height: 44,
                          child: Icon(Icons.location_on,
                              color:
                                  AppColors.colorForMagnitude(terremoto.magnitud),
                              size: 40),
                        ),
                      ]),
                    ],
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _botonMapa(
                          icono: Icons.add,
                          onTap: () => _zoom(1),
                        ),
                        const SizedBox(height: 8),
                        _botonMapa(
                          icono: Icons.remove,
                          onTap: () => _zoom(-1),
                        ),
                        const SizedBox(height: 8),
                        _botonMapa(
                          icono: Icons.my_location,
                          onTap: _recentrar,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (terremoto.url.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(terremoto.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ver ficha oficial en USGS'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
