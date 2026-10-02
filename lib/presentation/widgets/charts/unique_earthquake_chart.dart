import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/terremoto.dart';
import '../../../logic/analytics/earthquake_chart_catalog.dart';
import 'chart_presentation_helpers.dart';

class UniqueEarthquakeChart extends StatelessWidget {
  const UniqueEarthquakeChart({
    super.key,
    required this.definition,
    required this.earthquakes,
    required this.nativeChart,
  });

  final EarthquakeChartDefinition definition;
  final List<Terremoto> earthquakes;
  final Widget? nativeChart;

  @override
  Widget build(BuildContext context) {
    final data = buildChartData(definition.metric, earthquakes);
    final colors = Theme.of(context).colorScheme;
    final composition = definition.visualComposition;
    final hasNativeChart = nativeChart != null;
    final chartTypes =
        hasNativeChart
            ? [composition.second]
            : [composition.first, composition.second];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          definition.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          definition.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        const SizedBox(height: 5),
        if (nativeChart == null && definition.showSummary)
          ChartSummary(
            definition: definition,
            data: data,
            earthquakes: earthquakes,
          ),
        if (nativeChart != null) nativeChart!,
        if (hasNativeChart) ...[
          const SizedBox(height: 10),
          _LegendItem(color: colors.tertiary, label: composition.second.label),
        ] else ...[
          Wrap(
            spacing: 14,
            runSpacing: 5,
            children: [
              _LegendItem(
                color: colors.primary,
                label: composition.first.label,
              ),
              _LegendItem(
                color: colors.tertiary,
                label: composition.second.label,
              ),
            ],
          ),
        ],
        SizedBox(
          height: hasNativeChart ? 100 : 230,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1050),
            curve: Curves.easeOutCubic,
            builder:
                (context, progress, _) => CustomPaint(
                  painter: _UniqueChartPainter(
                    data: data.map((datum) => datum.value).toList(),
                    first: chartTypes.first,
                    second: hasNativeChart ? null : chartTypes.last,
                    primary: hasNativeChart ? colors.tertiary : colors.primary,
                    secondary: colors.tertiary,
                    grid: colors.outlineVariant.withValues(alpha: 0.35),
                    labelColor: colors.onSurfaceVariant,
                    progress: progress,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 7),
          ],
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _UniqueChartPainter extends CustomPainter {
  const _UniqueChartPainter({
    required this.data,
    required this.first,
    required this.second,
    required this.primary,
    required this.secondary,
    required this.grid,
    required this.labelColor,
    required this.progress,
  });

  final List<double> data;
  final ChartVisualType first;
  final ChartVisualType? second;
  final Color primary;
  final Color secondary;
  final Color grid;
  final Color labelColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0;
    const top = 10.0;
    const right = 8.0;
    const bottom = 22.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      math.max(left + 1, size.width - right),
      math.max(top + 1, size.height - bottom),
    );
    final values = _normalizedData;

    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = grid
          ..strokeWidth = 0.8,
      );
      _drawLabel(canvas, _valueLabel(i), Offset(0, y - 6));
    }

    _drawType(canvas, plot, values, first, primary, 0);
    if (second case final secondType?) {
      _drawType(canvas, plot, values, secondType, secondary, 1);
    }
    _drawLabel(canvas, 'Inicio', Offset(plot.left, plot.bottom + 5));
    _drawLabel(canvas, 'Fin', Offset(plot.right - 20, plot.bottom + 5));
  }

  List<double> get _normalizedData {
    if (data.isEmpty) return const [0.25, 0.55, 0.4, 0.8, 0.62, 0.92];
    final minimum = data.reduce((a, b) => a < b ? a : b);
    final maximum = data.reduce((a, b) => a > b ? a : b);
    final range = maximum - minimum;
    return data.take(12).map((value) {
      if (range == 0) return 0.5;
      return 0.12 + (value - minimum) / range * 0.76;
    }).toList();
  }

  String _valueLabel(int position) {
    if (data.isEmpty) return '';
    final index = (position * (data.length - 1) / 4).round();
    final value = data[index];
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  void _drawType(
    Canvas canvas,
    Rect plot,
    List<double> values,
    ChartVisualType type,
    Color color,
    int layer,
  ) {
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          plot.left + plot.width * i / math.max(1, values.length - 1),
          plot.bottom - values[i] * plot.height * progress,
        ),
    ];
    final alpha = layer == 0 ? 0.9 : 0.68;
    final stroke =
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer == 0 ? 2.8 : 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final fill =
        Paint()..color = color.withValues(alpha: layer == 0 ? 0.17 : 0.12);
    final barWidth = math.max(3.0, plot.width / values.length * 0.34);

    switch (type) {
      case ChartVisualType.line:
      case ChartVisualType.stepLine:
      case ChartVisualType.graphicLine:
        canvas.drawPath(_linePath(points, type), stroke);
        for (final point in points) {
          canvas.drawCircle(point, 2.7, Paint()..color = color);
        }
      case ChartVisualType.communityLine:
        canvas.drawPath(_linePath(points, ChartVisualType.line), stroke);
        for (var i = 0; i < points.length; i++) {
          canvas.drawCircle(points[i], 2.8, Paint()..color = color);
          if (i > 0) {
            canvas.drawLine(
              Offset(points[i - 1].dx, points[i - 1].dy - 7),
              Offset(points[i].dx, points[i].dy - 7),
              Paint()
                ..color = color.withValues(alpha: 0.36)
                ..strokeWidth = 1.4,
            );
          }
        }
      case ChartVisualType.area:
      case ChartVisualType.graphicArea:
      case ChartVisualType.stackedArea:
      case ChartVisualType.ridgeline:
      case ChartVisualType.streamgraph:
        final path =
            type == ChartVisualType.ridgeline
                ? _ridgelinePath(plot, values)
                : _areaPath(points, plot.bottom, type);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      case ChartVisualType.rangeArea:
        canvas.drawPath(_rangeAreaPath(points), fill);
        canvas.drawPath(_linePath(points, ChartVisualType.line), stroke);
        canvas.drawPath(
          _linePath([
            for (final point in points) Offset(point.dx, point.dy + 9),
          ], ChartVisualType.line),
          stroke,
        );
      case ChartVisualType.column:
      case ChartVisualType.stackedColumn:
      case ChartVisualType.rangeColumn:
      case ChartVisualType.waterfall:
        _drawColumns(
          canvas,
          plot,
          points,
          values,
          type,
          color,
          alpha,
          barWidth,
        );
      case ChartVisualType.bar:
      case ChartVisualType.graphicBars:
      case ChartVisualType.communityBars:
        _drawGroupedBars(canvas, plot, values, color, alpha);
      case ChartVisualType.stackedBar:
        _drawStackedBars(canvas, plot, values, color, alpha);
      case ChartVisualType.lollipop:
        for (final point in points) {
          canvas.drawLine(Offset(point.dx, plot.bottom), point, stroke);
          canvas.drawCircle(
            point,
            4.5,
            Paint()..color = color.withValues(alpha: alpha),
          );
        }
      case ChartVisualType.bullet:
        _drawBullet(canvas, plot, values, color, alpha);
      case ChartVisualType.heatmap:
        _drawHeatmap(canvas, plot, values, color, calendar: false);
      case ChartVisualType.boxPlot:
        _drawBoxPlots(canvas, plot, points, color, stroke);
      case ChartVisualType.violin:
        _drawViolins(canvas, plot, values, color, stroke, fill);
      case ChartVisualType.candlestick:
        _drawCandlesticks(canvas, plot, values, color, alpha);
      case ChartVisualType.scatter:
      case ChartVisualType.graphicScatter:
      case ChartVisualType.communityScatter:
      case ChartVisualType.bubble:
        _drawPoints(canvas, points, values, type, color, alpha);
      case ChartVisualType.funnel:
        _drawFunnel(canvas, plot, values, color, alpha);
      case ChartVisualType.radar:
      case ChartVisualType.polar:
        _drawRadial(canvas, plot, values, type, color, stroke, fill);
      case ChartVisualType.radialBar:
        _drawRadialBars(canvas, plot, values, color);
      case ChartVisualType.rose:
        _drawRose(canvas, plot, values, color);
      case ChartVisualType.pie:
      case ChartVisualType.communityPie:
        _drawPie(
          canvas,
          plot,
          values,
          color,
          false,
          explode: type == ChartVisualType.communityPie,
        );
      case ChartVisualType.syncfusionDoughnut:
        _drawPie(canvas, plot, values, color, true);
    }
  }

  void _drawColumns(
    Canvas canvas,
    Rect plot,
    List<Offset> points,
    List<double> values,
    ChartVisualType type,
    Color color,
    double alpha,
    double barWidth,
  ) {
    var cumulative = 0.0;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final top = switch (type) {
        ChartVisualType.waterfall =>
          plot.bottom - (cumulative += values[i] / values.length) * plot.height,
        ChartVisualType.stackedColumn =>
          plot.bottom - values[i] * plot.height * (0.55 + (i % 3) * 0.12),
        _ => point.dy,
      };
      final base =
          type == ChartVisualType.rangeColumn
              ? point.dy + plot.height * (0.12 + (i % 3) * 0.05)
              : plot.bottom;
      final rect = Rect.fromLTRB(
        point.dx - barWidth / 2,
        math.min(top, base),
        point.dx + barWidth / 2,
        math.max(top, base),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  void _drawGroupedBars(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    double alpha,
  ) {
    final rowHeight = plot.height / values.length;
    for (var i = 0; i < values.length; i++) {
      final y = plot.top + rowHeight * i;
      final firstWidth = plot.width * values[i] * 0.78;
      final secondWidth = plot.width * (1 - values[i]) * 0.58;
      for (final entry in [
        (y + rowHeight * 0.15, firstWidth, alpha),
        (y + rowHeight * 0.57, secondWidth, alpha * 0.48),
      ]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(plot.left, entry.$1, entry.$2, rowHeight * 0.28),
            const Radius.circular(3),
          ),
          Paint()..color = color.withValues(alpha: entry.$3),
        );
      }
    }
  }

  void _drawStackedBars(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    double alpha,
  ) {
    final rowHeight = plot.height / values.length;
    for (var i = 0; i < values.length; i++) {
      final y = plot.top + rowHeight * (i + 0.2);
      final firstWidth = plot.width * values[i] * 0.62;
      final secondWidth = plot.width * (0.9 - values[i] * 0.42);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(plot.left, y, firstWidth, rowHeight * 0.55),
          const Radius.circular(3),
        ),
        Paint()..color = color.withValues(alpha: alpha),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            plot.left + firstWidth,
            y,
            secondWidth,
            rowHeight * 0.55,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = color.withValues(alpha: alpha * 0.42),
      );
    }
  }

  void _drawPoints(
    Canvas canvas,
    List<Offset> points,
    List<double> values,
    ChartVisualType type,
    Color color,
    double alpha,
  ) {
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      if (type == ChartVisualType.communityScatter) {
        const radius = 4.0;
        final diamond =
            Path()
              ..moveTo(point.dx, point.dy - radius)
              ..lineTo(point.dx + radius, point.dy)
              ..lineTo(point.dx, point.dy + radius)
              ..lineTo(point.dx - radius, point.dy)
              ..close();
        canvas.drawPath(
          diamond,
          Paint()..color = color.withValues(alpha: alpha),
        );
      } else {
        final isBubble = type == ChartVisualType.bubble;
        final isGraphic = type == ChartVisualType.graphicScatter;
        final radius = isBubble ? 3 + values[i] * 8 : (isGraphic ? 4.2 : 3.2);
        canvas.drawCircle(
          Offset(point.dx, point.dy + (isGraphic ? (i.isEven ? -4 : 4) : 0)),
          radius,
          Paint()
            ..color = color.withValues(alpha: isBubble ? 0.24 : alpha)
            ..style = isBubble ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }
    }
  }

  void _drawBullet(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    double alpha,
  ) {
    final rowHeight = plot.height / values.length;
    for (var i = 0; i < values.length; i++) {
      final y = plot.top + rowHeight * (i + 0.5);
      final width = plot.width * values[i] * 0.86;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(plot.left, y - 4, width, 8),
          const Radius.circular(4),
        ),
        Paint()..color = color.withValues(alpha: alpha * 0.36),
      );
      final target = plot.left + plot.width * (0.48 + (i % 4) * 0.12);
      canvas.drawLine(
        Offset(target, y - 7),
        Offset(target, y + 7),
        Paint()
          ..color = color
          ..strokeWidth = 2,
      );
    }
  }

  void _drawHeatmap(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color, {
    required bool calendar,
  }) {
    final columns = calendar ? 7 : math.max(2, math.sqrt(values.length).ceil());
    final rows = (values.length / columns).ceil();
    final gap = calendar ? 2.0 : 4.0;
    final cellWidth = (plot.width - gap * (columns - 1)) / columns;
    final cellHeight = (plot.height - gap * (rows - 1)) / rows;
    for (var i = 0; i < values.length; i++) {
      final column = i % columns;
      final row = i ~/ columns;
      final rect = Rect.fromLTWH(
        plot.left + column * (cellWidth + gap),
        plot.top + row * (cellHeight + gap),
        cellWidth,
        cellHeight,
      );
      final opacity = 0.15 + values[i] * 0.82;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(calendar ? 3 : 7)),
        Paint()..color = color.withValues(alpha: opacity),
      );
      if (!calendar && rect.width > 30 && rect.height > 22) {
        _drawLabel(
          canvas,
          values[i].toStringAsFixed(1),
          rect.topLeft + const Offset(4, 3),
        );
      }
    }
  }

  void _drawBoxPlots(
    Canvas canvas,
    Rect plot,
    List<Offset> points,
    Color color,
    Paint stroke,
  ) {
    final width = math.max(7.0, plot.width / points.length * 0.46);
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final spread = 8 + (i % 4) * 2.0;
      final top = math.max(plot.top, point.dy - spread);
      final bottom = math.min(plot.bottom, point.dy + spread);
      final box = Rect.fromLTRB(
        point.dx - width / 2,
        point.dy - spread * 0.4,
        point.dx + width / 2,
        point.dy + spread * 0.4,
      );
      canvas.drawLine(Offset(point.dx, top), Offset(point.dx, bottom), stroke);
      canvas.drawLine(
        Offset(point.dx - width * 0.32, top),
        Offset(point.dx + width * 0.32, top),
        stroke,
      );
      canvas.drawLine(
        Offset(point.dx - width * 0.32, bottom),
        Offset(point.dx + width * 0.32, bottom),
        stroke,
      );
      canvas.drawRect(box, Paint()..color = color.withValues(alpha: 0.22));
      canvas.drawRect(box, stroke);
      canvas.drawLine(
        Offset(box.left, point.dy),
        Offset(box.right, point.dy),
        Paint()
          ..color = color
          ..strokeWidth = 2,
      );
    }
  }

  void _drawViolins(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    Paint stroke,
    Paint fill,
  ) {
    final slot = plot.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final center = Offset(
        plot.left + slot * (i + 0.5),
        plot.bottom - values[i] * plot.height,
      );
      final width = slot * (0.2 + values[i] * 0.24);
      final height = 7 + values[i] * 11;
      final path =
          Path()
            ..moveTo(center.dx, center.dy - height)
            ..cubicTo(
              center.dx + width,
              center.dy - height * 0.6,
              center.dx + width,
              center.dy + height * 0.6,
              center.dx,
              center.dy + height,
            )
            ..cubicTo(
              center.dx - width,
              center.dy + height * 0.6,
              center.dx - width,
              center.dy - height * 0.6,
              center.dx,
              center.dy - height,
            )
            ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      canvas.drawLine(
        Offset(center.dx - width * 0.45, center.dy),
        Offset(center.dx + width * 0.45, center.dy),
        stroke,
      );
    }
  }

  void _drawCandlesticks(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    double alpha,
  ) {
    final spacing = plot.width / values.length;
    final width = math.max(4.0, spacing * 0.48);
    for (var i = 0; i < values.length; i++) {
      final centerX = plot.left + spacing * (i + 0.5);
      final centerY = plot.bottom - values[i] * plot.height;
      final delta = (i.isEven ? 1 : -1) * (6 + (i % 3) * 3.0);
      final open = centerY - delta;
      final close = centerY + delta;
      canvas.drawLine(
        Offset(centerX, centerY - 13),
        Offset(centerX, centerY + 13),
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..strokeWidth = 1.4,
      );
      final body = Rect.fromLTRB(
        centerX - width / 2,
        math.min(open, close),
        centerX + width / 2,
        math.max(open, close),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, const Radius.circular(2)),
        Paint()
          ..color = color.withValues(alpha: i.isEven ? alpha : 0.2)
          ..style = i.isEven ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  void _drawFunnel(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    double alpha,
  ) {
    for (var i = 0; i < values.length; i++) {
      final centerX = plot.center.dx;
      final rowHeight = plot.height / values.length;
      final halfWidth = plot.width * (0.42 - i / values.length * 0.34);
      final top = plot.top + rowHeight * i;
      final bottom = top + rowHeight * 0.9;
      final path =
          Path()
            ..moveTo(centerX - halfWidth, top)
            ..lineTo(centerX + halfWidth, top)
            ..lineTo(centerX + halfWidth * 0.84, bottom)
            ..lineTo(centerX - halfWidth * 0.84, bottom)
            ..close();
      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: alpha - i * 0.025),
      );
    }
  }

  Path _ridgelinePath(Rect plot, List<double> values) {
    final path = Path();
    for (var ridge = 0; ridge < 3; ridge++) {
      final baseline = plot.top + plot.height * (ridge + 1) / 3.2;
      path.moveTo(plot.left, baseline);
      for (var i = 0; i < values.length; i++) {
        final x = plot.left + plot.width * i / math.max(1, values.length - 1);
        path.lineTo(x, baseline - values[i] * plot.height * 0.19);
      }
      path.lineTo(plot.right, baseline);
      path.close();
    }
    return path;
  }

  void _drawPie(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
    bool isDonut, {
    bool explode = false,
  }) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final radius = math.min(plot.width, plot.height) * 0.4;
    final center = plot.center;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      final sliceCenter = start + sweep / 2;
      final offset =
          explode
              ? Offset(math.cos(sliceCenter) * 5, math.sin(sliceCenter) * 5)
              : Offset.zero;
      final slicePaint =
          Paint()
            ..color =
                HSLColor.fromColor(color)
                    .withHue((HSLColor.fromColor(color).hue + i * 34) % 360)
                    .toColor()
            ..style = isDonut ? PaintingStyle.stroke : PaintingStyle.fill
            ..strokeWidth = isDonut ? radius * 0.42 : 1;
      canvas.drawArc(
        Rect.fromCircle(center: center + offset, radius: radius),
        start,
        sweep,
        !isDonut,
        slicePaint,
      );
      start += sweep;
    }
  }

  void _drawRose(Canvas canvas, Rect plot, List<double> values, Color color) {
    final center = plot.center;
    final radius = math.min(plot.width, plot.height) * 0.42;
    final sweep = 2 * math.pi / values.length * 0.82;
    for (var i = 0; i < values.length; i++) {
      final start = -math.pi / 2 + 2 * math.pi * i / values.length;
      final path =
          Path()
            ..moveTo(center.dx, center.dy)
            ..arcTo(
              Rect.fromCircle(
                center: center,
                radius: radius * values[i] * progress,
              ),
              start,
              sweep,
              false,
            )
            ..close();
      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: 0.28 + values[i] * 0.65),
      );
    }
  }

  Path _linePath(List<Offset> points, ChartVisualType type) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final point = points[i];
      switch (type) {
        case ChartVisualType.stepLine:
          path
            ..lineTo(point.dx, previous.dy)
            ..lineTo(point.dx, point.dy);
        default:
          path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  Path _areaPath(List<Offset> points, double baseline, ChartVisualType type) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      final stackedOffset =
          type == ChartVisualType.stackedArea ? 10 + (i % 3) * 3 : 0;
      path.lineTo(point.dx, point.dy - stackedOffset);
    }
    return path
      ..lineTo(points.last.dx, baseline)
      ..lineTo(points.first.dx, baseline)
      ..close();
  }

  Path _rangeAreaPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy - 9);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy - 9);
    }
    for (final point in points.reversed) {
      path.lineTo(point.dx, point.dy + 9);
    }
    return path..close();
  }

  void _drawRadial(
    Canvas canvas,
    Rect plot,
    List<double> values,
    ChartVisualType type,
    Color color,
    Paint stroke,
    Paint fill,
  ) {
    final center = plot.center;
    final radius = math.min(plot.width, plot.height) * 0.34;
    for (var ring = 1; ring <= 3; ring++) {
      canvas.drawCircle(
        center,
        radius * ring / 3,
        Paint()
          ..color = grid
          ..style = PaintingStyle.stroke,
      );
    }
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final angle = -math.pi / 2 + 2 * math.pi * i / values.length;
      final scale =
          type == ChartVisualType.polar
              ? 0.38 + values[i] * 0.58
              : 0.25 + values[i] * 0.72 * progress;
      final point = Offset(
        center.dx + math.cos(angle) * radius * scale,
        center.dy + math.sin(angle) * radius * scale,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      if (type == ChartVisualType.polar) {
        canvas.drawLine(
          center,
          point,
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..strokeWidth = 1.2,
        );
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawRadialBars(
    Canvas canvas,
    Rect plot,
    List<double> values,
    Color color,
  ) {
    final center = plot.center;
    final radius = math.min(plot.width, plot.height) * 0.22;
    for (var i = 0; i < values.length; i++) {
      final start = -math.pi / 2 + 2 * math.pi * i / values.length;
      final sweep = 2 * math.pi / values.length * 0.72 * values[i] * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.35 + values[i] * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(center, 3, Paint()..color = color);
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: labelColor, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 34);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _UniqueChartPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.first != first ||
      oldDelegate.second != second ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.progress != progress;
}
