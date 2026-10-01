import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../data/models/terremoto.dart';
import '../../logic/analytics/earthquake_chart_catalog.dart';
import '../../logic/providers/earthquake_provider.dart';
import '../widgets/charts/earthquake_chart_view.dart';
import '../widgets/charts/chart_texts.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  ChartComplexity? _complexity;
  ChartLibrary? _library;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar datos de USGS',
            onPressed: context.read<EarthquakeProvider>().cargarTerremotos,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                  child: Text(ChartTexts.emptyCatalog),
                );
              }
              return _catalog(provider.terremotos);
          }
        },
      ),
    );
  }

  Widget _catalog(List<Terremoto> earthquakes) {
    final charts = earthquakeChartCatalog.where((chart) {
      return (_complexity == null || chart.complexity == _complexity) &&
          (_library == null || chart.library == _library);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        const Text(
          '96 gráficas con datos de USGS: 64 existentes y 32 nuevas con Community Charts. '
          'Las nuevas incluyen 20 básicas y 12 avanzadas.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _filterChip(
              label: 'Todas',
              selected: _complexity == null,
              onSelected: () => setState(() => _complexity = null),
            ),
            _filterChip(
              label: 'Básicas',
              selected: _complexity == ChartComplexity.basica,
              onSelected: () =>
                  setState(() => _complexity = ChartComplexity.basica),
            ),
            _filterChip(
              label: 'Avanzadas',
              selected: _complexity == ChartComplexity.avanzada,
              onSelected: () =>
                  setState(() => _complexity = ChartComplexity.avanzada),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _filterChip(
              label: 'Todas las librerías',
              selected: _library == null,
              onSelected: () => setState(() => _library = null),
            ),
            for (final library in ChartLibrary.values)
              _filterChip(
                label: library.label,
                selected: _library == library,
                onSelected: () => setState(() => _library = library),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < charts.length; index++)
          TweenAnimationBuilder<double>(
            key: ValueKey(
              '${charts[index].id}-${_complexity?.name}-${_library?.name}',
            ),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 850),
            builder: (context, progress, child) {
              final delay = (index * 0.035).clamp(0.0, 0.72);
              final staggered =
                  ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
              final eased = Curves.easeOutCubic.transform(staggered);
              return Opacity(
                opacity: eased,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - eased)),
                  child: child,
                ),
              );
            },
            child: Card(
              key: ValueKey(charts[index].id),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    '${charts[index].id}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(charts[index].title),
                subtitle: Text(
                  '${charts[index].complexity == ChartComplexity.basica ? 'Básica' : 'Avanzada'}'
                  ' · ${charts[index].library.label}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _ChartDetailScreen(
                      definition: charts[index],
                      earthquakes: earthquakes,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) =>
      FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      );
}

class _ChartDetailScreen extends StatelessWidget {
  const _ChartDetailScreen({
    required this.definition,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gráfica ${definition.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            definition.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            definition.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            definition.complexity == ChartComplexity.basica
                ? 'Básica'
                : 'Avanzada',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          EarthquakeChartView(
            definition: definition,
            earthquakes: earthquakes,
          ),
          const SizedBox(height: 16),
          Text(
            ChartTexts.readingTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${definition.description} ${ChartTexts.readingHint}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Fuente: USGS · ${earthquakes.length} sismos en el conjunto actual.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
