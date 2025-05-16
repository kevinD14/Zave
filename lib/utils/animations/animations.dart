import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

// Retorna una ruta personalizada con animación de transición horizontal entre pantallas.
PageRouteBuilder transition(Widget pantalla) {
  return PageRouteBuilder(
    // Define el widget destino de la ruta.
    pageBuilder: (context, animation, secondaryAnimation) => pantalla,
    // Define la animación de transición entre pantallas.
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Utiliza una transición de eje compartido (horizontal) para la navegación.
      return SharedAxisTransition(
        animation: animation, // Animación principal de entrada/salida.
        secondaryAnimation: secondaryAnimation, // Animación secundaria.
        transitionType:
            SharedAxisTransitionType.horizontal, // Tipo de transición.
        child: child, // Widget hijo (pantalla destino).
      );
    },
  );
}
