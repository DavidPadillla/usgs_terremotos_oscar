import '../../data/models/terremoto.dart';

enum ChartLibrary {
  flChart('fl_chart'),
  graphic('Graphic'),
  communityCharts('Community Charts'),
  syncfusionCharts('Syncfusion Charts');

  const ChartLibrary(this.label);

  final String label;
}

enum ChartComplexity { basica, avanzada }

enum ChartStyle { line, bar, pie, scatter, area, groupedBar, combo }

enum ChartVisualType {
  area,
  bar,
  boxPlot,
  bubble,
  bullet,
  candlestick,
  column,
  communityBars,
  communityLine,
  communityPie,
  communityScatter,
  funnel,
  graphicArea,
  graphicBars,
  graphicLine,
  graphicScatter,
  heatmap,
  line,
  lollipop,
  pie,
  polar,
  radar,
  radialBar,
  rangeArea,
  rangeColumn,
  ridgeline,
  rose,
  scatter,
  stackedArea,
  stackedBar,
  stackedColumn,
  stepLine,
  streamgraph,
  syncfusionDoughnut,
  violin,
  waterfall,
}

extension ChartVisualTypeLabel on ChartVisualType {
  String get label => name
      .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
      .replaceFirstMapped(
        RegExp(r'^[a-z]'),
        (match) => match[0]!.toUpperCase(),
      );
}

class ChartVisualComposition {
  const ChartVisualComposition({required this.first, required this.second});

  final ChartVisualType first;
  final ChartVisualType second;
}

enum SyncfusionChartType {
  spline,
  stepLine,
  fastLine,
  splineArea,
  stepArea,
  stackedLine,
  stackedColumn,
  stackedBar,
  stackedArea,
  waterfall,
  histogram,
  boxAndWhisker,
  rangeColumn,
  rangeArea,
  splineRangeArea,
  bubble,
  doughnut,
  funnel,
  pyramid,
  radialBar,
  stackedLine100,
  stackedColumn100,
  stackedBar100,
  stackedArea100,
  errorBar,
  candle,
  hilo,
  hiloOpenClose,
  scatterWithTrendline,
  splineWithTrendline,
  columnWithTrendline,
  dualPanel,
}

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
    this.syncfusionType,
    this.showSummary = true,
  });

  final int id;
  final String title;
  final String description;
  final ChartLibrary library;
  final ChartComplexity complexity;
  final ChartStyle style;
  final ChartMetric metric;
  final SyncfusionChartType? syncfusionType;
  final bool showSummary;

  ChartVisualComposition get visualComposition =>
      ChartVisualComposition(first: _primaryVisual, second: _secondaryVisual);

  ChartVisualType get _primaryVisual => switch (style) {
    ChartStyle.line || ChartStyle.combo => ChartVisualType.line,
    ChartStyle.bar => ChartVisualType.bar,
    ChartStyle.pie => ChartVisualType.pie,
    ChartStyle.scatter => ChartVisualType.scatter,
    ChartStyle.area => ChartVisualType.area,
    ChartStyle.groupedBar => ChartVisualType.stackedBar,
  };

  ChartVisualType get _secondaryVisual {
    if (library == ChartLibrary.syncfusionCharts) {
      return switch (syncfusionType) {
        SyncfusionChartType.spline ||
        SyncfusionChartType.fastLine ||
        SyncfusionChartType.stackedLine ||
        SyncfusionChartType.stackedLine100 ||
        SyncfusionChartType.splineWithTrendline ||
        SyncfusionChartType.dualPanel => ChartVisualType.line,
        SyncfusionChartType.stepLine => ChartVisualType.stepLine,
        SyncfusionChartType.splineArea ||
        SyncfusionChartType.stepArea => ChartVisualType.area,
        SyncfusionChartType.stackedArea ||
        SyncfusionChartType.stackedArea100 => ChartVisualType.stackedArea,
        SyncfusionChartType.stackedColumn ||
        SyncfusionChartType.stackedColumn100 => ChartVisualType.stackedColumn,
        SyncfusionChartType.stackedBar ||
        SyncfusionChartType.stackedBar100 => ChartVisualType.stackedBar,
        SyncfusionChartType.waterfall => ChartVisualType.waterfall,
        SyncfusionChartType.histogram => ChartVisualType.column,
        SyncfusionChartType.boxAndWhisker => ChartVisualType.boxPlot,
        SyncfusionChartType.rangeColumn => ChartVisualType.rangeColumn,
        SyncfusionChartType.rangeArea ||
        SyncfusionChartType.splineRangeArea ||
        SyncfusionChartType.errorBar => ChartVisualType.rangeArea,
        SyncfusionChartType.bubble => ChartVisualType.bubble,
        SyncfusionChartType.doughnut => ChartVisualType.syncfusionDoughnut,
        SyncfusionChartType.funnel ||
        SyncfusionChartType.pyramid => ChartVisualType.funnel,
        SyncfusionChartType.radialBar => ChartVisualType.radialBar,
        SyncfusionChartType.candle ||
        SyncfusionChartType.hilo ||
        SyncfusionChartType.hiloOpenClose => ChartVisualType.candlestick,
        SyncfusionChartType.scatterWithTrendline => ChartVisualType.scatter,
        SyncfusionChartType.columnWithTrendline => ChartVisualType.column,
        null => _primaryVisual,
      };
    }

    return switch ((library, style)) {
      (ChartLibrary.graphic, ChartStyle.line) => ChartVisualType.graphicLine,
      (ChartLibrary.graphic, ChartStyle.area) => ChartVisualType.graphicArea,
      (ChartLibrary.graphic, ChartStyle.scatter) =>
        ChartVisualType.graphicScatter,
      (ChartLibrary.graphic, ChartStyle.bar) ||
      (
        ChartLibrary.graphic,
        ChartStyle.groupedBar,
      ) => ChartVisualType.graphicBars,
      (ChartLibrary.communityCharts, ChartStyle.line) ||
      (
        ChartLibrary.communityCharts,
        ChartStyle.area,
      ) => ChartVisualType.communityLine,
      (ChartLibrary.communityCharts, ChartStyle.scatter) =>
        ChartVisualType.communityScatter,
      (ChartLibrary.communityCharts, ChartStyle.pie) =>
        ChartVisualType.communityPie,
      (ChartLibrary.communityCharts, ChartStyle.bar) ||
      (
        ChartLibrary.communityCharts,
        ChartStyle.groupedBar,
      ) => ChartVisualType.communityBars,
      (_, ChartStyle.line) => ChartVisualType.stepLine,
      (_, ChartStyle.bar) => ChartVisualType.column,
      (_, ChartStyle.pie) => ChartVisualType.pie,
      (_, ChartStyle.scatter) => ChartVisualType.bubble,
      (_, ChartStyle.area) => ChartVisualType.streamgraph,
      (_, ChartStyle.groupedBar) => ChartVisualType.stackedColumn,
      (_, ChartStyle.combo) => ChartVisualType.rangeArea,
    };
  }
}

