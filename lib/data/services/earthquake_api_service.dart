/*Es un servicio de Flutter que consulta la API de USGS para obtener información de terremotos.

Construye la URL con filtros como fecha y magnitud.
Hace la petición a la API.
Recibe y convierte los datos JSON.
Maneja errores de conexión o del servidor. */

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/app_constants.dart';

class EarthquakeApiException implements Exception {
  final String message;
  EarthquakeApiException(this.message);

  @override
  String toString() => message;
}

class EarthquakeApiService {
  final http.Client _client;

  EarthquakeApiService({http.Client? client})
      : _client = client ?? http.Client();

  Uri _buildUri({
    required DateTime startTime,
    required DateTime endTime,
    double minMagnitude = AppConstants.defaultMinMagnitude,
    String orderBy = AppConstants.defaultOrderBy,
    int limit = AppConstants.defaultLimit,
  }) {
    String formatter(DateTime date) => date.toIso8601String().split('T').first;

    return Uri.parse(AppConstants.apiBaseUrl).replace(queryParameters: {
      'format': AppConstants.apiFormat,
      'starttime': formatter(startTime),
      'endtime': formatter(endTime),
      'minmagnitude': minMagnitude.toString(),
      'orderby': orderBy,
      'limit': limit.toString(),
    });
  }

  Future<Map<String, dynamic>> fetchEarthquakes({
    required DateTime startTime,
    required DateTime endTime,
    double minMagnitude = AppConstants.defaultMinMagnitude,
    String orderBy = AppConstants.defaultOrderBy,
    int limit = AppConstants.defaultLimit,
  }) async {
    final uri = _buildUri(
      startTime: startTime,
      endTime: endTime,
      minMagnitude: minMagnitude,
      orderBy: orderBy,
      limit: limit,
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw EarthquakeApiException(
        'El servidor de USGS respondio con codigo ${response.statusCode}.',
      );
    } on EarthquakeApiException {
      rethrow;
    } catch (e) {
      throw EarthquakeApiException(
        'No fue posible conectar con la API de USGS. Verifica tu conexion '
        'a internet e intenta nuevamente.',
      );
    }
  }

  void dispose() => _client.close();
}
