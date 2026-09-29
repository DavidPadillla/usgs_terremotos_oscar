import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class MagnitudeBadge extends StatelessWidget {
  final double magnitud;
  final double size;

  const MagnitudeBadge({
    super.key,
    required this.magnitud,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.colorForMagnitude(magnitud);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        magnitud.toStringAsFixed(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}
