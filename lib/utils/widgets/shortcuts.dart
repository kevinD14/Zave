import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Widget personalizado que representa un acceso directo visual (botón grande con ícono y etiqueta).
class ShortcutBox extends StatelessWidget {
  // Etiqueta que se muestra debajo del ícono.
  final String label;
  // Ruta del archivo SVG que se usará como ícono.
  final String iconPath;
  // Función que se ejecuta al tocar el acceso directo.
  final VoidCallback onTap;

  // Constructor que recibe la etiqueta, el ícono y la función de tap.
  const ShortcutBox({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  // Construye el widget visual del acceso directo.
  @override
  Widget build(BuildContext context) {
    // InkWell permite detectar el tap y mostrar un efecto visual.
    return InkWell(
      onTap: onTap, // Ejecuta la función al tocar el widget.
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 100, // Ancho fijo del acceso directo.
        height: 135, // Alto fijo del acceso directo.
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondary, // Color de fondo según el tema.
          borderRadius: BorderRadius.circular(18), // Bordes redondeados.
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Muestra el ícono SVG centrado.
            SvgPicture.asset(
              iconPath,
              width: 38,
              height: 38,
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el ícono y la etiqueta.
            // Muestra la etiqueta debajo del ícono.
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
