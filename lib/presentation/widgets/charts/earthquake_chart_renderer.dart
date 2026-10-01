import 'dart:math' as math;

import 'package:community_charts_flutter/community_charts_flutter.dart'
    as community;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import '../../../config/app_theme.dart';
import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'chart_helpers.dart';
import 'chart_presentation_helpers.dart';
import 'chart_texts.dart';

class EarthquakeChartRenderer extends StatefulWidget {
  const EarthquakeChartRenderer({
    super.key,
    required this.definition,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

  @override
  State<EarthquakeChartRenderer> createState() =>
      _EarthquakeChartRendererState();
}

class _EarthquakeChartRendererState extends State<EarthquakeChartRenderer> {
  int? _selectedPieSection;

  EarthquakeChartDefinition get definition => widget.definition;
  List<Terremoto> get earthquakes => widget.earthquakes;
  ChartTooltipFormatter get _tooltipFormatter =>
      ChartTooltipFormatter(definition, earthquakes);

  Color get _onSurface => Theme.of(context).colorScheme.onSurface;
  Color get _onSurfaceVariant => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _tooltipBackground => Theme.of(context).colorScheme.inverseSurface;
  TextStyle get _tooltipTextStyle => TextStyle(
        color: Theme.of(context).colorScheme.onInverseSurface,
        fontWeight: FontWeight.w600,
        fontSize: ChartTooltipFormatter.tooltipFontSize,
      );

  @override
  void didUpdateWidget(covariant EarthquakeChartRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.id != widget.definition.id ||
        !identical(oldWidget.earthquakes, widget.earthquakes)) {
      _selectedPieSection = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = buildChartData(definition.metric, earthquakes);
    if (data.isEmpty) {
      return const SizedBox(
        height: 260,
        child:
            Center(child: Text('No hay datos suficientes para esta gráfica.')),
      );
    }

    if (definition.library == ChartLibrary.communityCharts) {
      final chart = _communityChart(data);
      return _chartColumn(
        data,
        SizedBox(
          height: _chartHeight(data),
          key: ValueKey('${definition.library.name}-${definition.id}'),
          child: chart,
        ),
      );
    }

    final dataKey = _dataHash(data);
    return LayoutBuilder(
      builder: (context, constraints) {
        final graphicChart = definition.library == ChartLibrary.graphic
            ? SizedBox.expand(
                child: _graphicChart(data, constraints.maxWidth),
              )
            : null;
        return TweenAnimationBuilder<double>(
          key: ValueKey('${definition.id}-$dataKey'),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            final chart = definition.library == ChartLibrary.graphic
                ? Transform.rotate(
                    angle: definition.style == ChartStyle.pie
                        ? (1 - progress) * math.pi * 2
                        : 0,
                    child: Transform.translate(
                      offset: Offset(0, (1 - progress) * 10),
                      child: Opacity(opacity: progress, child: child),
                    ),
                  )
                : Transform.translate(
                    offset: Offset(0, (1 - progress) * 10),
                    child: Opacity(
                      opacity: progress,
                      child: _flChart(
                        _animateData(data, progress),
                        constraints.maxWidth,
                        progress,
                        sourceData: data,
                      ),
                    ),
                  );
            return _chartColumn(
              data,
              SizedBox(
                height: _chartHeight(data),
                key: ValueKey(
                  '${definition.library.name}-${definition.id}-$dataKey',
                ),
                child: chart,
              ),
            );
          },
          child: graphicChart,
        );
      },
    );
  }

  Widget _communityChart(List<EarthquakeChartDatum> data) {
    final series = _communitySeries(data);
    return switch (definition.style) {
      ChartStyle.pie => community.PieChart<String>(
          [
            community.Series<EarthquakeChartDatum, String>(
              id: definition.title,
              data: data,
              domainFn: (datum, _) => datum.label,
              measureFn: (datum, _) => datum.value,
            ),
          ],
          animate: true,
        ),
      ChartStyle.scatter => community.ScatterPlotChart(
          [
            community.Series<EarthquakeChartDatum, num>(
              id: definition.title,
              data: data,
              domainFn: (datum, index) =>
                  datum.xValue ?? (index ?? 0).toDouble(),
              measureFn: (datum, _) => datum.value,
            ),
          ],
          animate: true,
        ),
      ChartStyle.line || ChartStyle.area => community.LineChart(
          [
            community.Series<EarthquakeChartDatum, num>(
              id: definition.title,
              data: data,
              domainFn: (_, index) => (index ?? 0).toDouble(),
              measureFn: (datum, _) => datum.value,
            ),
          ],
          animate: true,
        ),
      ChartStyle.bar ||
      ChartStyle.groupedBar ||
      ChartStyle.combo =>
        community.BarChart(
          series,
          animate: true,
          barGroupingType: community.BarGroupingType.grouped,
        ),
    };
  }

  List<community.Series<EarthquakeChartDatum, String>> _communitySeries(
    List<EarthquakeChartDatum> data,
  ) {
    if (definition.style == ChartStyle.combo) {
      final secondaryData = data
          .where((datum) => datum.secondaryValue != null)
          .map(
            (datum) => EarthquakeChartDatum(
              label: datum.label,
              value: datum.secondaryValue!,
            ),
          )
          .toList();
      return [
        community.Series<EarthquakeChartDatum, String>(
          id: 'Cantidad',
          data: data,
          domainFn: (datum, _) => datum.label,
          measureFn: (datum, _) => datum.value,
        ),
        community.Series<EarthquakeChartDatum, String>(
          id: 'Medida secundaria',
          data: secondaryData,
          domainFn: (datum, _) => datum.label,
          measureFn: (datum, _) => datum.value,
        ),
      ];
    }
    final namedSeries = data.map((datum) => datum.series).toSet()..remove('');
    final groups = namedSeries.isEmpty
        ? <String, List<EarthquakeChartDatum>>{definition.title: data}
        : {
            for (final name in namedSeries)
              name: data.where((datum) => datum.series == name).toList(),
          };
    return [
      for (final entry in groups.entries)
        community.Series<EarthquakeChartDatum, String>(
          id: entry.key,
          data: entry.value,
          domainFn: (datum, _) => datum.label,
          measureFn: (datum, _) => datum.value,
        ),
    ];
  }

  Widget _chartColumn(
    List<EarthquakeChartDatum> data,
    Widget chart,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartSummary(
            definition: definition,
            data: data,
            earthquakes: earthquakes,
          ),
          const SizedBox(height: 8),
          _maximumHighlight(data),
          const SizedBox(height: 4),
          chart,
          if (ChartLegend.hasEntries(definition, data)) ...[
            const SizedBox(height: 8),
            ChartLegend(
              definition: definition,
              data: data,
              primaryColor: _primaryChartColor(data),
            ),
          ],
        ],
      );

