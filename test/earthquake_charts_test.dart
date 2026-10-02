import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as community;
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:graphic/graphic.dart' as graphic;
import 'package:syncfusion_flutter_charts/charts.dart' as syncfusion;
import 'package:usgs_terremotos/config/app_constants.dart';
import 'package:usgs_terremotos/config/app_theme.dart';
import 'package:usgs_terremotos/data/models/terremoto.dart';
import 'package:usgs_terremotos/logic/analytics/earthquake_chart_catalog.dart';
import 'package:usgs_terremotos/presentation/widgets/charts/earthquake_chart_view.dart';
import 'package:usgs_terremotos/presentation/widgets/charts/chart_helpers.dart';
import 'package:usgs_terremotos/presentation/widgets/charts/chart_presentation_helpers.dart';
import 'package:usgs_terremotos/presentation/widgets/charts/chart_style_widgets.dart';
import 'package:usgs_terremotos/presentation/widgets/charts/chart_texts.dart';

void main() {
  final earthquakes = <Terremoto>[
    _earthquake('a', 4.8, DateTime(2025, 1, 1), 15, 'Region A'),
    _earthquake('b', 5.4, DateTime(2025, 1, 1, 12), 100, 'Region A'),
    _earthquake('c', 6.2, DateTime(2025, 1, 2), 350, 'Region B'),
    _earthquake('d', 7.1, DateTime(2025, 1, 10), 40, 'Region C'),
  ];

  test('los ejes usan escalas legibles y etiquetas en español', () {
    expect(AppConstants.defaultLimit, 500);
    final magnitudeRange = chartYAxisRange(
      metric: ChartMetric.magnitudeOverTime,
      values: [4.7, 5.2, 6.1],
    );
    expect(magnitudeRange.min, 4);
    expect(magnitudeRange.max, greaterThanOrEqualTo(6.1));
    expect(magnitudeRange.interval, greaterThan(0));
    expect(
      chartNumericAxisRange([0, 37], targetTickCount: 4).interval,
      10,
    );

    final countRange = chartYAxisRange(
      metric: ChartMetric.magnitudeBands,
      values: [0, 3, 8],
    );
    expect(countRange.min, 0);
    expect(countRange.max, greaterThanOrEqualTo(8));

    expect(
      formatChartXAxisLabel('05/12', ChartMetric.dailyCount,
          referenceYear: 2026),
      '12 may',
    );
    expect(
      formatChartXAxisLabel(
        '05/04',
        ChartMetric.weeklyAverageMagnitude,
        referenceYear: 2026,
      ),
      'S19',
    );
    expect(
      chartXAxisLabelInterval(
        itemCount: 40,
        availableWidth: 200,
      ),
      greaterThan(1),
    );
    expect(
      chartYAxisTitle(
        earthquakeChartCatalog.firstWhere(
          (chart) => chart.metric == ChartMetric.magnitudeBands,
        ),
      ),
      'Cantidad de sismos',
    );
  });

  test('se conservan las gráficas y se agregan 32 de Syncfusion', () {
    expect(earthquakeChartCatalog, hasLength(128));
    expect(
      earthquakeChartCatalog.map((chart) => chart.id).toSet(),
      hasLength(128),
    );
    for (final library in [ChartLibrary.flChart, ChartLibrary.graphic]) {
      final libraryCharts = earthquakeChartCatalog
          .where((chart) => chart.library == library)
          .toList();
      expect(libraryCharts, hasLength(32), reason: library.label);
      expect(
        libraryCharts
            .where((chart) => chart.complexity == ChartComplexity.basica),
        hasLength(20),
        reason: '${library.label}: básicas',
      );
      expect(
        libraryCharts
            .where((chart) => chart.complexity == ChartComplexity.avanzada),
        hasLength(12),
        reason: '${library.label}: avanzadas',
      );
    }
    final addedCharts = earthquakeChartCatalog
        .where((chart) => chart.library == ChartLibrary.communityCharts);
    expect(addedCharts, hasLength(32));
    expect(
      addedCharts.where((chart) => chart.complexity == ChartComplexity.basica),
      hasLength(20),
    );
    expect(
      addedCharts
          .where((chart) => chart.complexity == ChartComplexity.avanzada),
      hasLength(12),
    );
    final syncfusionCharts = earthquakeChartCatalog
        .where((chart) => chart.library == ChartLibrary.syncfusionCharts)
        .toList();
    expect(syncfusionCharts, hasLength(32));
    expect(
      syncfusionCharts
          .where((chart) => chart.complexity == ChartComplexity.basica),
      hasLength(20),
    );
    expect(
      syncfusionCharts
          .where((chart) => chart.complexity == ChartComplexity.avanzada),
      hasLength(12),
    );
    expect(
      syncfusionCharts.map((chart) => chart.syncfusionType).toSet(),
      hasLength(32),
    );
    final existingTitles = earthquakeChartCatalog
        .where((chart) => chart.library != ChartLibrary.syncfusionCharts)
        .map((chart) => chart.title)
        .toSet();
    expect(
      syncfusionCharts.every((chart) => !existingTitles.contains(chart.title)),
      isTrue,
    );
    expect(
      addedCharts.where((chart) => chart.complexity == ChartComplexity.basica),
      hasLength(20),
    );
    expect(
      addedCharts
          .where((chart) => chart.complexity == ChartComplexity.avanzada),
      hasLength(12),
    );
  });

  test('las agregaciones usan los eventos reales y conservan sus medidas', () {
    final dailyCounts = buildChartData(ChartMetric.dailyCount, earthquakes);
    expect(dailyCounts.map((point) => point.value), [2, 1, 1]);

    final magnitudeBands =
        buildChartData(ChartMetric.magnitudeBands, earthquakes);
    expect(magnitudeBands.map((point) => point.value), [1, 1, 1, 1]);

    final scatter = buildChartData(ChartMetric.magnitudeVsDepth, earthquakes);
    expect(scatter, hasLength(4));
    expect(scatter.first.xValue, 4.8);
    expect(scatter.first.value, 15);

    final combined =
        buildChartData(ChartMetric.dailyCountAndAverageMagnitude, earthquakes);
    expect(combined.first.value, 2);
    expect(combined.first.secondaryValue, closeTo(5.1, 0.001));
  });

  testWidgets('las 128 gráficas construyen sus widgets sin excepciones',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    for (final definition in earthquakeChartCatalog) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EarthquakeChartView(
              definition: definition,
              earthquakes: earthquakes,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.textContaining('Máximo:'),
        findsOneWidget,
        reason: 'Falta el resumen de ${definition.title}',
      );
      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: 'Falló la gráfica ${definition.id}: ${definition.title}',
      );
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('genera resumen legible para cada una de las 128 gráficas',
      (tester) async {
    for (final definition in earthquakeChartCatalog) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartSummary(
              definition: definition,
              data: buildChartData(definition.metric, earthquakes),
              earthquakes: earthquakes,
            ),
          ),
        ),
      );
      expect(find.textContaining('Máximo:'), findsOneWidget);
      expect(find.textContaining('Promedio:'), findsOneWidget);
      expect(find.textContaining('Total: 4 sismos'), findsOneWidget);
    }
  });

  testWidgets('muestra un estado vacío amable con pocos sismos',
      (tester) async {
    final definition = earthquakeChartCatalog.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EarthquakeChartView(
            definition: definition,
            earthquakes: [earthquakes.first],
          ),
        ),
      ),
    );
    expect(find.text(ChartTexts.emptyTitle), findsOneWidget);
    expect(find.text(ChartTexts.emptyDescription), findsOneWidget);
    expect(find.byIcon(Icons.query_stats_rounded), findsOneWidget);
  });

  testWidgets('selector usa tarjeta adaptable al tema y widget por estilo',
      (tester) async {
    final definition = earthquakeChartCatalog.firstWhere(
      (chart) => chart.library == ChartLibrary.flChart,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: EarthquakeChartView(
            definition: definition,
            earthquakes: earthquakes,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(BarChartWidget), findsOneWidget);
    expect(find.byType(FlChartStyleWidget), findsOneWidget);
    final summary = tester.widget<Text>(find.textContaining('Máximo:'));
    expect(
      summary.style?.color,
      AppTheme.darkTheme.colorScheme.onSurfaceVariant,
    );

    final graphicDefinition = earthquakeChartCatalog.firstWhere(
      (chart) =>
          chart.library == ChartLibrary.graphic &&
          chart.style == ChartStyle.bar,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EarthquakeChartView(
            definition: graphicDefinition,
            earthquakes: earthquakes,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(GraphicChartStyleWidget), findsOneWidget);
    expect(find.byType(graphic.Chart<Map<String, Object>>), findsOneWidget);
  });

  testWidgets('Community Charts dibuja las nuevas gráficas', (tester) async {
    final communityChart = earthquakeChartCatalog.firstWhere(
      (definition) =>
          definition.library == ChartLibrary.communityCharts &&
          definition.style == ChartStyle.groupedBar,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EarthquakeChartView(
            definition: communityChart,
            earthquakes: earthquakes,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(community.BarChart), findsOneWidget);
  });

  testWidgets('las librerías conservan o dibujan líneas', (tester) async {
    for (final library in ChartLibrary.values) {
      final definition = earthquakeChartCatalog.firstWhere(
        (chart) => chart.library == library && chart.style == ChartStyle.line,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EarthquakeChartView(
              definition: definition,
              earthquakes: earthquakes,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      switch (library) {
        case ChartLibrary.flChart:
          expect(find.byType(fl_chart.LineChart), findsOneWidget);
        case ChartLibrary.graphic:
          expect(
              find.byType(graphic.Chart<Map<String, Object>>), findsOneWidget);
        case ChartLibrary.communityCharts:
          expect(find.byType(community.LineChart), findsOneWidget);
        case ChartLibrary.syncfusionCharts:
          expect(find.byType(syncfusion.SfCartesianChart), findsOneWidget);
      }
    }
  });
}

Terremoto _earthquake(
  String id,
  double magnitude,
  DateTime date,
  double depth,
  String place,
) =>
    Terremoto(
      id: id,
      magnitud: magnitude,
      lugar: place,
      fecha: date,
      latitud: 0,
      longitud: 0,
      profundidad: depth,
      tipo: 'earthquake',
      revisiones: 'reviewed',
      fuente: 'usgs',
      url: '',
      titulo: place,
    );
