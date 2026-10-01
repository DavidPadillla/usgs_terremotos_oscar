import 'package:flutter/material.dart';

import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'chart_texts.dart';
import 'chart_style_widgets.dart';

class EarthquakeChartView extends StatelessWidget {
  const EarthquakeChartView({
    super.key,
    required this.definition,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

  @override
  Widget build(BuildContext context) {
    final enoughData = earthquakes.length >= 2 &&
        buildChartData(definition.metric, earthquakes).length >= 2;
    if (!enoughData) {
      return const Card(
        child: SizedBox(
          width: double.infinity,
          height: 280,
          child: _ChartEmptyState(),
        ),
      );
    }

    final styleChart = switch (definition.style) {
      ChartStyle.bar => BarChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
      ChartStyle.line => LineChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
      ChartStyle.pie => PieChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
      ChartStyle.scatter => ScatterChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
      ChartStyle.area => AreaChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
      ChartStyle.groupedBar => GroupedBarChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
      ChartStyle.combo => ComboChartWidget(
          definition: definition,
          earthquakes: earthquakes,
        ),
    };
    final chart = switch (definition.library) {
      ChartLibrary.flChart => FlChartStyleWidget(content: styleChart),
      ChartLibrary.graphic => GraphicChartStyleWidget(content: styleChart),
      ChartLibrary.communityCharts =>
        CommunityChartsStyleWidget(content: styleChart),
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: chart,
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats_rounded, size: 42, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            ChartTexts.emptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            ChartTexts.emptyDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
