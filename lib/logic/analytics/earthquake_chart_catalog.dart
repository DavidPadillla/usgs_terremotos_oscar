import '../../data/models/terremoto.dart';

enum ChartLibrary {
  flChart('fl_chart'),
  graphic('Graphic'),
  communityCharts('Community Charts'),
  ;

  const ChartLibrary(this.label);

  final String label;
}

enum ChartComplexity { basica, avanzada }

enum ChartStyle { line, bar, pie, scatter, area, groupedBar, combo }

enum ChartMetric {
  dailyCount,
  magnitudeOverTime,
  magnitudeBands,
  dailyAverageMagnitude,
  magnitudeVsDepth,
  cumulativeCount,
  dailyCountByMagnitude,
  dailyMaximumMagnitude,
  dailyAverageDepth,
  depthBands,
  dailyCountAndAverageMagnitude,
  magnitudeAndDepthByEvent,
  averageMagnitudeByPlace,
  weeklyCountByMagnitude,
  weeklyAverageMagnitude,
  movingAverageMagnitude,
  topPlaces,
  magnitudeByEvent,
  weeklyAverageDepth,
  depthVsMagnitude,
}

class EarthquakeChartDefinition {
  const EarthquakeChartDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.library,
    required this.complexity,
    required this.style,
    required this.metric,
  });

  final int id;
  final String title;
  final String description;
  final ChartLibrary library;
  final ChartComplexity complexity;
  final ChartStyle style;
  final ChartMetric metric;
}

class EarthquakeChartDatum {
  const EarthquakeChartDatum({
    required this.label,
    required this.value,
    this.series = '',
    this.secondaryValue,
    this.xValue,
  });

  final String label;
  final double value;
  final String series;
  final double? secondaryValue;
  final double? xValue;
}

