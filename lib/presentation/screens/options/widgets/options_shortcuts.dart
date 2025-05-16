import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/widgets/shortcuts.dart';
import 'package:myapp/utils/animations/animations.dart';
import 'package:myapp/presentation/screens/options/Settings/settings_screen.dart';
import 'package:myapp/presentation/screens/options/categories/edit_categories_screen.dart';
import 'package:myapp/presentation/screens/options/debts/debts_screen.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';
import 'package:myapp/presentation/screens/options/backup/backups_screen.dart';

// Widget que muestra accesos directos a diferentes pantallas de opciones
class OptionsShortcuts extends StatefulWidget {
  const OptionsShortcuts({super.key});

  @override
  State<OptionsShortcuts> createState() => _OptionsShortcutsState();
}

class _OptionsShortcutsState extends State<OptionsShortcuts> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Fila con 3 accesos directos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Atajo para ir a la pantalla de deudas
                Flexible(
                  child: ShortcutBox(
                    label: 'Gestionar\ndeudas',
                    iconPath: 'assets/icons/debt.svg',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DebtScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Atajo para ir a la pantalla de resumen
                Flexible(
                  child: ShortcutBox(
                    label: 'Resumen\ncompleto',
                    iconPath: 'assets/icons/bar.svg',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummaryScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Atajo para editar categorías
                Flexible(
                  child: ShortcutBox(
                    label: 'Editar\nCategorias',
                    iconPath: 'assets/icons/categorias.svg',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCategoriesPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Segunda fila con 2 accesos directos
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Atajo para ir a la pantalla de respaldo de datos
                Expanded(
                  child: ShortcutBox(
                    label: 'Respaldo\nde datos',
                    iconPath: 'assets/icons/backup.svg',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BackupsPage()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Atajo para ir a los ajustes de la app
                Expanded(
                  child: ShortcutBox(
                    label: 'Ajustes\nde la app',
                    iconPath: 'assets/icons/settings.svg',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, transition(SettingsScreen()));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
