import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String mensaje;

  const LoadingView({super.key, this.mensaje = 'Consultando sismos...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(mensaje, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