  double _chartHeight(List<EarthquakeChartDatum> data) {
    final labelCount = _labels(data).length;
    if (labelCount > 40) return 360;
    if (labelCount > 16) return 320;
    return 280;
  }

  Widget _flChart(
    List<EarthquakeChartDatum> data,
    double width,
    double progress, {
    required List<EarthquakeChartDatum> sourceData,
  }) {
    if (definition.style == ChartStyle.pie) {
      final visibleData = data.where((datum) => datum.value > 0).toList();
      final total = visibleData.fold<double>(
        0,
        (sum, datum) => sum + datum.value,
      );
      return Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: 360 * (1 - progress),
              sectionsSpace: 4,
              centerSpaceRadius: 38,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final index = response?.touchedSection?.touchedSectionIndex;
                  if (index != null &&
                      index >= 0 &&
                      index < visibleData.length) {
                    setState(() => _selectedPieSection = index);
                  }
                },
              ),
              sections: [
                for (var i = 0; i < visibleData.length; i++)
                  PieChartSectionData(
                    value: visibleData[i].value,
                    title:
                        '${(visibleData[i].value / total * 100).toStringAsFixed(0)}% · ${visibleData[i].value.toStringAsFixed(0)}',
                    color: _colorForDatum(visibleData[i], i),
                    radius: _selectedPieSection == i
                        ? 103
                        : visibleData[i].value ==
                                visibleData
                                    .map((datum) => datum.value)
                                    .reduce(math.max)
                            ? 98
                            : 92,
                    cornerRadius: _selectedPieSection == i ? 5 : 2,
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: _selectedPieSection == i ||
                              visibleData[i].value ==
                                  visibleData
                                      .map((datum) => datum.value)
                                      .reduce(math.max)
                          ? 2.5
                          : 1,
                    ),
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            duration: Duration.zero,
            curve: Curves.easeOutCubic,
          ),
          IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  total.toStringAsFixed(0),
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ChartTexts.earthquakeUnit,
                  style: TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedPieSection != null &&
              _selectedPieSection! < visibleData.length)
            Positioned(
              bottom: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _tooltipBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    '${visibleData[_selectedPieSection!].label}: '
                    '${(visibleData[_selectedPieSection!].value / total * 100).toStringAsFixed(1)}% · '
                    '${visibleData[_selectedPieSection!].value.toStringAsFixed(0)} ${ChartTexts.earthquakeUnit}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    if (definition.style == ChartStyle.scatter) {
      return _flScatterChart(data, width, progress, sourceData);
    }
    if (definition.style == ChartStyle.combo) {
      return _flComboChart(data, width, sourceData);
    }
    if (definition.style == ChartStyle.line ||
        definition.style == ChartStyle.area) {
      final yRange = chartYAxisRange(
        metric: definition.metric,
        values: sourceData.map((datum) => datum.value),
      );
      final lineColor = _primaryChartColor(data);
      final revealCount =
          (data.length * progress).ceil().clamp(1, data.length).toInt();
      final maximumIndex = _maximumIndex(sourceData);
      return LineChart(
        LineChartData(
          minY: yRange.min,
          maxY: yRange.max,
          titlesData: _flCategoryTitles(
            sourceData,
            width,
            yRange: yRange,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: data.length <= 12,
            getDrawingVerticalLine: (_) => FlLine(
              color: _onSurfaceVariant.withValues(alpha: 0.08),
              strokeWidth: 0.7,
            ),
            getDrawingHorizontalLine: (value) => FlLine(
              color: _onSurfaceVariant.withValues(alpha: 0.16),
              strokeWidth: 0.8,
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: ChartTooltipFormatter.tooltipBorderRadius,
              tooltipPadding: ChartTooltipFormatter.tooltipPadding,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => _tooltipBackground,
              getTooltipItems: (spots) => spots.map((spot) {
                final datumIndex = spot.x.round().clamp(0, data.length - 1);
                final datum = data[datumIndex];
                return LineTooltipItem(
                  _tooltipFormatter.formatDatum(datum, value: spot.y),
                  _tooltipTextStyle,
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < revealCount; i++)
                  FlSpot(i.toDouble(), data[i].value),
              ],
              isCurved: true,
              curveSmoothness: 0.24,
              color: lineColor,
              gradient: LinearGradient(
                colors: [
                  lineColor.withValues(alpha: 0.65),
                  lineColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 3.5,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) =>
                    sourceData.length <= 15 || spot.x.round() == maximumIndex,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: index == maximumIndex ? 5 : 3,
                  color: index == maximumIndex ? AppColors.magHigh : lineColor,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: definition.style == ChartStyle.area ||
                    definition.complexity == ChartComplexity.avanzada,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withValues(alpha: 0.28),
                    lineColor.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              shadow: const Shadow(
                color: Color(0x332B6CB0),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ),
            if (data.any((datum) => datum.secondaryValue != null))
              LineChartBarData(
                spots: [
                  for (var i = 0; i < revealCount; i++)
                    if (data[i].secondaryValue != null)
                      FlSpot(i.toDouble(), data[i].secondaryValue!),
                ],
                isCurved: true,
                color: AppColors.magMid,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
              ),
          ],
          minX: 0,
          maxX: sourceData.length - 1.0,
        ),
        duration: Duration.zero,
        curve: Curves.easeOutCubic,
      );
    }

    final labels = _labels(data);
    final groupNames = _seriesNames(data);
    final maximumValue = data
        .map((datum) => datum.value)
        .fold<double>(double.negativeInfinity, math.max);
    final groups = <BarChartGroupData>[];
    for (var index = 0; index < labels.length; index++) {
      final label = labels[index];
      final bars = groupNames.isEmpty
          ? [
              BarChartRodData(
                toY: _valueFor(data, label),
                color: _valueFor(data, label) == maximumValue
                    ? AppColors.magHigh
                    : _colorForLabel(label, index),
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                gradient: LinearGradient(
                  colors: [
                    (_valueFor(data, label) == maximumValue
                            ? AppColors.magHigh
                            : _colorForLabel(label, index))
                        .withValues(alpha: 0.72),
                    _valueFor(data, label) == maximumValue
                        ? AppColors.magHigh
                        : _colorForLabel(label, index),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ]
          : [
              for (var seriesIndex = 0;
                  seriesIndex < groupNames.length;
                  seriesIndex++)
                BarChartRodData(
                  toY: _valueFor(data, label, groupNames[seriesIndex]),
                  color: _valueFor(data, label, groupNames[seriesIndex]) ==
                          maximumValue
                      ? AppColors.magHigh
                      : _colorForLabel(
                          groupNames[seriesIndex],
                          seriesIndex,
                        ),
                  width: 8,
                  borderRadius: BorderRadius.circular(3),
                ),
            ];
      groups.add(BarChartGroupData(
        x: index,
        barRods: bars,
        barsSpace: 3,
      ));
    }
    final yRange = chartYAxisRange(
      metric: definition.metric,
      values: sourceData.map((datum) => datum.value),
    );
    return BarChart(
      BarChartData(
        minY: yRange.min,
        maxY: yRange.max,
        titlesData: _flCategoryTitles(data, width, yRange: yRange),
        gridData: _flGridData(data.length),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: ChartTooltipFormatter.tooltipBorderRadius,
            tooltipPadding: ChartTooltipFormatter.tooltipPadding,
            getTooltipColor: (_) => _tooltipBackground,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              _tooltipFormatter.formatDatum(
                _datumForLabel(data, labels[group.x]),
                value: rod.toY,
              ),
              _tooltipTextStyle,
            ),
          ),
        ),
        barGroups: groups,
        groupsSpace: 12,
        borderData: FlBorderData(show: false),
      ),
      duration: Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _flScatterChart(
    List<EarthquakeChartDatum> data,
    double width,
    double progress,
    List<EarthquakeChartDatum> sourceData,
  ) {
    final xIsMagnitude = definition.metric == ChartMetric.magnitudeVsDepth;
    final xRange = chartNumericAxisRange(
      sourceData.map((datum) => datum.xValue ?? 0),
      minimum: xIsMagnitude ? 4 : 0,
    );
    final yRange = chartYAxisRange(
      metric: definition.metric,
      values: sourceData.map((datum) => datum.value),
    );
    return ScatterChart(
      ScatterChartData(
        minX: xRange.min,
        maxX: xRange.max,
        minY: yRange.min,
        maxY: yRange.max,
        titlesData: FlTitlesData(
          leftTitles: _flValueAxis(
            chartYAxisTitle(definition),
            yRange,
          ),
          bottomTitles: _flNumericXAxis(
            chartXAxisTitle(definition),
            xRange,
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: _flGridData(data.length),
        borderData: FlBorderData(show: false),
        scatterSpots: [
          for (var i = 0; i < data.length; i++)
            ScatterSpot(
              data[i].xValue ?? i.toDouble(),
              data[i].value,
              show: progress >= (i + 1) / data.length,
              dotPainter: FlDotCirclePainter(
                color: chartColorForMagnitude(
                  i == _maximumIndex(data)
                      ? 6
                      : xIsMagnitude
                          ? data[i].xValue ?? 0
                          : data[i].value,
                ),
                radius: i == _maximumIndex(data) ? 7 : 5,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
        ],
        scatterTouchData: ScatterTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchSpotThreshold: 18,
          touchTooltipData: ScatterTouchTooltipData(
            tooltipBorderRadius: ChartTooltipFormatter.tooltipBorderRadius,
            tooltipPadding: ChartTooltipFormatter.tooltipPadding,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spot) {
              final datum = data.firstWhere(
                (item) => (item.xValue ?? 0) == spot.x && item.value == spot.y,
                orElse: () => data.first,
              );
              return ScatterTooltipItem(
                _tooltipFormatter.formatDatum(datum, value: spot.y),
                textStyle: _tooltipTextStyle,
              );
            },
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
      ),
      duration: Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _flComboChart(
    List<EarthquakeChartDatum> data,
    double width,
    List<EarthquakeChartDatum> sourceData,
  ) {
    final labels = _labels(data);
    final primaryRange = chartYAxisRange(
      metric: definition.metric,
      values: sourceData.map((datum) => datum.value),
    );
    final secondaryMetric =
        definition.metric == ChartMetric.dailyCountAndAverageMagnitude
            ? ChartMetric.dailyAverageMagnitude
            : ChartMetric.dailyAverageDepth;
    final secondaryRange = chartYAxisRange(
      metric: secondaryMetric,
      values: sourceData.map((datum) => datum.secondaryValue ?? 0),
    );
    final primarySpan = primaryRange.max - primaryRange.min;
    final secondarySpan = secondaryRange.max - secondaryRange.min;
    final barGroups = [
      for (var index = 0; index < labels.length; index++)
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: _valueFor(data, labels[index]),
              color: _valueFor(data, labels[index]) ==
                      data.map((datum) => datum.value).reduce(math.max)
                  ? AppColors.magHigh
                  : AppColors.primary,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
    ];
    final secondarySpots = [
      for (var index = 0; index < data.length; index++)
        if (data[index].secondaryValue != null)
          FlSpot(
            index.toDouble(),
            primaryRange.min +
                (data[index].secondaryValue! - secondaryRange.min) /
                    secondarySpan *
                    primarySpan,
          ),
    ];

    return Stack(
      children: [
        BarChart(
          BarChartData(
            minY: primaryRange.min,
            maxY: primaryRange.max,
            titlesData: _flCategoryTitles(
              data,
              width,
              yRange: primaryRange,
              secondaryRange: secondaryRange,
              secondaryTitle: chartSecondaryAxisTitle(definition),
            ),
            gridData: _flGridData(data.length),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBorderRadius: ChartTooltipFormatter.tooltipBorderRadius,
                tooltipPadding: ChartTooltipFormatter.tooltipPadding,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final datum = _datumForLabel(data, labels[group.x]);
                  return BarTooltipItem(
                    _tooltipFormatter.formatDatum(datum, value: rod.toY),
                    _tooltipTextStyle,
                  );
                },
              ),
            ),
          ),
          duration: Duration.zero,
          curve: Curves.easeOutCubic,
        ),
        IgnorePointer(
          child: LineChart(
            LineChartData(
              minX: -0.5,
              maxX: labels.length - 0.5,
              minY: primaryRange.min,
              maxY: primaryRange.max,
              titlesData: const FlTitlesData(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: secondarySpots,
                  isCurved: true,
                  color: AppColors.magHigh,
                  barWidth: 3,
                  dotData: FlDotData(show: secondarySpots.length <= 15),
                  shadow: const Shadow(
                    color: Color(0x44D97706),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ),
              ],
            ),
            duration: Duration.zero,
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  FlTitlesData _flCategoryTitles(
    List<EarthquakeChartDatum> data,
    double width, {
    required ChartAxisRange yRange,
    ChartAxisRange? secondaryRange,
    String secondaryTitle = '',
  }) {
    final xInterval = chartXAxisLabelInterval(
      itemCount: _labels(data).length,
      availableWidth: width - 115,
      estimatedLabelWidth: chartXAxisTitle(definition) == 'Lugar' ? 82 : 48,
    );
    final referenceYear = _referenceYear;
    final longLabels = chartXAxisTitle(definition) == 'Lugar';
    final maxLabelCharacters =
        (width / math.max(1, _labels(data).length) / 7).floor().clamp(5, 14);
    return FlTitlesData(
      show: true,
      leftTitles: _flValueAxis(chartYAxisTitle(definition), yRange),
      rightTitles: secondaryRange == null
          ? const AxisTitles()
          : _flValueAxis(
              secondaryTitle,
              secondaryRange,
              maxY: yRange.max,
              minY: yRange.min,
              axisInterval: yRange.interval,
            ),
      bottomTitles: AxisTitles(
        axisNameWidget: _axisName(chartXAxisTitle(definition)),
        axisNameSize: 21,
        sideTitles: SideTitles(
          showTitles: true,
          interval: xInterval,
          reservedSize: 43,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if ((value - index).abs() > 0.01 ||
                index < 0 ||
                index >= _labels(data).length) {
              return const SizedBox.shrink();
            }
            final label = longLabels
                ? truncateChartLabel(
                    _labels(data)[index],
                    maxCharacters: maxLabelCharacters,
                  )
                : formatChartXAxisLabel(
                    _labels(data)[index],
                    definition.metric,
                    referenceYear: referenceYear,
                    referenceMonth: _referenceMonth,
                  );
            return SideTitleWidget(
              meta: meta,
              space: 3,
              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
              child: Text(label, style: _axisTextStyle, maxLines: 1),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(),
    );
  }

  AxisTitles _flValueAxis(
    String title,
    ChartAxisRange range, {
    double? minY,
    double? maxY,
    double? axisInterval,
  }) =>
      AxisTitles(
        axisNameWidget: _axisName(title),
        axisNameSize: 22,
        sideTitles: SideTitles(
          showTitles: true,
          interval: axisInterval ?? range.interval,
          reservedSize: title.length > 15 ? 68 : 52,
          getTitlesWidget: (value, meta) {
            final displayedValue = minY == null || maxY == null
                ? value
                : range.min +
                    (value - minY) / (maxY - minY) * (range.max - range.min);
            final label = displayedValue.abs() < 10
                ? displayedValue.toStringAsFixed(1)
                : displayedValue.toStringAsFixed(0);
            return SideTitleWidget(
              meta: meta,
              space: 3,
              child: Text(label, style: _axisTextStyle),
            );
          },
        ),
      );

  AxisTitles _flNumericXAxis(String title, ChartAxisRange range) => AxisTitles(
        axisNameWidget: _axisName(title),
        axisNameSize: 21,
        sideTitles: SideTitles(
          showTitles: true,
          interval: range.interval,
          reservedSize: 35,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            space: 3,
            child: Text(
              value.abs() < 10
                  ? value.toStringAsFixed(1)
                  : value.toStringAsFixed(0),
              style: _axisTextStyle,
            ),
          ),
        ),
      );

  FlGridData _flGridData(int dataLength) => FlGridData(
        show: true,
        drawVerticalLine: dataLength <= 12,
        getDrawingHorizontalLine: (_) => FlLine(
          color: _onSurfaceVariant.withValues(alpha: 0.16),
          strokeWidth: 0.8,
        ),
        getDrawingVerticalLine: (_) => FlLine(
          color: _onSurfaceVariant.withValues(alpha: 0.08),
          strokeWidth: 0.7,
        ),
      );

  Widget _axisName(String text) => Text(
        text,
        style: TextStyle(
          color: _onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
      );

  Widget _maximumHighlight(List<EarthquakeChartDatum> data) {
    final values = ChartSummary.summarize(definition, data);
    if (values.isEmpty) return const SizedBox.shrink();
    final maximum = values.reduce((a, b) => a.value >= b.value ? a : b);
    final unit = ChartTooltipFormatter.unitFor(definition.metric);
    final label = switch (unit) {
      'Mw' => 'Mayor magnitud',
      'km' => 'Mayor profundidad',
      _ => 'Mayor cantidad',
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.magHigh.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  size: 15, color: AppColors.magHigh),
              const SizedBox(width: 4),
              Text(
                '$label: ${maximum.label}'
                '${maximum.series.isEmpty ? '' : ' (${maximum.series})'} · '
                '${ChartTooltipFormatter.formatNumber(maximum.value)} $unit',
                style: TextStyle(
                  color: _onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  EarthquakeChartDatum _datumForLabel(
    List<EarthquakeChartDatum> data,
    String label,
  ) =>
      data.firstWhere(
        (datum) => datum.label == label,
        orElse: () => EarthquakeChartDatum(label: label, value: 0),
      );

  int _dataHash(List<EarthquakeChartDatum> data) => Object.hash(
        definition.id,
        Object.hashAll(
          data.map(
            (datum) => Object.hash(
              datum.label,
              datum.value,
              datum.secondaryValue,
              datum.series,
              datum.xValue,
            ),
          ),
        ),
        Object.hashAll(
          earthquakes.map(
            (event) => Object.hash(
              event.id,
              event.fecha.millisecondsSinceEpoch,
              event.magnitud,
              event.profundidad,
              event.lugar,
            ),
          ),
        ),
      );

  List<EarthquakeChartDatum> _animateData(
    List<EarthquakeChartDatum> data,
    double progress,
  ) {
    final baseline =
        ChartTooltipFormatter.unitFor(definition.metric) == 'Mw' ? 4.0 : 0.0;
    return [
      for (final datum in data)
        EarthquakeChartDatum(
          label: datum.label,
          series: datum.series,
          xValue: datum.xValue,
          value: baseline + (datum.value - baseline) * progress,
          secondaryValue: datum.secondaryValue == null
              ? null
              : _secondaryBaseline +
                  (datum.secondaryValue! - _secondaryBaseline) * progress,
        ),
    ];
  }

  double get _secondaryBaseline =>
      definition.metric == ChartMetric.dailyCountAndAverageMagnitude ? 4 : 0;

  int _maximumIndex(List<EarthquakeChartDatum> data) {
    if (data.isEmpty) return -1;
    var maximumIndex = 0;
    for (var index = 1; index < data.length; index++) {
      if (data[index].value > data[maximumIndex].value) maximumIndex = index;
    }
    return maximumIndex;
  }

  int? get _referenceYear {
    if (earthquakes.isEmpty) return null;
    return earthquakes
        .map((event) => event.fecha)
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .year;
  }

  int? get _referenceMonth {
    if (earthquakes.isEmpty) return null;
    return earthquakes
        .map((event) => event.fecha)
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .month;
  }

  TextStyle get _axisTextStyle =>
      TextStyle(color: _onSurfaceVariant, fontSize: 9);

  Widget _graphicChart(List<EarthquakeChartDatum> data, double width) {
    final xLabels = _labels(data);
    final xLabelInterval = chartXAxisLabelInterval(
      itemCount: xLabels.length,
      availableWidth: width - 105,
      estimatedLabelWidth: chartXAxisTitle(definition) == 'Lugar' ? 82 : 48,
    ).ceil();
    final yRange = chartYAxisRange(
      metric: definition.metric,
      values: data.map((datum) => datum.value),
    );
    final xIsMagnitude = definition.metric == ChartMetric.magnitudeVsDepth;
    final xRange = chartNumericAxisRange(
      data.map((datum) => datum.xValue ?? 0),
      minimum: xIsMagnitude ? 4 : 0,
    );
    final isScatter = definition.style == ChartStyle.scatter;
    final axisTextStyle = _axisTextStyle;
    final maximumValue = data
        .map((datum) => datum.value)
        .fold<double>(double.negativeInfinity, math.max);
    final labelScale = graphic.OrdinalScale(
      title: chartXAxisTitle(definition),
      formatter: (label) => chartXAxisTitle(definition) == 'Lugar'
          ? truncateChartLabel(label, maxCharacters: 12)
          : formatChartXAxisLabel(
              label,
              definition.metric,
              referenceYear: _referenceYear,
              referenceMonth: _referenceMonth,
            ),
      ticks: [
        for (var index = 0; index < xLabels.length; index++)
          if (index % xLabelInterval == 0 || index == xLabels.length - 1)
            xLabels[index],
      ],
    );
    final valueScale = graphic.LinearScale(
      min: yRange.min,
      max: yRange.max,
      title: chartYAxisTitle(definition),
      ticks: chartAxisTicks(yRange),
    );
    final horizontalAxis = graphic.AxisGuide(
      variable: isScatter ? 'xValue' : 'label',
      line: graphic.Defaults.strokeStyle,
      labelMapper: (_, __, ___) => graphic.LabelStyle(
        textStyle: axisTextStyle,
        offset: const Offset(0, 7),
        maxWidth: 70,
      ),
    );
    final verticalAxis = graphic.AxisGuide(
      variable: 'value',
      label: graphic.LabelStyle(
        textStyle: axisTextStyle,
      ),
      grid: graphic.Defaults.strokeStyle,
    );
    final chartData = [
      for (final datum in data)
        if (definition.style != ChartStyle.pie || datum.value > 0)
          <String, Object>{
            'label': datum.label,
            'value': datum.value,
            'secondary': _scaledSecondary(data, datum),
            'series': datum.series.isEmpty ? 'Serie principal' : datum.series,
            'xValue': datum.xValue ?? 0,
            'Fecha': _tooltipFormatter.dateFor(datum),
            'Valor': _tooltipFormatter.valueAndSeries(datum),
            'Lugar': _tooltipFormatter.placeFor(datum),
          },
    ];
    final marks = <graphic.Mark>[];
    final transition = graphic.Transition(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
    switch (definition.style) {
      case ChartStyle.pie:
        marks.add(
          graphic.IntervalMark(
            position: graphic.Varset('proportion') / graphic.Varset('label'),
            color: graphic.ColorEncode(
              variable: 'label',
              values: AppColors.chartPalette,
              updaters: {
                'tap': {
                  true: (color) => color,
                  false: (color) => color.withValues(alpha: 0.68),
                },
              },
            ),
            size: graphic.SizeEncode(
              value: 5,
              updaters: {
                'tap': {true: (size) => size * 1.35},
              },
            ),
            label: graphic.LabelEncode(
              encoder: (tuple) {
                final value = (tuple['value'] as num).toDouble();
                final total = data.fold<double>(
                  0,
                  (sum, datum) => sum + datum.value,
                );
                return graphic.Label(
                  '${tuple['label']} · ${(value / total * 100).toStringAsFixed(0)}% · ${value.toStringAsFixed(0)}',
                  graphic.LabelStyle(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
            modifiers: [graphic.StackModifier()],
            transition: transition,
            entrance: {graphic.MarkEntrance.opacity},
          ),
        );
        break;
      case ChartStyle.line:
        marks.add(
          graphic.LineMark(
            position: graphic.Varset('label') *
                graphic.Varset('value') /
                graphic.Varset('series'),
            color: graphic.ColorEncode(
              value: _primaryChartColor(data),
            ),
            shape: graphic.ShapeEncode(
              value: graphic.BasicLineShape(smooth: true),
            ),
            size: graphic.SizeEncode(value: 3),
            transition: transition,
            entrance: {
              graphic.MarkEntrance.opacity,
              graphic.MarkEntrance.y,
            },
          ),
        );
        if (data.any((datum) => datum.secondaryValue != null) &&
            definition.metric == ChartMetric.movingAverageMagnitude) {
          marks.add(
            graphic.LineMark(
              position: graphic.Varset('label') *
                  graphic.Varset('secondary') /
                  graphic.Varset('series'),
              color: graphic.ColorEncode(value: AppColors.magMid),
              shape: graphic.ShapeEncode(
                value: graphic.BasicLineShape(smooth: true),
              ),
              transition: transition,
              entrance: {
                graphic.MarkEntrance.opacity,
                graphic.MarkEntrance.y,
              },
            ),
          );
        }
        break;
      case ChartStyle.area:
        marks.add(
          graphic.AreaMark(
            position: graphic.Varset('label') * graphic.Varset('value'),
            shape: graphic.ShapeEncode(
              value: graphic.BasicAreaShape(smooth: true),
            ),
            transition: transition,
            entrance: {
              graphic.MarkEntrance.opacity,
              graphic.MarkEntrance.y,
            },
          ),
        );
        break;
      case ChartStyle.scatter:
        marks.add(
          graphic.PointMark(
            position: graphic.Varset('xValue') * graphic.Varset('value'),
            size: graphic.SizeEncode(
              encoder: (tuple) =>
                  (tuple['value'] as num).toDouble() == maximumValue ? 10 : 6,
            ),
            shape: graphic.ShapeEncode(value: graphic.CircleShape()),
            color: graphic.ColorEncode(
              encoder: (tuple) => chartColorForMagnitude(
                (xIsMagnitude ? tuple['xValue'] : tuple['value'] as num)
                    .toDouble(),
              ),
            ),
            transition: transition,
            entrance: {
              graphic.MarkEntrance.opacity,
              graphic.MarkEntrance.size,
            },
          ),
        );
        break;
      case ChartStyle.combo:
        marks
          ..add(
            graphic.IntervalMark(
              position: graphic.Varset('label') * graphic.Varset('value'),
              color: graphic.ColorEncode(value: AppColors.chartPalette[4]),
              transition: transition,
              entrance: {
                graphic.MarkEntrance.opacity,
                graphic.MarkEntrance.y,
              },
            ),
          )
          ..add(
            graphic.LineMark(
              position: graphic.Varset('label') * graphic.Varset('secondary'),
              color: graphic.ColorEncode(value: AppColors.magMid),
              shape: graphic.ShapeEncode(
                value: graphic.BasicLineShape(smooth: true),
              ),
              transition: transition,
              entrance: {
                graphic.MarkEntrance.opacity,
                graphic.MarkEntrance.y,
              },
            ),
          );
        break;
      case ChartStyle.bar:
      case ChartStyle.groupedBar:
        marks.add(
          graphic.IntervalMark(
            position: definition.style == ChartStyle.groupedBar
                ? graphic.Varset('label') *
                    graphic.Varset('value') /
                    graphic.Varset('series')
                : graphic.Varset('label') * graphic.Varset('value'),
            color: graphic.ColorEncode(
              variable: definition.style == ChartStyle.groupedBar
                  ? 'series'
                  : 'label',
              values: AppColors.chartPalette,
            ),
            modifiers: definition.style == ChartStyle.groupedBar
                ? [graphic.DodgeModifier()]
                : null,
            transition: transition,
            entrance: {
              graphic.MarkEntrance.opacity,
              graphic.MarkEntrance.y,
            },
          ),
        );
        break;
    }
    if (definition.style == ChartStyle.line ||
        definition.style == ChartStyle.area) {
      marks.add(
        graphic.PointMark(
          position: graphic.Varset('label') * graphic.Varset('value'),
          color: graphic.ColorEncode(value: AppColors.magHigh),
          size: graphic.SizeEncode(
            encoder: (tuple) =>
                (tuple['value'] as num).toDouble() == maximumValue ? 10 : 0,
          ),
          shape: graphic.ShapeEncode(value: graphic.CircleShape()),
          transition: transition,
          entrance: {
            graphic.MarkEntrance.opacity,
            graphic.MarkEntrance.size,
          },
        ),
      );
    }
    final variables = <String, graphic.Variable<Map<String, Object>, dynamic>>{
      'label': graphic.Variable<Map<String, Object>, String>(
        accessor: (datum) => datum['label'] as String,
        scale: labelScale,
      ),
      'value': graphic.Variable<Map<String, Object>, num>(
        accessor: (datum) => datum['value'] as num,
        scale: valueScale,
      ),
      'secondary': graphic.Variable<Map<String, Object>, num>(
        accessor: (datum) => datum['secondary'] as num,
        scale: valueScale,
      ),
      'xValue': graphic.Variable<Map<String, Object>, num>(
        accessor: (datum) => datum['xValue'] as num,
        scale: graphic.LinearScale(
          min: xRange.min,
          max: xRange.max,
          title: chartXAxisTitle(definition),
          ticks: chartAxisTicks(xRange),
        ),
      ),
      'series': graphic.Variable<Map<String, Object>, String>(
        accessor: (datum) => datum['series'] as String,
      ),
      'Fecha': graphic.Variable<Map<String, Object>, String>(
        accessor: (datum) => datum['Fecha'] as String,
        scale: graphic.OrdinalScale(),
      ),
      'Valor': graphic.Variable<Map<String, Object>, String>(
        accessor: (datum) => datum['Valor'] as String,
        scale: graphic.OrdinalScale(),
      ),
      'Lugar': graphic.Variable<Map<String, Object>, String>(
        accessor: (datum) => datum['Lugar'] as String,
        scale: graphic.OrdinalScale(),
      ),
    };
    final chart = graphic.Chart<Map<String, Object>>(
      key: ValueKey(
        '${definition.library.name}-${definition.id}-${_dataHash(data)}',
      ),
      data: chartData,
      variables: variables,
      transforms: definition.style == ChartStyle.pie
          ? [graphic.Proportion(variable: 'value', as: 'proportion')]
          : null,
      marks: marks,
      selections: {
        'tap': graphic.PointSelection(
          on: {graphic.GestureType.tap},
        ),
      },
      tooltip: graphic.TooltipGuide(
        selections: const {'tap'},
        multiTuples: false,
        variables: const ['Fecha', 'Valor', 'Lugar'],
        padding: ChartTooltipFormatter.tooltipPadding,
        backgroundColor: _tooltipBackground,
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: ChartTooltipFormatter.tooltipFontSize,
          fontWeight: FontWeight.w600,
        ),
        radius: ChartTooltipFormatter.graphicTooltipRadius,
      ),
      crosshair: definition.style == ChartStyle.line ||
              definition.style == ChartStyle.area ||
              definition.style == ChartStyle.scatter
          ? graphic.CrosshairGuide(
              selections: const {'tap'},
              showLabel: const [true, true],
              followPointer: const [false, false],
            )
          : null,
      coord: definition.style == ChartStyle.pie
          ? graphic.PolarCoord(transposed: true, dimCount: 1)
          : null,
      axes: definition.style == ChartStyle.pie
          ? const []
          : [horizontalAxis, verticalAxis],
    );
    if (definition.style == ChartStyle.pie) {
      final total = data.fold<double>(0, (sum, datum) => sum + datum.value);
      return Stack(
        alignment: Alignment.center,
        children: [
          chart,
          IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  total.toStringAsFixed(0),
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ChartTexts.earthquakeUnit,
                  style: TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final secondaryTitle = chartSecondaryAxisTitle(definition);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _axisName(
            secondaryTitle.isEmpty
                ? 'Eje vertical: ${chartYAxisTitle(definition)}'
                : 'Barras: ${chartYAxisTitle(definition)} · Línea: $secondaryTitle',
          ),
        ),
        Expanded(child: chart),
        Align(
          alignment: Alignment.center,
          child: _axisName('Eje horizontal: ${chartXAxisTitle(definition)}'),
        ),
      ],
    );
  }

  double _scaledSecondary(
    List<EarthquakeChartDatum> data,
    EarthquakeChartDatum datum,
  ) {
    final secondary = datum.secondaryValue;
    if (secondary == null) return datum.value;
    if (definition.metric == ChartMetric.movingAverageMagnitude) {
      return secondary;
    }

    final secondaryMax = data
        .map((item) => item.secondaryValue ?? 0)
        .fold<double>(0, (maximum, value) => value > maximum ? value : maximum);
    if (secondaryMax == 0) return 0;
    final primaryRange = chartYAxisRange(
      metric: definition.metric,
      values: data.map((item) => item.value),
    );
    return primaryRange.min +
        secondary / secondaryMax * (primaryRange.max - primaryRange.min);
  }

  Color _primaryChartColor(List<EarthquakeChartDatum> data) {
    final magnitudeMetric = switch (definition.metric) {
      ChartMetric.depthVsMagnitude ||
      ChartMetric.magnitudeOverTime ||
      ChartMetric.dailyAverageMagnitude ||
      ChartMetric.dailyMaximumMagnitude ||
      ChartMetric.averageMagnitudeByPlace ||
      ChartMetric.weeklyAverageMagnitude ||
      ChartMetric.movingAverageMagnitude ||
      ChartMetric.magnitudeByEvent ||
      ChartMetric.magnitudeAndDepthByEvent =>
        true,
      _ => false,
    };
    if (!magnitudeMetric || data.isEmpty) return AppColors.chartPalette[4];
    final average =
        data.map((datum) => datum.value).reduce((a, b) => a + b) / data.length;
    return chartColorForMagnitude(average);
  }

  Color _colorForDatum(EarthquakeChartDatum datum, int index) =>
      _colorForLabel(datum.series.isEmpty ? datum.label : datum.series, index);

  Color _colorForLabel(String label, int index) {
    if (definition.metric == ChartMetric.magnitudeBands) {
      if (label == '<5') return AppColors.magLow;
      if (label == '5–6') return AppColors.magMid;
      if (label == '6–7' || label == '7+') return AppColors.magHigh;
    }
    if (definition.metric == ChartMetric.depthBands) {
      return AppColors.chartPalette[index % 3];
    }
    return AppColors.chartPalette[index % AppColors.chartPalette.length];
  }

  List<String> _seriesNames(List<EarthquakeChartDatum> data) => data
      .map((datum) => datum.series)
      .where((series) => series.isNotEmpty)
      .toSet()
      .toList();

  List<String> _labels(List<EarthquakeChartDatum> data) =>
      data.map((datum) => datum.label).toSet().toList();

  double _valueFor(
    List<EarthquakeChartDatum> data,
    String label, [
    String series = '',
  ]) {
    for (final datum in data) {
      if (datum.label == label && datum.series == series) return datum.value;
    }
    return 0;
  }
}
