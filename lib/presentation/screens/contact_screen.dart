import 'package:flutter/material.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.public, color: Colors.white, size: 36),
          ),
          SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Aplicacion academica que consume el servicio publico '
            'FDSN Event Web Service del United States Geological Survey '
            '(USGS) para consultar la actividad sismica reciente a nivel '
            'mundial.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.api, color: AppColors.primary),
            title: Text('Fuente de datos'),
            subtitle: Text('earthquake.usgs.gov/fdsnws/event/1/query'),
          ),
          ListTile(
            leading: Icon(Icons.school_outlined, color: AppColors.primary),
            title: Text('Curso'),
            subtitle: Text('Computacion Movil'),
          ),
        ],
      ),
    );
  }
}