const _chartTemplates = <EarthquakeChartDefinition>[
  EarthquakeChartDefinition(
    id: 1,
    title: 'Sismos por día',
    description: 'Cantidad de eventos registrados en cada fecha.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.dailyCount,
  ),
  EarthquakeChartDefinition(
    id: 2,
    title: 'Magnitud a través del tiempo',
    description: 'Magnitud de cada evento ordenado cronológicamente.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeOverTime,
  ),
  EarthquakeChartDefinition(
    id: 3,
    title: 'Eventos por rango de magnitud',
    description: 'Conteo de sismos agrupados por rangos de magnitud.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.magnitudeBands,
  ),
  EarthquakeChartDefinition(
    id: 4,
    title: 'Proporción por magnitud',
    description: 'Distribución porcentual de eventos por magnitud.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.magnitudeBands,
  ),
  EarthquakeChartDefinition(
    id: 5,
    title: 'Magnitud promedio diaria',
    description: 'Promedio de magnitud de los sismos registrados cada día.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.dailyAverageMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 6,
    title: 'Magnitud frente a profundidad',
    description: 'Cada punto corresponde a un sismo y relaciona sus medidas.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.scatter,
    metric: ChartMetric.magnitudeVsDepth,
  ),
  EarthquakeChartDefinition(
    id: 7,
    title: 'Sismos acumulados',
    description: 'Total acumulado de eventos según su fecha.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.area,
    metric: ChartMetric.cumulativeCount,
  ),
  EarthquakeChartDefinition(
    id: 8,
    title: 'Conteo diario por magnitud',
    description: 'Compara por día el conteo de sismos de cada rango.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.dailyCountByMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 9,
    title: 'Magnitud máxima diaria',
    description: 'Mayor magnitud registrada en cada día.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.dailyMaximumMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 10,
    title: 'Profundidad promedio diaria',
    description: 'Profundidad media de los sismos por día.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.dailyAverageDepth,
  ),
  EarthquakeChartDefinition(
    id: 11,
    title: 'Eventos por rango de profundidad',
    description: 'Distribución de eventos entre rangos de profundidad.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.depthBands,
  ),
  EarthquakeChartDefinition(
    id: 12,
    title: 'Cantidad y magnitud promedio',
    description: 'Barras de cantidad y línea de magnitud media por día.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.combo,
    metric: ChartMetric.dailyCountAndAverageMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 13,
    title: 'Magnitud promedio por lugar',
    description: 'Compara la magnitud media entre las ubicaciones reportadas.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.bar,
    metric: ChartMetric.averageMagnitudeByPlace,
  ),
  EarthquakeChartDefinition(
    id: 14,
    title: 'Conteo semanal por magnitud',
    description: 'Eventos semanales separados en rangos de magnitud.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.weeklyCountByMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 15,
    title: 'Lugares con más sismos',
    description: 'Ubicaciones de USGS ordenadas por número de eventos.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.bar,
    metric: ChartMetric.topPlaces,
  ),
  EarthquakeChartDefinition(
    id: 16,
    title: 'Magnitud y profundidad por evento',
    description: 'Compara las medidas de los eventos en orden cronológico.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.combo,
    metric: ChartMetric.magnitudeAndDepthByEvent,
  ),
  EarthquakeChartDefinition(
    id: 17,
    title: 'Conteo diario',
    description: 'Número de terremotos detectados por día.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.dailyCount,
  ),
  EarthquakeChartDefinition(
    id: 18,
    title: 'Magnitud por evento',
    description: 'Serie cronológica de las magnitudes reportadas.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeByEvent,
  ),
  EarthquakeChartDefinition(
    id: 19,
    title: 'Distribución de magnitudes',
    description: 'Porcentaje de sismos en cada categoría de magnitud.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.magnitudeBands,
  ),
  EarthquakeChartDefinition(
    id: 20,
    title: 'Eventos por profundidad',
    description: 'Cantidad de sismos agrupados por profundidad.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.depthBands,
  ),
  EarthquakeChartDefinition(
    id: 21,
    title: 'Lugares con más eventos',
    description: 'Top de ubicaciones según la descripción entregada por USGS.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.topPlaces,
  ),
  EarthquakeChartDefinition(
    id: 22,
    title: 'Magnitud promedio semanal',
    description: 'Magnitud media de los eventos agrupados por semana.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.weeklyAverageMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 23,
    title: 'Comparación semanal por magnitud',
    description: 'Compara los conteos semanales de cada rango de magnitud.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.weeklyCountByMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 24,
    title: 'Magnitud y promedio móvil',
    description:
        'Contrasta cada magnitud con el promedio móvil de cinco eventos.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.line,
    metric: ChartMetric.movingAverageMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 25,
    title: 'Magnitud cronológica',
    description: 'Muestra la magnitud registrada en cada evento.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeOverTime,
  ),
  EarthquakeChartDefinition(
    id: 26,
    title: 'Sismos por día',
    description: 'Conteo diario de los eventos del conjunto consultado.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.dailyCount,
  ),
  EarthquakeChartDefinition(
    id: 27,
    title: 'Rangos de magnitud',
    description: 'Distribución del total de eventos por rangos de magnitud.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.magnitudeBands,
  ),
  EarthquakeChartDefinition(
    id: 28,
    title: 'Rangos de profundidad',
    description: 'Conteo de eventos en rangos de profundidad.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.depthBands,
  ),
  EarthquakeChartDefinition(
    id: 29,
    title: 'Promedio semanal de profundidad',
    description: 'Profundidad media semanal en kilómetros.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.weeklyAverageDepth,
  ),
  EarthquakeChartDefinition(
    id: 30,
    title: 'Eventos por ubicación',
    description: 'Compara las ubicaciones con mayor número de sismos.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.topPlaces,
  ),
  EarthquakeChartDefinition(
    id: 31,
    title: 'Conteo y promedio por día',
    description: 'Muestra en conjunto el conteo diario y la magnitud media.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.combo,
    metric: ChartMetric.dailyCountAndAverageMagnitude,
  ),
  EarthquakeChartDefinition(
    id: 32,
    title: 'Profundidad según magnitud',
    description: 'Diagrama de puntos que relaciona magnitud y profundidad.',
    library: ChartLibrary.flChart,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.scatter,
    metric: ChartMetric.depthVsMagnitude,
  ),
];

List<EarthquakeChartDefinition> _additionalChartDefinitions() {
  return [
    for (final chart in _chartTemplates)
      EarthquakeChartDefinition(
        id: chart.id + _chartTemplates.length * 2,
        title: chart.title,
        description: chart.description,
        library: ChartLibrary.communityCharts,
        complexity: chart.complexity,
        style: chart.style,
        metric: chart.metric,
      ),
  ];
}

