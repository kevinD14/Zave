class FilterUtils {
  static Map<String, DateTime> getDateRange(String filterType) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (filterType) {
      case 'hoy':
        start = _getTodayStart();
        end = _getTodayEnd();
        break;
      case 'semana':
        start = _getStartOfWeek();
        end = _getEndOfWeek();
        break;
      case 'mes':
        start = _getStartOfLast30Days();
        end = now;
        break;
      case 'seisMeses':
        start = _getStartOfLast6Months();
        end = now;
        break;
      case 'general':
        start = DateTime(2000);
        end = DateTime(2100);
        break;
      default:
        throw Exception('Filtro no válido');
    }

    return {'start': start, 'end': end};
  }

  static DateTime _getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  static DateTime _getStartOfWeek() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
  }

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

  static DateTime _getStartOfLast30Days() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return DateTime(start.year, start.month, start.day);
  }

  static DateTime _getStartOfLast6Months() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 5, 1);
  }
}
