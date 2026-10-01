import 'package:flutter/material.dart';

import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'earthquake_chart_renderer.dart';

class FlChartStyleWidget extends StatelessWidget {
  const FlChartStyleWidget({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) => content;
}

class GraphicChartStyleWidget extends StatelessWidget {
  const GraphicChartStyleWidget({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) => content;
}

class CommunityChartsStyleWidget extends StatelessWidget {
  const CommunityChartsStyleWidget({
    super.key,
    required this.content,
  });

  final Widget content;

  @override
  Widget build(BuildContext context) => content;
}

abstract class ChartStyleWidget extends StatelessWidget {
  const ChartStyleWidget({
    super.key,
    required this.definition,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

  @override
  Widget build(BuildContext context) => EarthquakeChartRenderer(
        definition: definition,
        earthquakes: earthquakes,
      );
}

class BarChartWidget extends ChartStyleWidget {
  const BarChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}

class LineChartWidget extends ChartStyleWidget {
  const LineChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}

class PieChartWidget extends ChartStyleWidget {
  const PieChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}

class ScatterChartWidget extends ChartStyleWidget {
  const ScatterChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}

class AreaChartWidget extends ChartStyleWidget {
  const AreaChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}

class GroupedBarChartWidget extends ChartStyleWidget {
  const GroupedBarChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}

class ComboChartWidget extends ChartStyleWidget {
  const ComboChartWidget(
      {super.key, required super.definition, required super.earthquakes});
}
