import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../config/app_theme.dart';
import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'chart_presentation_helpers.dart';

class SyncfusionEarthquakeChart extends StatelessWidget {
  const SyncfusionEarthquakeChart({
    super.key,
    required this.definition,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

  @override
  Widget build(BuildContext context) {
    final type = definition.syncfusionType;
    if (type == null) {
      throw StateError(
        'La gráfica ${definition.id} no tiene un tipo Syncfusion asignado.',
      );
    }

    final data = _chartData(type);
    if (data.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: Text('No hay datos suficientes para esta gráfica.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartSummary(
          definition: definition,
          data: data,
          earthquakes: earthquakes,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: _buildChart(context, type, data),
        ),
      ],
    );
  }

  Widget _buildChart(
    BuildContext context,
    SyncfusionChartType type,
    List<EarthquakeChartDatum> data,
  ) {
    if (type == SyncfusionChartType.funnel) {
      return SfFunnelChart(
        legend: _legend(context),
        tooltipBehavior: _tooltip(),
        series: FunnelSeries<EarthquakeChartDatum, String>(
          dataSource: data,
          xValueMapper: (datum, _) => datum.label,
          yValueMapper: (datum, _) => datum.value,
          pointColorMapper: (_, index) => _color(index),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          animationDuration: 1000,
        ),
      );
    }

    if (type == SyncfusionChartType.pyramid) {
      return SfPyramidChart(
        legend: _legend(context),
        tooltipBehavior: _tooltip(),
        series: PyramidSeries<EarthquakeChartDatum, String>(
          dataSource: data,
          xValueMapper: (datum, _) => datum.label,
          yValueMapper: (datum, _) => datum.value,
          pointColorMapper: (_, index) => _color(index),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          animationDuration: 1000,
        ),
      );
    }

    if (_isCircular(type)) {
      return SfCircularChart(
        legend: _legend(context),
        tooltipBehavior: _tooltip(),
        series: <CircularSeries<EarthquakeChartDatum, String>>[
          if (type == SyncfusionChartType.radialBar)
            RadialBarSeries<EarthquakeChartDatum, String>(
              dataSource: data,
              xValueMapper: (datum, _) => datum.label,
              yValueMapper: (datum, _) => datum.value,
              pointColorMapper: (_, index) => _color(index),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              animationDuration: 1000,
            )
          else
            DoughnutSeries<EarthquakeChartDatum, String>(
              dataSource: data,
              xValueMapper: (datum, _) => datum.label,
              yValueMapper: (datum, _) => datum.value,
              pointColorMapper: (_, index) => _color(index),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              innerRadius: '58%',
              animationDuration: 1000,
            ),
        ],
      );
    }

    if (type == SyncfusionChartType.dualPanel) {
      final horizontal = MediaQuery.sizeOf(context).width >= 700;
      return Flex(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(
            child: _measureChart(
              context,
              data,
              title: 'Magnitud (Mw)',
              value: (datum) => datum.value,
              color: AppColors.primaryLight,
            ),
          ),
          Expanded(
            child: _measureChart(
              context,
              data,
              title: 'Profundidad (km)',
              value: (datum) => datum.secondaryValue ?? 0,
              color: AppColors.magHigh,
            ),
          ),
        ],
      );
    }

    final isScatter = type == SyncfusionChartType.bubble ||
        type == SyncfusionChartType.scatterWithTrendline;
    final isAdvanced = definition.complexity == ChartComplexity.avanzada;
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: isScatter || type == SyncfusionChartType.histogram
          ? NumericAxis(
              title: AxisTitle(
                text: type == SyncfusionChartType.histogram
                    ? 'Intervalo de magnitud'
                    : 'Magnitud (Mw)',
              ),
              labelStyle: _axisTextStyle(context),
              majorGridLines: const MajorGridLines(width: 0),
            )
          : CategoryAxis(
              title: AxisTitle(text: _xAxisTitle),
              labelStyle: _axisTextStyle(context),
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: AxisLine(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              labelRotation: data.length > 12 ? -35 : 0,
            ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: _yAxisTitle),
        labelStyle: _axisTextStyle(context),
        majorGridLines: MajorGridLines(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.45,
              ),
        ),
      ),
      legend: _legend(context),
      tooltipBehavior: _tooltip(),
      trackballBehavior: isAdvanced
          ? TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
            )
          : null,
      zoomPanBehavior: isAdvanced
          ? ZoomPanBehavior(
              enablePinching: true,
              enablePanning: true,
              enableDoubleTapZooming: true,
              zoomMode: isScatter ? ZoomMode.xy : ZoomMode.x,
            )
          : null,
      series: _cartesianSeries(type, data),
    );
  }

  List<CartesianSeries<dynamic, dynamic>> _cartesianSeries(
    SyncfusionChartType type,
    List<EarthquakeChartDatum> data,
  ) {
    String x(EarthquakeChartDatum datum, int _) => datum.label;
    double y(EarthquakeChartDatum datum, int _) => datum.value;
    double low(EarthquakeChartDatum datum, int _) =>
        math.min(datum.value, datum.secondaryValue ?? datum.value);
    double high(EarthquakeChartDatum datum, int _) =>
        math.max(datum.value, datum.secondaryValue ?? datum.value);
    final trendline = <Trendline>[
      Trendline(
        type: TrendlineType.linear,
        color: AppColors.magHigh,
        width: 2,
      ),
    ];

    if (_isStacked(type)) {
      final groups = data.map((datum) => datum.series).toSet()
        ..removeWhere((series) => series.isEmpty);
      if (groups.length < 2) {
        throw StateError(
          'La gráfica apilada ${definition.id} requiere series agrupadas.',
        );
      }
      return [
        for (final group in groups.toList().asMap().entries)
          _stackedSeries(
            type,
            data.where((datum) => datum.series == group.value).toList(),
            _color(group.key),
            x,
            y,
            group.value,
          ),
      ];
    }

    return switch (type) {
      SyncfusionChartType.spline => [
          SplineSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            markerSettings: const MarkerSettings(isVisible: true),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.stepLine => [
          StepLineSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.fastLine => [
          FastLineSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.splineArea => [
          SplineAreaSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index).withValues(alpha: 0.35),
            borderColor: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.stepArea => [
          StepAreaSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index).withValues(alpha: 0.35),
            borderColor: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.stackedLine ||
      SyncfusionChartType.stackedColumn ||
      SyncfusionChartType.stackedBar ||
      SyncfusionChartType.stackedArea ||
      SyncfusionChartType.stackedLine100 ||
      SyncfusionChartType.stackedColumn100 ||
      SyncfusionChartType.stackedBar100 ||
      SyncfusionChartType.stackedArea100 =>
        throw StateError('Las series apiladas se deben crear por grupo.'),
      SyncfusionChartType.waterfall => [
          WaterfallSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.histogram => [
          HistogramSeries<EarthquakeChartDatum, num>(
            dataSource: data,
            yValueMapper: y,
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.boxAndWhisker => [
          BoxAndWhiskerSeries<EarthquakeChartDatum, String>(
            dataSource: [data.first],
            xValueMapper: (datum, _) => 'Magnitudes',
            yValueMapper: (datum, _) =>
                data.map((point) => point.value).toList(),
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.rangeColumn => [
          RangeColumnSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            lowValueMapper: low,
            highValueMapper: high,
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.rangeArea => [
          RangeAreaSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            lowValueMapper: low,
            highValueMapper: high,
            color: _color(type.index).withValues(alpha: 0.35),
            borderColor: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.splineRangeArea => [
          SplineRangeAreaSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            lowValueMapper: low,
            highValueMapper: high,
            color: _color(type.index).withValues(alpha: 0.35),
            borderColor: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.bubble => [
          BubbleSeries<EarthquakeChartDatum, num>(
            dataSource: data,
            xValueMapper: (datum, index) => datum.xValue ?? index.toDouble(),
            yValueMapper: y,
            sizeValueMapper: (datum, _) =>
                (datum.xValue ?? datum.value).abs().clamp(1, 10).toDouble(),
            pointColorMapper: (datum, _) =>
                AppColors.colorForMagnitude(datum.xValue ?? datum.value),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.errorBar => [
          ErrorBarSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            type: ErrorBarType.standardDeviation,
          ),
        ],
      SyncfusionChartType.candle => [
          CandleSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            lowValueMapper: (datum, _) => datum.lowValue ?? datum.value,
            highValueMapper: (datum, _) => datum.highValue ?? datum.value,
            openValueMapper: (datum, _) => datum.openValue ?? datum.value,
            closeValueMapper: (datum, _) => datum.closeValue ?? datum.value,
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.hilo => [
          HiloSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            lowValueMapper: (datum, _) => datum.lowValue ?? datum.value,
            highValueMapper: (datum, _) => datum.highValue ?? datum.value,
            color: _color(type.index),
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.hiloOpenClose => [
          HiloOpenCloseSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            lowValueMapper: (datum, _) => datum.lowValue ?? datum.value,
            highValueMapper: (datum, _) => datum.highValue ?? datum.value,
            openValueMapper: (datum, _) => datum.openValue ?? datum.value,
            closeValueMapper: (datum, _) => datum.closeValue ?? datum.value,
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.scatterWithTrendline => [
          ScatterSeries<EarthquakeChartDatum, num>(
            dataSource: data,
            xValueMapper: (datum, index) => datum.xValue ?? index.toDouble(),
            yValueMapper: y,
            pointColorMapper: (datum, _) =>
                AppColors.colorForMagnitude(datum.xValue ?? datum.value),
            trendlines: trendline,
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.splineWithTrendline => [
          SplineSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            markerSettings: const MarkerSettings(isVisible: true),
            trendlines: trendline,
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.columnWithTrendline => [
          ColumnSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: x,
            yValueMapper: y,
            color: _color(type.index),
            trendlines: trendline,
            enableTooltip: true,
          ),
        ],
      SyncfusionChartType.doughnut ||
      SyncfusionChartType.funnel ||
      SyncfusionChartType.pyramid ||
      SyncfusionChartType.radialBar ||
      SyncfusionChartType.dualPanel =>
        throw StateError(
            'El tipo circular o combinado se debe enrutar aparte.'),
    };
  }

  CartesianSeries<EarthquakeChartDatum, String> _stackedSeries(
    SyncfusionChartType type,
    List<EarthquakeChartDatum> data,
    Color color,
    String Function(EarthquakeChartDatum, int) x,
    double Function(EarthquakeChartDatum, int) y,
    String name,
  ) {
    final args = _StackedSeriesArgs(
      data: data,
      xValueMapper: x,
      yValueMapper: y,
      name: name,
      color: color,
    );
    return switch (type) {
      SyncfusionChartType.stackedLine =>
        StackedLineSeries<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color,
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedColumn =>
        StackedColumnSeries<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color,
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedBar =>
        StackedBarSeries<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color,
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedArea =>
        StackedAreaSeries<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color.withValues(alpha: 0.4),
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedLine100 =>
        StackedLine100Series<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color,
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedColumn100 =>
        StackedColumn100Series<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color,
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedBar100 =>
        StackedBar100Series<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color,
          enableTooltip: true,
        ),
      SyncfusionChartType.stackedArea100 =>
        StackedArea100Series<EarthquakeChartDatum, String>(
          dataSource: args.data,
          xValueMapper: args.xValueMapper,
          yValueMapper: args.yValueMapper,
          name: args.name,
          color: args.color.withValues(alpha: 0.4),
          enableTooltip: true,
        ),
      _ => throw StateError('$type no es una serie apilada.'),
    };
  }

  List<EarthquakeChartDatum> _chartData(SyncfusionChartType type) {
    if (type == SyncfusionChartType.candle ||
        type == SyncfusionChartType.hilo ||
        type == SyncfusionChartType.hiloOpenClose) {
      return _dailyMagnitudeOhlc();
    }
    return buildChartData(definition.metric, earthquakes);
  }

  Widget _measureChart(
    BuildContext context,
    List<EarthquakeChartDatum> data, {
    required String title,
    required double Function(EarthquakeChartDatum) value,
    required Color color,
  }) =>
      SfCartesianChart(
        margin: const EdgeInsets.all(4),
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          labelStyle: _axisTextStyle(context),
          majorGridLines: const MajorGridLines(width: 0),
          labelRotation: data.length > 8 ? -35 : 0,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: title),
          labelStyle: _axisTextStyle(context),
          majorGridLines: MajorGridLines(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
                  alpha: 0.45,
                ),
          ),
        ),
        tooltipBehavior: _tooltip(),
        series: <CartesianSeries<EarthquakeChartDatum, String>>[
          SplineSeries<EarthquakeChartDatum, String>(
            dataSource: data,
            xValueMapper: (datum, _) => datum.label,
            yValueMapper: (datum, _) => value(datum),
            color: color,
            markerSettings: const MarkerSettings(isVisible: true),
            enableTooltip: true,
          ),
        ],
      );

  List<EarthquakeChartDatum> _dailyMagnitudeOhlc() {
    final sorted = [...earthquakes]..sort((a, b) => a.fecha.compareTo(b.fecha));
    final grouped = <String, List<Terremoto>>{};
    for (final event in sorted) {
      final label = '${event.fecha.month.toString().padLeft(2, '0')}/'
          '${event.fecha.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(label, () => []).add(event);
    }
    return [
      for (final entry in grouped.entries)
        EarthquakeChartDatum(
          label: entry.key,
          value: entry.value.last.magnitud,
          openValue: entry.value.first.magnitud,
          closeValue: entry.value.last.magnitud,
          lowValue: entry.value.map((event) => event.magnitud).reduce(math.min),
          highValue:
              entry.value.map((event) => event.magnitud).reduce(math.max),
        ),
    ];
  }

  Legend _legend(BuildContext context) => Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
        textStyle: _axisTextStyle(context),
      );

  TooltipBehavior _tooltip() => TooltipBehavior(
        enable: true,
        header: '',
        activationMode: ActivationMode.singleTap,
      );

  static bool _isCircular(SyncfusionChartType type) =>
      type == SyncfusionChartType.doughnut ||
      type == SyncfusionChartType.radialBar;

  static bool _isStacked(SyncfusionChartType type) => switch (type) {
        SyncfusionChartType.stackedLine ||
        SyncfusionChartType.stackedColumn ||
        SyncfusionChartType.stackedBar ||
        SyncfusionChartType.stackedArea ||
        SyncfusionChartType.stackedLine100 ||
        SyncfusionChartType.stackedColumn100 ||
        SyncfusionChartType.stackedBar100 ||
        SyncfusionChartType.stackedArea100 =>
          true,
        _ => false,
      };

  String get _xAxisTitle => definition.metric == ChartMetric.magnitudeVsDepth
      ? 'Magnitud (Mw)'
      : 'Periodo / categoría';

  String get _yAxisTitle => switch (definition.metric) {
        ChartMetric.dailyAverageDepth ||
        ChartMetric.weeklyAverageDepth ||
        ChartMetric.magnitudeVsDepth =>
          'Profundidad (km)',
        ChartMetric.depthVsMagnitude ||
        ChartMetric.magnitudeOverTime ||
        ChartMetric.dailyAverageMagnitude ||
        ChartMetric.dailyMaximumMagnitude ||
        ChartMetric.averageMagnitudeByPlace ||
        ChartMetric.weeklyAverageMagnitude ||
        ChartMetric.movingAverageMagnitude ||
        ChartMetric.magnitudeByEvent ||
        ChartMetric.magnitudeAndDepthByEvent =>
          'Magnitud (Mw)',
        _ => 'Eventos',
      };

  static Color _color(int index) =>
      AppColors.chartPalette[index % AppColors.chartPalette.length];

  static TextStyle _axisTextStyle(BuildContext context) => TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 10,
      );
}

class _StackedSeriesArgs {
  const _StackedSeriesArgs({
    required this.data,
    required this.xValueMapper,
    required this.yValueMapper,
    required this.name,
    required this.color,
  });

  final List<EarthquakeChartDatum> data;
  final String Function(EarthquakeChartDatum, int) xValueMapper;
  final double Function(EarthquakeChartDatum, int) yValueMapper;
  final String name;
  final Color color;
}
