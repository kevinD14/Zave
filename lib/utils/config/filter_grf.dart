// Clase utilitaria para obtener rangos de fechas según diferentes filtros.
class FilterUtils {
  // Devuelve un mapa con el rango de fechas ('start' y 'end') según el tipo de filtro.
  static Map<String, DateTime> getDateRange(String filterType) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    // Determina el rango de fechas según el filtro seleccionado.
    switch (filterType) {
      case 'hoy': // Rango solo para el día de hoy.
        start = _getTodayStart();
        end = _getTodayEnd();
        break;
      case 'semana': // Rango para la semana actual.
        start = _getStartOfWeek();
        end = _getEndOfWeek();
        break;
      case 'mes': // Rango para los últimos 30 días.
        start = _getStartOfLast30Days();
        end = now;
        break;
      case 'seisMeses': // Rango para los últimos 6 meses.
        start = _getStartOfLast6Months();
        end = now;
        break;
      case 'general': // Rango amplio para mostrar todos los datos posibles.
        start = DateTime(2000);
        end = DateTime(2100);
        break;
      default: // Si el filtro no es válido, lanza una excepción.
        throw Exception('Filtro no válido');
    }

    // Retorna el mapa con la fecha de inicio y fin.
    return {'start': start, 'end': end};
  }

  // Obtiene el inicio del día actual (00:00:00).
  static DateTime _getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Obtiene el final del día actual (23:59:59).
  static DateTime _getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // Obtiene el inicio de la semana actual (lunes).
  static DateTime _getStartOfWeek() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
  }

  // Obtiene el final de la semana actual (domingo, 23:59:59).
  static DateTime _getEndOfWeek() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    ).add(Duration(days: 7 - now.weekday));
  }

  // Obtiene la fecha de inicio de los últimos 30 días.
  static DateTime _getStartOfLast30Days() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return DateTime(start.year, start.month, start.day);
  }

  // Obtiene la fecha de inicio de los últimos 6 meses.
  static DateTime _getStartOfLast6Months() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 5, 1);
  }
}
