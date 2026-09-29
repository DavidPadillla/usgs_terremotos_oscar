import 'package:flutter/material.dart';

import 'contact_screen.dart';
import 'analytics_screen.dart';
import 'earthquake_list_screen.dart';
import 'earthquake_map_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = const [
    EarthquakeListScreen(),
    EarthquakeMapScreen(),
    AnalyticsScreen(),
    ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceActual, children: _pantallas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Gráficas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail_outlined),
            label: 'Contacto',
          ),
        ],
      ),
    );
  }
}
