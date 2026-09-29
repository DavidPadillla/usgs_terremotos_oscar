import 'package:flutter/material.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirExplorador(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF0A2B66),
              Color(0xFF071B3F),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'DATOS EN TIEMPO REAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 255,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            for (final size in [230.0, 178.0, 126.0])
                              Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: AppColors.magMid,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.magMid.withValues(alpha: 0.4),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.public,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const Positioned(
                              top: 19,
                              right: 22,
                              child: Icon(
                                Icons.add,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ),
                            const Positioned(
                              bottom: 18,
                              left: 16,
                              child: Icon(
                                Icons.circle,
                                color: AppColors.magLow,
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'USGS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explora la actividad sismica',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Consulta terremotos recientes en todo el mundo '
                        'con datos oficiales y actualizados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DatoRapido(
                            icono: Icons.public_outlined,
                            texto: 'Mundial',
                          ),
                          SizedBox(width: 12),
                          _DatoRapido(
                            icono: Icons.update,
                            texto: 'Actualizado',
                          ),
                          SizedBox(width: 12),
                          _DatoRapido(
                            icono: Icons.map_outlined,
                            texto: 'Con mapa',
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _abrirExplorador(context),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Explorar sismos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Fuente oficial: ${AppConstants.appName}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DatoRapido extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _DatoRapido({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: Colors.white70, size: 19),
          const SizedBox(height: 4),
          Text(
            texto,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
