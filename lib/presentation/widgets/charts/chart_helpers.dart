import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';

class ChartAxisRange {
  const ChartAxisRange({
    required this.min,
    required this.max,
    required this.interval,
  });

  final double min;
  final double max;
  final double interval;
}

ChartAxisRange chartNumericAxisRange(
  Iterable<num> values, {
  double minimum = 0,
  int targetTickCount = 5,
}) {
  final finiteValues = values.where((value) => value.isFinite).toList();
  final dataMaximum = finiteValues.isEmpty
      ? minimum + 1
      : finiteValues.reduce(math.max).toDouble();
  final rawInterval = math.max((dataMaximum - minimum) / targetTickCount, 0.1);
  final interval = _niceInterval(rawInterval);
  final maximum = math.max(
    minimum + interval,
    (dataMaximum / interval).ceil() * interval,
  );
  return ChartAxisRange(min: minimum, max: maximum, interval: interval);
}

String chartXAxisTitle(EarthquakeChartDefinition definition) {
  return switch (definition.metric) {
    ChartMetric.magnitudeVsDepth => 'Magnitud (Mw)',
    ChartMetric.depthVsMagnitude => 'Profundidad (km)',
    ChartMetric.magnitudeBands => 'Rango de magnitud',
    ChartMetric.depthBands => 'Rango de profundidad',
    ChartMetric.topPlaces || ChartMetric.averageMagnitudeByPlace => 'Lugar',
    _ => 'Fecha',
  };
}

String chartYAxisTitle(EarthquakeChartDefinition definition) {
  return switch (definition.metric) {
    ChartMetric.dailyCount ||
    ChartMetric.cumulativeCount ||
    ChartMetric.dailyCountByMagnitude ||
    ChartMetric.weeklyCountByMagnitude ||
    ChartMetric.magnitudeBands ||
    ChartMetric.depthBands ||
    ChartMetric.topPlaces =>
      'Cantidad de sismos',
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
    ChartMetric.dailyCountAndAverageMagnitude => 'Cantidad de sismos',
  };
}

String chartSecondaryAxisTitle(EarthquakeChartDefinition definition) {
  return switch (definition.metric) {
    ChartMetric.dailyCountAndAverageMagnitude => 'Magnitud (Mw)',
    ChartMetric.magnitudeAndDepthByEvent => 'Profundidad (km)',
    _ => '',
  };
}

ChartAxisRange chartYAxisRange({
  required ChartMetric metric,
  required Iterable<num> values,
  int targetTickCount = 5,
}) {
  final magnitudeAxis = switch (metric) {
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
  return chartNumericAxisRange(
    values,
    minimum: magnitudeAxis ? 4 : 0,
    targetTickCount: targetTickCount,
  );
}

List<double> chartAxisTicks(ChartAxisRange range) {
  final ticks = <double>[];
  for (var value = range.min;
      value <= range.max + range.interval / 2;
      value += range.interval) {
    ticks.add(double.parse(value.toStringAsFixed(6)));
  }
  return ticks;
}

double chartXAxisLabelInterval({
  required int itemCount,
  required double availableWidth,
  double estimatedLabelWidth = 48,
}) {
  if (itemCount <= 1 || availableWidth <= 0) return 1;
  final visibleLabelCount = (availableWidth / estimatedLabelWidth).floor();
  return (itemCount / math.max(visibleLabelCount, 1)).ceilToDouble();
}

String formatChartXAxisLabel(
  String label,
  ChartMetric metric, {
  int? referenceYear,
  int? referenceMonth,
  int maxCharacters = 12,
}) {
  final dateLabel = label.split(' #').first;
  final parts = dateLabel.split('/');
  if (parts.length == 2) {
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    if (month != null && day != null) {
      var year = referenceYear ?? DateTime.now().year;
      if (referenceMonth != null && referenceMonth >= 11 && month <= 2) {
        year++;
      } else if (referenceMonth != null && referenceMonth <= 2 && month >= 11) {
        year--;
      }
      final date = DateTime(year, month, day);
      if (metric == ChartMetric.weeklyCountByMagnitude ||
          metric == ChartMetric.weeklyAverageMagnitude ||
          metric == ChartMetric.weeklyAverageDepth) {
        return 'S${_isoWeekNumber(date)}';
      }
      return '${date.day} ${_spanishMonths[date.month - 1]}';
    }
  }
  return truncateChartLabel(label, maxCharacters: maxCharacters);
}

String truncateChartLabel(String value, {int maxCharacters = 12}) {
  if (value.length <= maxCharacters) return value;
  return '${value.substring(0, math.max(1, maxCharacters - 1))}…';
}

Color chartColorForMagnitude(double magnitude) =>
    AppColors.colorForMagnitude(magnitude);

const _spanishMonths = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

double _niceInterval(double value) {
  final exponent =
      math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  final fraction = value / exponent;
  final niceFraction = switch (fraction) {
    <= 1 => 1.0,
    <= 2 => 2.0,
    <= 2.5 => 2.5,
    <= 5 => 5.0,
    _ => 10.0,
  };
  return niceFraction * exponent;
}

int _isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final firstWeekThursday = firstThursday.add(
    Duration(days: DateTime.thursday - firstThursday.weekday),
  );
  return 1 + thursday.difference(firstWeekThursday).inDays ~/ 7;
}
