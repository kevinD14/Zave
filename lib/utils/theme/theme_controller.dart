import 'package:flutter/material.dart';
import 'package:myapp/utils/theme/themes.dart';

/// Controlador para manejar el tema de la aplicación utilizando ValueNotifier.
/// Permite actualizar y notificar cambios del tema seleccionado en la app.
class ThemeController extends ValueNotifier<AppThemeOption> {
  // Constructor que recibe el tema inicial seleccionado.
  ThemeController(super.initial);

  // Cambia el tema actual por el tema recibido y notifica a los listeners.
  void setTheme(AppThemeOption t) {
    value = t;
  }
}
