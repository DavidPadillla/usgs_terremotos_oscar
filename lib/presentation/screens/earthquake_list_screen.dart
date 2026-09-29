import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../logic/providers/earthquake_provider.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'earthquake_detail_screen.dart';

class EarthquakeListScreen extends StatefulWidget {
  const EarthquakeListScreen({super.key});

  @override
  State<EarthquakeListScreen> createState() => _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends State<EarthquakeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarthquakeProvider>().cargarTerremotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USGS · Terremotos'),
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          switch (provider.status) {
            case EarthquakeStatus.inicial:
            case EarthquakeStatus.cargando:
              return const LoadingView();

            case EarthquakeStatus.error:
              return ErrorView(
                mensaje: provider.errorMessage,
                onRetry: provider.cargarTerremotos,
              );

            case EarthquakeStatus.cargado:
              if (!provider.tieneDatos) {
                return const Center(
                  child: Text('No se encontraron sismos en el rango consultado.'),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: provider.cargarTerremotos,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: provider.terremotos.length,
                  itemBuilder: (context, index) {
                    final terremoto = provider.terremotos[index];
                    return EarthquakeCard(
                      terremoto: terremoto,
                      onTap: () {
                        provider.seleccionarTerremoto(terremoto);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EarthquakeDetailScreen(terremoto: terremoto),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
