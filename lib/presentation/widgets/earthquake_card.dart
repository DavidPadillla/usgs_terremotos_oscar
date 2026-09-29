import 'package:flutter/material.dart';

import '../../data/models/terremoto.dart';
import '../../logic/utils/date_formatter.dart';
import 'magnitude_badge.dart';

class EarthquakeCard extends StatelessWidget {
  final Terremoto terremoto;
  final VoidCallback onTap;

  const EarthquakeCard({
    super.key,
    required this.terremoto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terremoto.lugar,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormatterUtil.fechaHora(terremoto.fecha),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MagnitudeBadge(magnitud: terremoto.magnitud),
            ],
          ),
        ),
      ),
    );
  }
}
