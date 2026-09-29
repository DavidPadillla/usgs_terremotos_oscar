/*Es el repositorio que conecta la API con la aplicación.

Pide los sismos recientes a la API.
Define el rango de días, magnitud mínima y límite.
Convierte la respuesta en una lista de objetos Terremoto.

En resumen: obtiene los terremotos de la API y los prepara para que la app los pueda usar.*/

import '../../config/app_constants.dart';
import '../models/terremoto.dart';
import '../services/earthquake_api_service.dart';

class EarthquakeRepository {
  final EarthquakeApiService _apiService;

  EarthquakeRepository({EarthquakeApiService? apiService})
      : _apiService = apiService ?? EarthquakeApiService();

  Future<List<Terremoto>> obtenerSismosRecientes({
    int rangoEnDias = AppConstants.defaultRangeInDays,
    double magnitudMinima = AppConstants.defaultMinMagnitude,
    int limite = AppConstants.defaultLimit,
  }) async {
    final DateTime ahora = DateTime.now();
    final DateTime desde = ahora.subtract(Duration(days: rangoEnDias));

    final Map<String, dynamic> json = await _apiService.fetchEarthquakes(
      startTime: desde,
      endTime: ahora,
      minMagnitude: magnitudMinima,
      limit: limite,
    );

    return Terremoto.listFromGeoJson(json);
  }
}
