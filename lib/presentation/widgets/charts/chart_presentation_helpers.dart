import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'chart_helpers.dart';
import 'chart_texts.dart';

class ChartSummary extends StatelessWidget {
  const ChartSummary({
    super.key,
    required this.definition,
    required this.data,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<EarthquakeChartDatum> data;
  final List<Terremoto> earthquakes;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final summaryData = summarize(definition, data);
    final maximum = summaryData.reduce((a, b) => a.value >= b.value ? a : b);
    final average =
        summaryData.fold<double>(0, (sum, point) => sum + point.value) /
            summaryData.length;
    final total = earthquakes.length;
    final unit = ChartTooltipFormatter.unitFor(definition.metric);
    final label = _periodLabel(maximum.label);
    final seriesLabel = maximum.series.isEmpty ? '' : ' (${maximum.series})';
    final maximumContext =
        label.isEmpty ? ' · ${maximum.label}$seriesLabel' : label;
    return Text(
      'Máximo: ${ChartTooltipFormatter.formatNumber(maximum.value)} $unit'
      '$maximumContext · '
      'Promedio: ${ChartTooltipFormatter.formatNumber(average)} $unit · '
      'Total: $total ${ChartTexts.earthquakeUnit}',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
        height: 1.35,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static List<EarthquakeChartDatum> summarize(
    EarthquakeChartDefinition definition,
    List<EarthquakeChartDatum> data,
  ) =>
      data;

  String _periodLabel(String label) {
    final monthDay = RegExp(r'^(\d{2})/(\d{2})').firstMatch(label);
    if (monthDay == null) return '';
    final month = int.parse(monthDay.group(1)!);
    final day = int.parse(monthDay.group(2)!);
    final events = earthquakes.where(
      (event) => event.fecha.month == month && event.fecha.day == day,
    );
    if (events.isEmpty) return ' · $day/$month';
    final event = events.reduce(
      (a, b) => a.fecha.isBefore(b.fecha) ? a : b,
    );
    return ' el ${ChartTooltipFormatter.formatDate(event.fecha, withTime: false)}';
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.definition,
    required this.data,
    required this.primaryColor,
  });

  final EarthquakeChartDefinition definition;
  final List<EarthquakeChartDatum> data;
  final Color primaryColor;

  static bool hasEntries(
    EarthquakeChartDefinition definition,
    List<EarthquakeChartDatum> data,
  ) =>
      definition.style == ChartStyle.combo ||
      data
              .map((point) => point.series)
              .where((series) => series.isNotEmpty)
              .toSet()
              .length >
          1 ||
      definition.metric == ChartMetric.magnitudeBands ||
      definition.metric == ChartMetric.depthBands ||
      definition.metric == ChartMetric.movingAverageMagnitude;

  @override
  Widget build(BuildContext context) {
    final entries = _entries();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final entry in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: entry.$2,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                entry.$1,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<(String, Color)> _entries() {
    if (definition.style == ChartStyle.combo) {
      return [
        (
          definition.metric == ChartMetric.dailyCountAndAverageMagnitude
              ? 'Cantidad'
              : 'Magnitud',
          AppColors.primaryLight,
        ),
        (
          definition.metric == ChartMetric.dailyCountAndAverageMagnitude
              ? 'Magnitud promedio'
              : 'Profundidad',
          AppColors.magHigh,
        ),
      ];
    }
    final series =
        data.map((point) => point.series).where((s) => s.isNotEmpty).toSet();
    if (series.length > 1) {
      return [
        for (var index = 0; index < series.length; index++)
          (
            series.elementAt(index),
            AppColors.chartPalette[index % AppColors.chartPalette.length]
          ),
      ];
    }
    if (definition.metric == ChartMetric.magnitudeBands ||
        definition.metric == ChartMetric.depthBands) {
      return [
        for (var index = 0; index < data.length; index++)
          (data[index].label, _categoryColor(data[index].label, index)),
      ];
    }
    if (definition.metric == ChartMetric.movingAverageMagnitude) {
      return [('Magnitud', primaryColor), ('Promedio móvil', AppColors.magMid)];
    }
    return const [];
  }

  Color _categoryColor(String label, int index) {
    if (definition.metric == ChartMetric.magnitudeBands) {
      if (label == '<5') return AppColors.magLow;
      if (label == '5–6') return AppColors.magMid;
      return AppColors.magHigh;
    }
    return AppColors.chartPalette[index % 3];
  }
}

class ChartTooltipFormatter {
  const ChartTooltipFormatter(this.definition, this.earthquakes);

  static const tooltipPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const tooltipBorderRadius = BorderRadius.all(Radius.circular(8));
  static const graphicTooltipRadius = Radius.circular(8);
  static const tooltipFontSize = 11.0;

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

  static String unitFor(ChartMetric metric) => switch (metric) {
        ChartMetric.dailyAverageDepth ||
        ChartMetric.weeklyAverageDepth ||
        ChartMetric.magnitudeVsDepth =>
          'km',
        ChartMetric.depthVsMagnitude ||
        ChartMetric.magnitudeOverTime ||
        ChartMetric.dailyAverageMagnitude ||
        ChartMetric.dailyMaximumMagnitude ||
        ChartMetric.averageMagnitudeByPlace ||
        ChartMetric.weeklyAverageMagnitude ||
        ChartMetric.movingAverageMagnitude ||
        ChartMetric.magnitudeByEvent ||
        ChartMetric.magnitudeAndDepthByEvent =>
          'Mw',
        _ => ChartTexts.earthquakeUnit,
      };

  static String formatNumber(double value) =>
      value.abs() >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  static String metricValue(double value, ChartMetric metric) =>
      '${formatNumber(value)} ${unitFor(metric)}';

  String formatDatum(EarthquakeChartDatum datum, {double? value}) {
    final event = eventFor(datum);
    final date = switch (definition.metric) {
      ChartMetric.magnitudeBands ||
      ChartMetric.depthBands =>
        'Distribución del período',
      ChartMetric.topPlaces ||
      ChartMetric.averageMagnitudeByPlace =>
        'Período: últimos 30 días',
      _ => event == null
          ? datum.label
          : formatDate(event.fecha, withTime: _isEventMetric),
    };
    final place = placeFor(datum);
    return '$date\n${valueAndSeries(datum, value: value)}'
        '${place.isEmpty ? '' : '\n$place'}';
  }

  String valueAndSeries(EarthquakeChartDatum datum, {double? value}) {
    final metric = definition.style == ChartStyle.scatter
        ? '${chartXAxisTitle(definition)}: ${formatNumber(datum.xValue ?? 0)} · '
            '${chartYAxisTitle(definition)}: ${metricValue(value ?? datum.value, definition.metric)}'
        : metricValue(value ?? datum.value, definition.metric);
    final secondaryValue = datum.secondaryValue;
    if (secondaryValue == null) return metric;
    return '$metric\n${_secondaryLabel()}: '
        '${metricValue(secondaryValue, _secondaryMetric())}';
  }

  String _secondaryLabel() =>
      definition.metric == ChartMetric.movingAverageMagnitude
          ? 'Promedio móvil'
          : chartSecondaryAxisTitle(definition);

  ChartMetric _secondaryMetric() => switch (definition.metric) {
        ChartMetric.dailyCountAndAverageMagnitude =>
          ChartMetric.dailyAverageMagnitude,
        ChartMetric.magnitudeAndDepthByEvent => ChartMetric.dailyAverageDepth,
        _ => definition.metric,
      };

  String dateFor(EarthquakeChartDatum datum) {
    final formatted = formatDatum(datum);
    return formatted.split('\n').first;
  }

  String placeFor(EarthquakeChartDatum datum) {
    if (definition.metric == ChartMetric.topPlaces ||
        definition.metric == ChartMetric.averageMagnitudeByPlace) {
      return datum.label;
    }
    return _isEventMetric ? eventFor(datum)?.lugar ?? '' : '';
  }

  Terremoto? eventFor(EarthquakeChartDatum datum) {
    if (definition.metric == ChartMetric.magnitudeVsDepth ||
        definition.metric == ChartMetric.depthVsMagnitude) {
      for (final event in earthquakes) {
        final x = definition.metric == ChartMetric.magnitudeVsDepth
            ? event.magnitud
            : event.profundidad;
        final y = definition.metric == ChartMetric.magnitudeVsDepth
            ? event.profundidad
            : event.magnitud;
        if (event.lugar == datum.label &&
            x == datum.xValue &&
            (y - datum.value).abs() < 0.01) {
          return event;
        }
      }
    }
    final indexText = RegExp(r'#(\d+)$').firstMatch(datum.label)?.group(1);
    if (indexText != null) {
      final sorted = [...earthquakes]
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
      final index = int.parse(indexText) - 1;
      if (index >= 0 && index < sorted.length) return sorted[index];
    }
    final dateParts = RegExp(r'^(\d{2})/(\d{2})').firstMatch(datum.label);
    if (dateParts != null) {
      final month = int.parse(dateParts.group(1)!);
      final day = int.parse(dateParts.group(2)!);
      for (final event in earthquakes) {
        if (event.fecha.month == month && event.fecha.day == day) return event;
      }
    }
    for (final event in earthquakes) {
      if (event.lugar == datum.label) return event;
    }
    return null;
  }

  static String formatDate(DateTime date, {bool withTime = true}) {
    const months = [
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
    final dateLabel = '${date.day} ${months[date.month - 1]} ${date.year}';
    if (!withTime) return dateLabel;
    return '$dateLabel · ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  bool get _isEventMetric => switch (definition.metric) {
        ChartMetric.magnitudeOverTime ||
        ChartMetric.magnitudeVsDepth ||
        ChartMetric.magnitudeAndDepthByEvent ||
        ChartMetric.magnitudeByEvent ||
        ChartMetric.movingAverageMagnitude ||
        ChartMetric.depthVsMagnitude =>
          true,
        _ => false,
      };
}