final earthquakeChartCatalog = List<EarthquakeChartDefinition>.unmodifiable([
  ..._chartTemplates,
  for (final chart in _chartTemplates)
    EarthquakeChartDefinition(
      id: chart.id + _chartTemplates.length,
      title: chart.title,
      description: chart.description,
      library: ChartLibrary.graphic,
      complexity: chart.complexity,
      style: chart.style,
      metric: chart.metric,
    ),
  ..._additionalChartDefinitions(),
]);

List<EarthquakeChartDatum> buildChartData(
  ChartMetric metric,
  List<Terremoto> earthquakes,
) {
  final sorted = [...earthquakes]..sort((a, b) => a.fecha.compareTo(b.fecha));

  switch (metric) {
    case ChartMetric.dailyCount:
      return _aggregateByDate(sorted, (events) => events.length.toDouble());
    case ChartMetric.magnitudeOverTime:
    case ChartMetric.magnitudeByEvent:
      return _eventValues(sorted, (event) => event.magnitud);
    case ChartMetric.magnitudeAndDepthByEvent:
      return sorted
          .asMap()
          .entries
          .map(
            (entry) => EarthquakeChartDatum(
              label: _eventLabel(entry.value, entry.key),
              value: entry.value.magnitud,
              secondaryValue: entry.value.profundidad,
            ),
          )
          .toList();
    case ChartMetric.magnitudeBands:
      return _countByBucket(
        sorted,
        (event) => _magnitudeBand(event.magnitud),
        const ['<5', '5–6', '6–7', '7+'],
      );
    case ChartMetric.dailyAverageMagnitude:
      return _aggregateByDate(
        sorted,
        (events) => _average(events, (event) => event.magnitud),
      );
    case ChartMetric.magnitudeVsDepth:
    case ChartMetric.depthVsMagnitude:
      return sorted
          .asMap()
          .entries
          .map(
            (entry) => EarthquakeChartDatum(
              label: entry.value.lugar,
              value: metric == ChartMetric.magnitudeVsDepth
                  ? entry.value.profundidad
                  : entry.value.magnitud,
              xValue: metric == ChartMetric.magnitudeVsDepth
                  ? entry.value.magnitud
                  : entry.value.profundidad,
            ),
          )
          .toList();
    case ChartMetric.cumulativeCount:
      var total = 0;
      return _groupByDate(sorted).entries.map((entry) {
        total += entry.value.length;
        return EarthquakeChartDatum(
          label: entry.key,
          value: total.toDouble(),
        );
      }).toList();
    case ChartMetric.dailyCountByMagnitude:
    case ChartMetric.weeklyCountByMagnitude:
      final groups = <String, Map<String, int>>{};
      for (final event in sorted) {
        final period = metric == ChartMetric.dailyCountByMagnitude
            ? _day(event.fecha)
            : _week(event.fecha);
        final band = _magnitudeBand(event.magnitud);
        groups.putIfAbsent(period, () => {})[band] =
            (groups[period]?[band] ?? 0) + 1;
      }
      return [
        for (final period in groups.entries)
          for (final band in const ['<5', '5–6', '6–7', '7+'])
            EarthquakeChartDatum(
              label: period.key,
              series: band,
              value: (period.value[band] ?? 0).toDouble(),
            ),
      ];

    case ChartMetric.dailyMaximumMagnitude:
      return _aggregateByDate(
        sorted,
        (events) => events.map((event) => event.magnitud).reduce(
            (maximum, magnitude) => magnitude > maximum ? magnitude : maximum),
      );
    case ChartMetric.dailyAverageDepth:
      return _aggregateByDate(
        sorted,
        (events) => _average(events, (event) => event.profundidad),
      );
    case ChartMetric.depthBands:
      return _countByBucket(
        sorted,
        (event) => _depthBand(event.profundidad),
        const ['0–70 km', '70–300 km', '300+ km'],
      );
    case ChartMetric.dailyCountAndAverageMagnitude:
      return _groupByDate(sorted).entries.map((entry) {
        return EarthquakeChartDatum(
          label: entry.key,
          value: entry.value.length.toDouble(),
          secondaryValue: _average(entry.value, (event) => event.magnitud),
        );
      }).toList();
    case ChartMetric.averageMagnitudeByPlace:
      final grouped = _groupByPlace(sorted);
      return grouped.entries
          .map((entry) => EarthquakeChartDatum(
                label: entry.key,
                value: _average(entry.value, (event) => event.magnitud),
              ))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    case ChartMetric.weeklyAverageMagnitude:
      return _aggregateByWeek(
        sorted,
        (events) => _average(events, (event) => event.magnitud),
      );
    case ChartMetric.movingAverageMagnitude:
      return [
        for (var i = 0; i < sorted.length; i++)
          EarthquakeChartDatum(
            label: _eventLabel(sorted[i], i),
            value: sorted[i].magnitud,
            secondaryValue: _average(
              sorted.sublist(i < 4 ? 0 : i - 4, i + 1),
              (event) => event.magnitud,
            ),
          ),
      ];
    case ChartMetric.topPlaces:
      final counts = <String, int>{};
      for (final event in sorted) {
        counts[event.lugar] = (counts[event.lugar] ?? 0) + 1;
      }
      final places = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return places
          .take(8)
          .map((entry) => EarthquakeChartDatum(
                label: entry.key,
                value: entry.value.toDouble(),
              ))
          .toList();
    case ChartMetric.weeklyAverageDepth:
      return _aggregateByWeek(
        sorted,
        (events) => _average(events, (event) => event.profundidad),
      );
  }
}

