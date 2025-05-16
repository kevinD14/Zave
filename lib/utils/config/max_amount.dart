// Importa utilidades para formatear y validar la entrada de texto en campos de Flutter.
import 'package:flutter/services.dart';

// Formatea la entrada de texto para limitar el monto máximo permitido.
class MaxAmountFormatter extends TextInputFormatter {
  // Monto máximo permitido para la entrada.
  static const double maxAmount = 9999.99;

  @override
  // Método que se llama cada vez que el usuario edita el campo de texto.
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Obtiene el texto actual ingresado por el usuario.
    final text = newValue.text;

    // Si hay más de un punto decimal, se rechaza el cambio.
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    // Si el valor numérico supera el máximo permitido, se rechaza el cambio.
    final parsed = double.tryParse(text);
    if (parsed != null && parsed > maxAmount) {
      return oldValue;
    }

    // Si pasa todas las validaciones, acepta el nuevo valor.
    return newValue;
  }
}
