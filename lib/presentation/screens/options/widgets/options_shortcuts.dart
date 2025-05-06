import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/widgets/shortcuts.dart';
import 'package:myapp/utils/animations/animations.dart';
import 'package:myapp/presentation/screens/options/Settings/settings_screen.dart';
import 'package:myapp/presentation/screens/options/categories/edit_categories_screen.dart';
import 'package:myapp/presentation/screens/options/debts/debts_screen.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';

class OptionsShortcuts extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  const OptionsShortcuts({super.key, this.onSettingsChanged});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ShortcutBox(
                    label: 'Gestionar\ndeudas',
                    iconPath: 'assets/icons/debt.svg',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DebtScreen(),
                        ),
                      );
                      if (result == true) {
                        setState(
                          () {},
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ShortcutBox(
                    label: 'Ajustes\nde la app',
                    iconPath: 'assets/icons/settings.svg',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final result = await Navigator.push(
                        context,
                        transition(SettingsScreen()),
                      );
                      if (result == true && context.mounted) {
                        widget.onSettingsChanged!();
                      }
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
