/*Es una clase auxiliar para formatear fechas.

fechaHora() → muestra fecha y hora.

fechaCorta() → muestra solo la fecha.

tiempoTranscurrido() → indica cuánto tiempo ha pasado, por ejemplo, «hace 5 min» o «hace 2 días».

En resumen: presenta las fechas de los terremotos de forma clara y legible.*/
import 'package:intl/intl.dart';

class DateFormatterUtil {
  DateFormatterUtil._();

  static final DateFormat _fechaHora = DateFormat('dd MMM yyyy, HH:mm', 'es');
  static final DateFormat _fechaCorta = DateFormat('dd MMM yyyy', 'es');

  static String fechaHora(DateTime fecha) => _fechaHora.format(fecha);

  static String fechaCorta(DateTime fecha) => _fechaCorta.format(fecha);

  static String tiempoTranscurrido(DateTime fecha) {
    final Duration diff = DateTime.now().difference(fecha);

    if (diff.inSeconds < 60) return 'hace instantes';
    if (diff.inMinutes < 60) {
      return 'hace ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      final horas = diff.inHours;
      return 'hace $horas ${horas == 1 ? 'hora' : 'horas'}';
    }
    if (diff.inDays < 30) {
      final dias = diff.inDays;
      return 'hace $dias ${dias == 1 ? 'dia' : 'dias'}';
    }
    final meses = (diff.inDays / 30).floor();
    return 'hace $meses ${meses == 1 ? 'mes' : 'meses'}';
  }
}
