import 'package:intl/intl.dart';

String formatDate(String date) {
  try {
    if (date.isEmpty) return 'Fecha inválida';
    final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);
    return DateFormat("d 'de' MMMM 'de' y", 'es').format(parsedDate);
  } catch (e) {
    return 'Fecha inválida';
  }
}

String formatSelectedDate(DateTime? date) {
  if (date == null) return 'Fecha inválida';
  return DateFormat("d 'de' MMMM 'de' y", 'es').format(date);
}
