// Importa el paquete intl para formatear fechas en distintos formatos y localizaciones.
import 'package:intl/intl.dart';

// Formatea un string de fecha (formato 'dd/MM/yyyy') a un formato largo en español.
// Si la fecha es inválida, retorna 'Fecha inválida'.
String formatDate(String date) {
  try {
    // Si el string está vacío, retorna 'Fecha inválida'.
    if (date.isEmpty) return 'Fecha inválida';
    // Intenta parsear la fecha con el formato esperado.
    final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);
    // Devuelve la fecha formateada en español, ejemplo: 5 de mayo de 2024.
    return DateFormat("d 'de' MMMM 'de' y", 'es').format(parsedDate);
  } catch (e) {
    // Si ocurre un error al parsear, retorna 'Fecha inválida'.
    return 'Fecha inválida';
  }
}

// Formatea un objeto DateTime a un string largo en español.
// Si la fecha es null, retorna 'Fecha inválida'.
String formatSelectedDate(DateTime? date) {
  // Si la fecha es null, retorna 'Fecha inválida'.
  if (date == null) return 'Fecha inválida';
  // Devuelve la fecha formateada en español, ejemplo: 5 de mayo de 2024.
  return DateFormat("d 'de' MMMM 'de' y", 'es').format(date);
}
