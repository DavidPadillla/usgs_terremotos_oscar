import 'package:community_charts_flutter/community_charts_flutter.dart'
    as community;
import 'package:flutter/material.dart';

import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'chart_presentation_helpers.dart';

class CommunityEarthquakeChart extends StatelessWidget {
  const CommunityEarthquakeChart({
    super.key,
    required this.definition,
    required this.earthquakes,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;

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

    final chart = switch (definition.style) {
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
          _series(data),
          animate: true,
          barGroupingType: community.BarGroupingType.grouped,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (definition.showSummary)
          ChartSummary(
            definition: definition,
            data: data,
            earthquakes: earthquakes,
          ),
        const SizedBox(height: 8),
        SizedBox(height: 280, child: chart),
      ],
    );
  }

  List<community.Series<EarthquakeChartDatum, String>> _series(
    List<EarthquakeChartDatum> data,
  ) {
    final grouped = data.map((datum) => datum.series).toSet()
      ..removeWhere((series) => series.isEmpty);
    if (grouped.isNotEmpty) {
      return [
        for (final name in grouped)
          community.Series<EarthquakeChartDatum, String>(
            id: name,
            data: data.where((datum) => datum.series == name).toList(),
            domainFn: (datum, _) => datum.label,
            measureFn: (datum, _) => datum.value,
          ),
      ];
    }

    if (definition.style == ChartStyle.combo) {
      final secondary = data
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
          id: 'Eventos',
          data: data,
          domainFn: (datum, _) => datum.label,
          measureFn: (datum, _) => datum.value,
        ),
        community.Series<EarthquakeChartDatum, String>(
          id: 'Medida secundaria',
          data: secondary,
          domainFn: (datum, _) => datum.label,
          measureFn: (datum, _) => datum.value,
        ),
      ];
    }

    return [
      community.Series<EarthquakeChartDatum, String>(
        id: definition.title,
        data: data,
        domainFn: (datum, _) => datum.label,
        measureFn: (datum, _) => datum.value,
      ),
    ];
  }
}