class EarthquakeChartDatum {
  const EarthquakeChartDatum({
    required this.label,
    required this.value,
    this.series = '',
    this.secondaryValue,
    this.xValue,
    this.openValue,
    this.highValue,
    this.lowValue,
    this.closeValue,
  });

  final String label;
  final double value;
  final String series;
  final double? secondaryValue;
  final double? xValue;
  final double? openValue;
  final double? highValue;
  final double? lowValue;
  final double? closeValue;
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

const _syncfusionCharts = <EarthquakeChartDefinition>[
  EarthquakeChartDefinition(
    id: 97,
    title: 'Magnitud suavizada por semana',
    description: 'Representa la tendencia semanal con una curva spline.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.weeklyAverageMagnitude,
    syncfusionType: SyncfusionChartType.spline,
  ),
  EarthquakeChartDefinition(
    id: 98,
    title: 'Magnitud escalonada por evento',
    description: 'Destaca los cambios entre magnitudes consecutivas.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeByEvent,
    syncfusionType: SyncfusionChartType.stepLine,
  ),
  EarthquakeChartDefinition(
    id: 99,
    title: 'Profundidad semanal de alta densidad',
    description: 'Traza los promedios semanales con una serie optimizada.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.line,
    metric: ChartMetric.weeklyAverageDepth,
    syncfusionType: SyncfusionChartType.fastLine,
  ),
  EarthquakeChartDefinition(
    id: 100,
    title: 'Área de sismos acumulados suavizada',
    description: 'Muestra el crecimiento acumulado mediante un área spline.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.cumulativeCount,
    syncfusionType: SyncfusionChartType.splineArea,
  ),
  EarthquakeChartDefinition(
    id: 101,
    title: 'Área escalonada de actividad diaria',
    description: 'Resalta los cambios abruptos en el conteo diario.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.dailyCount,
    syncfusionType: SyncfusionChartType.stepArea,
  ),
  EarthquakeChartDefinition(
    id: 102,
    title: 'Línea apilada por rangos de magnitud',
    description: 'Compara la contribución de cada rango por día.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.dailyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedLine,
  ),
  EarthquakeChartDefinition(
    id: 103,
    title: 'Columnas apiladas por rango semanal',
    description: 'Acumula los rangos de magnitud en cada semana.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.weeklyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedColumn,
  ),
  EarthquakeChartDefinition(
    id: 104,
    title: 'Barras apiladas por rango diario',
    description: 'Compara horizontalmente los rangos de magnitud por día.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.dailyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedBar,
  ),
  EarthquakeChartDefinition(
    id: 105,
    title: 'Área apilada de conteos semanales',
    description: 'Presenta la composición semanal de magnitudes como áreas.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.weeklyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedArea,
  ),
  EarthquakeChartDefinition(
    id: 106,
    title: 'Variación diaria en cascada',
    description: 'Desglosa el aporte del conteo de cada día.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.dailyCount,
    syncfusionType: SyncfusionChartType.waterfall,
  ),
  EarthquakeChartDefinition(
    id: 107,
    title: 'Histograma de magnitudes reportadas',
    description: 'Agrupa las magnitudes individuales en intervalos.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.magnitudeByEvent,
    syncfusionType: SyncfusionChartType.histogram,
  ),
  EarthquakeChartDefinition(
    id: 108,
    title: 'Distribución de magnitudes por evento',
    description: 'Resume la dispersión de magnitudes en un diagrama de caja.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.bar,
    metric: ChartMetric.magnitudeByEvent,
    syncfusionType: SyncfusionChartType.boxAndWhisker,
  ),
  EarthquakeChartDefinition(
    id: 109,
    title: 'Rango de magnitud y promedio móvil',
    description: 'Compara cada medición con su promedio móvil.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.movingAverageMagnitude,
    syncfusionType: SyncfusionChartType.rangeColumn,
  ),
  EarthquakeChartDefinition(
    id: 110,
    title: 'Banda de magnitud frente al promedio móvil',
    description: 'Visualiza el intervalo entre magnitud y promedio móvil.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.movingAverageMagnitude,
    syncfusionType: SyncfusionChartType.rangeArea,
  ),
  EarthquakeChartDefinition(
    id: 111,
    title: 'Banda spline del promedio móvil',
    description: 'Suaviza el intervalo entre valores y promedio móvil.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.area,
    metric: ChartMetric.movingAverageMagnitude,
    syncfusionType: SyncfusionChartType.splineRangeArea,
  ),
  EarthquakeChartDefinition(
    id: 112,
    title: 'Burbujas de magnitud y profundidad',
    description: 'Relaciona profundidad y magnitud con tamaño proporcional.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.scatter,
    metric: ChartMetric.magnitudeVsDepth,
    syncfusionType: SyncfusionChartType.bubble,
  ),
  EarthquakeChartDefinition(
    id: 113,
    title: 'Anillo de rangos de profundidad',
    description: 'Distribuye los eventos en un gráfico de anillo.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.depthBands,
    syncfusionType: SyncfusionChartType.doughnut,
  ),
  EarthquakeChartDefinition(
    id: 114,
    title: 'Embudo de magnitudes',
    description: 'Ordena los rangos de magnitud según su número de eventos.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.magnitudeBands,
    syncfusionType: SyncfusionChartType.funnel,
  ),
  EarthquakeChartDefinition(
    id: 115,
    title: 'Pirámide de ubicaciones sísmicas',
    description: 'Compara los lugares con más eventos en forma piramidal.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.topPlaces,
    syncfusionType: SyncfusionChartType.pyramid,
  ),
  EarthquakeChartDefinition(
    id: 116,
    title: 'Barras radiales de magnitud semanal',
    description: 'Compara magnitudes semanales en una disposición radial.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.basica,
    style: ChartStyle.pie,
    metric: ChartMetric.weeklyAverageMagnitude,
    syncfusionType: SyncfusionChartType.radialBar,
  ),
  EarthquakeChartDefinition(
    id: 117,
    title: 'Composición porcentual semanal en líneas',
    description: 'Muestra la proporción semanal de cada rango de magnitud.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.weeklyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedLine100,
  ),
  EarthquakeChartDefinition(
    id: 118,
    title: 'Composición porcentual diaria en columnas',
    description: 'Normaliza cada día al cien por ciento por rango.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.dailyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedColumn100,
  ),
  EarthquakeChartDefinition(
    id: 119,
    title: 'Composición porcentual semanal en barras',
    description: 'Compara horizontalmente las proporciones por semana.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.groupedBar,
    metric: ChartMetric.weeklyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedBar100,
  ),
  EarthquakeChartDefinition(
    id: 120,
    title: 'Composición porcentual diaria en áreas',
    description:
        'Contrasta la participación de cada rango a través del tiempo.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.area,
    metric: ChartMetric.dailyCountByMagnitude,
    syncfusionType: SyncfusionChartType.stackedArea100,
  ),
  EarthquakeChartDefinition(
    id: 121,
    title: 'Promedio semanal con barras de error',
    description: 'Incluye una estimación de dispersión sobre el promedio.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.line,
    metric: ChartMetric.weeklyAverageMagnitude,
    syncfusionType: SyncfusionChartType.errorBar,
  ),
  EarthquakeChartDefinition(
    id: 122,
    title: 'Velas del cambio de magnitud diario',
    description: 'Resume apertura, máximo, mínimo y cierre por día.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeOverTime,
    syncfusionType: SyncfusionChartType.candle,
  ),
  EarthquakeChartDefinition(
    id: 123,
    title: 'Rango máximo y mínimo de magnitud',
    description: 'Destaca el intervalo diario entre magnitudes extremas.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeOverTime,
    syncfusionType: SyncfusionChartType.hilo,
  ),
  EarthquakeChartDefinition(
    id: 124,
    title: 'Rango con apertura y cierre diarios',
    description: 'Combina extremos y orden cronológico de magnitudes.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeOverTime,
    syncfusionType: SyncfusionChartType.hiloOpenClose,
  ),
  EarthquakeChartDefinition(
    id: 125,
    title: 'Dispersión con tendencia de profundidad',
    description: 'Relaciona magnitud y profundidad con una tendencia lineal.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.scatter,
    metric: ChartMetric.magnitudeVsDepth,
    syncfusionType: SyncfusionChartType.scatterWithTrendline,
  ),
  EarthquakeChartDefinition(
    id: 126,
    title: 'Magnitud y profundidad en paneles paralelos',
    description: 'Compara ambas medidas en paneles con escalas independientes.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.combo,
    metric: ChartMetric.magnitudeAndDepthByEvent,
    syncfusionType: SyncfusionChartType.dualPanel,
  ),
  EarthquakeChartDefinition(
    id: 127,
    title: 'Magnitudes con tendencia spline',
    description: 'Añade una tendencia lineal a la serie de magnitudes.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.line,
    metric: ChartMetric.magnitudeByEvent,
    syncfusionType: SyncfusionChartType.splineWithTrendline,
  ),
  EarthquakeChartDefinition(
    id: 128,
    title: 'Conteo de sismos con tendencia',
    description: 'Contrasta los conteos diarios con una línea de tendencia.',
    library: ChartLibrary.syncfusionCharts,
    complexity: ChartComplexity.avanzada,
    style: ChartStyle.bar,
    metric: ChartMetric.dailyCount,
    syncfusionType: SyncfusionChartType.columnWithTrendline,
  ),
];

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
  ..._syncfusionCharts,
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
              value:
                  metric == ChartMetric.magnitudeVsDepth
                      ? entry.value.profundidad
                      : entry.value.magnitud,
              xValue:
                  metric == ChartMetric.magnitudeVsDepth
                      ? entry.value.magnitud
                      : entry.value.profundidad,
            ),
          )
          .toList();
    case ChartMetric.cumulativeCount:
      var total = 0;
      return _groupByDate(sorted).entries.map((entry) {
        total += entry.value.length;
        return EarthquakeChartDatum(label: entry.key, value: total.toDouble());
      }).toList();
    case ChartMetric.dailyCountByMagnitude:
    case ChartMetric.weeklyCountByMagnitude:
      final groups = <String, Map<String, int>>{};
      for (final event in sorted) {
        final period =
            metric == ChartMetric.dailyCountByMagnitude
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
        (events) => events
            .map((event) => event.magnitud)
            .reduce(
              (maximum, magnitude) => magnitude > maximum ? magnitude : maximum,
            ),
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
          .map(
            (entry) => EarthquakeChartDatum(
              label: entry.key,
              value: _average(entry.value, (event) => event.magnitud),
            ),
          )
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
      final places =
          counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      return places
          .take(8)
          .map(
            (entry) => EarthquakeChartDatum(
              label: entry.key,
              value: entry.value.toDouble(),
            ),
          )
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
    _groupByDate(earthquakes).entries
        .map(
          (entry) => EarthquakeChartDatum(
            label: entry.key,
            value: aggregate(entry.value),
          ),
        )
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
      .map(
        (entry) => EarthquakeChartDatum(
          label: entry.key,
          value: aggregate(entry.value),
        ),
      )
      .toList();
}

List<EarthquakeChartDatum> _eventValues(
  List<Terremoto> earthquakes,
  double Function(Terremoto) value,
) =>
    earthquakes
        .asMap()
        .entries
        .map(
          (entry) => EarthquakeChartDatum(
            label: _eventLabel(entry.value, entry.key),
            value: value(entry.value),
          ),
        )
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
      .map(
        (entry) => EarthquakeChartDatum(
          label: entry.key,
          value: entry.value.toDouble(),
        ),
      )
      .toList();
}

double _average(List<Terremoto> events, double Function(Terremoto) value) =>
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
  final monday = DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: date.weekday - 1));
  return '${monday.month.toString().padLeft(2, '0')}/${monday.day.toString().padLeft(2, '0')}';
}

String _eventLabel(Terremoto event, int index) =>
    '${event.fecha.month.toString().padLeft(2, '0')}/${event.fecha.day.toString().padLeft(2, '0')} #${index + 1}';
