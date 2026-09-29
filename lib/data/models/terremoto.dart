/*Es el modelo Terremoto que representa los datos de un terremoto.

Guarda datos como magnitud, lugar, fecha, coordenadas y profundidad.
fromJson() convierte los datos de la API en un objeto Terremoto.
listFromGeoJson() convierte una lista de terremotos en varios objetos.
En resumen: recibe los datos de la API y los organiza para usarlos fácilmente en la app.*/

class Terremoto {
  final String id;
  final double magnitud;
  final String lugar;
  final DateTime fecha;
  final double latitud;
  final double longitud;
  final double profundidad;
  final String tipo;
  final String revisiones;
  final String fuente;
  final String url;
  final String titulo;

  const Terremoto({
    required this.id,
    required this.magnitud,
    required this.lugar,
    required this.fecha,
    required this.latitud,
    required this.longitud,
    required this.profundidad,
    required this.tipo,
    required this.revisiones,
    required this.fuente,
    required this.url,
    required this.titulo,
  });

  factory Terremoto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> props =
        json['properties'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> geometry =
        json['geometry'] as Map<String, dynamic>? ?? {};
    final List<dynamic> coords =
        geometry['coordinates'] as List<dynamic>? ?? [0, 0, 0];

    return Terremoto(
      id: json['id']?.toString() ?? '',
      magnitud: (props['mag'] as num?)?.toDouble() ?? 0.0,
      lugar: props['place']?.toString() ?? 'Ubicacion desconocida',
      fecha: DateTime.fromMillisecondsSinceEpoch(
        (props['time'] as num?)?.toInt() ?? 0,
      ),
      longitud: (coords.isNotEmpty ? coords[0] as num? : 0)?.toDouble() ?? 0,
      latitud: (coords.length > 1 ? coords[1] as num? : 0)?.toDouble() ?? 0,
      profundidad:
          (coords.length > 2 ? coords[2] as num? : 0)?.toDouble() ?? 0,
      tipo: props['type']?.toString() ?? 'earthquake',
      revisiones: props['status']?.toString() ?? 'desconocido',
      fuente: props['net']?.toString() ?? 'usgs',
      url: props['url']?.toString() ?? '',
      titulo: props['title']?.toString() ?? '',
    );
  }

  static List<Terremoto> listFromGeoJson(Map<String, dynamic> geoJson) {
    final List<dynamic> features =
        geoJson['features'] as List<dynamic>? ?? [];
    return features
        .map((f) => Terremoto.fromJson(f as Map<String, dynamic>))
        .toList();
  }
}
