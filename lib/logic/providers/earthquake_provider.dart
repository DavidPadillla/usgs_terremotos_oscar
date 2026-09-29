/*el Provider, que controla el estado de los terremotos en la app.

cargarTerremotos() → carga los datos y maneja cargando, cargado o error.
seleccionarTerremoto() → guarda el terremoto seleccionado.
notifyListeners() → avisa a la interfaz para que se actualice.

En resumen: conecta los datos con la interfaz y controla su estado.*/

import 'package:flutter/foundation.dart';

import '../../data/models/terremoto.dart';
import '../../data/repositories/earthquake_repository.dart';
import '../../data/services/earthquake_api_service.dart';

enum EarthquakeStatus { inicial, cargando, cargado, error }

class EarthquakeProvider extends ChangeNotifier {
  final EarthquakeRepository _repository;

  EarthquakeProvider({EarthquakeRepository? repository})
      : _repository = repository ?? EarthquakeRepository();

  EarthquakeStatus _status = EarthquakeStatus.inicial;
  List<Terremoto> _terremotos = [];
  String _errorMessage = '';
  Terremoto? _seleccionado;

  EarthquakeStatus get status => _status;
  List<Terremoto> get terremotos => List.unmodifiable(_terremotos);
  String get errorMessage => _errorMessage;
  Terremoto? get seleccionado => _seleccionado;
  bool get tieneDatos => _terremotos.isNotEmpty;

  Future<void> cargarTerremotos() async {
    _status = EarthquakeStatus.cargando;
    notifyListeners();

    try {
      final resultado = await _repository.obtenerSismosRecientes();
      _terremotos = resultado;
      _status = EarthquakeStatus.cargado;
    } on EarthquakeApiException catch (e) {
      _errorMessage = e.message;
      _status = EarthquakeStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrio un error inesperado. Intenta nuevamente.';
      _status = EarthquakeStatus.error;
    }

    notifyListeners();
  }

  void seleccionarTerremoto(Terremoto terremoto) {
    _seleccionado = terremoto;
    notifyListeners();
  }
}