Map<String, List<Terremoto>> _groupByDate(List<Terremoto> earthquakes) {
  final result = <String, List<Terremoto>>{};
  for (final event in earthquakes) {
    result.putIfAbsent(_day(event.fecha), () => []).add(event);
  }
  return result;
}

Map<String, List<Terremoto>> _groupByPlace(List<Terremoto> earthquakes) {
  final result = <String, List<Terremoto>>{};
  for (final event in earthquakes) {
    result.putIfAbsent(event.lugar, () => []).add(event);
  }
  return result;
}

List<EarthquakeChartDatum> _aggregateByDate(
  List<Terremoto> earthquakes,
  double Function(List<Terremoto>) aggregate,
) =>
    _groupByDate(earthquakes)
        .entries
        .map((entry) => EarthquakeChartDatum(
              label: entry.key,
              value: aggregate(entry.value),
            ))
        .toList();

List<EarthquakeChartDatum> _aggregateByWeek(
  List<Terremoto> earthquakes,
  double Function(List<Terremoto>) aggregate,
) {
  final grouped = <String, List<Terremoto>>{};
  for (final event in earthquakes) {
    grouped.putIfAbsent(_week(event.fecha), () => []).add(event);
  }
  return grouped.entries
      .map((entry) => EarthquakeChartDatum(
            label: entry.key,
            value: aggregate(entry.value),
          ))
      .toList();
}

List<EarthquakeChartDatum> _eventValues(
  List<Terremoto> earthquakes,
  double Function(Terremoto) value,
) =>
    earthquakes
        .asMap()
        .entries
        .map((entry) => EarthquakeChartDatum(
              label: _eventLabel(entry.value, entry.key),
              value: value(entry.value),
            ))
        .toList();

List<EarthquakeChartDatum> _countByBucket(
  List<Terremoto> earthquakes,
  String Function(Terremoto) bucket,
  List<String> labels,
) {
  final counts = {for (final label in labels) label: 0};
  for (final event in earthquakes) {
    final label = bucket(event);
    counts[label] = (counts[label] ?? 0) + 1;
  }
  return counts.entries
      .map((entry) => EarthquakeChartDatum(
            label: entry.key,
            value: entry.value.toDouble(),
          ))
      .toList();
}

double _average(
  List<Terremoto> events,
  double Function(Terremoto) value,
) =>
    events.map(value).reduce((a, b) => a + b) / events.length;

String _magnitudeBand(double magnitude) {
  if (magnitude < 5) return '<5';
  if (magnitude < 6) return '5–6';
  if (magnitude < 7) return '6–7';
  return '7+';
}

String _depthBand(double depth) {
  if (depth < 70) return '0–70 km';
  if (depth < 300) return '70–300 km';
  return '300+ km';
}

String _day(DateTime date) =>
    '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

String _week(DateTime date) {
  final monday = DateTime(date.year, date.month, date.day)
      .subtract(Duration(days: date.weekday - 1));
  return '${monday.month.toString().padLeft(2, '0')}/${monday.day.toString().padLeft(2, '0')}';
}

String _eventLabel(Terremoto event, int index) =>
    '${event.fecha.month.toString().padLeft(2, '0')}/${event.fecha.day.toString().padLeft(2, '0')} #${index + 1}';
