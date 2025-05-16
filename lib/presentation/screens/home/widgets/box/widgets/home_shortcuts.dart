import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/animations/animations.dart';
import 'package:myapp/utils/widgets/shortcuts.dart';
import 'package:myapp/presentation/screens/transactions/income/add_funds_screen.dart';
import 'package:myapp/presentation/screens/transactions/expense/subtract_funds_screen.dart';
import 'package:myapp/presentation/screens/options/more_options_screen.dart';

// Widget sin estado (StatelessWidget) que representa los accesos rápidos en la pantalla principal.
class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Espaciado horizontal para los accesos directos
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        // Distribuye los botones uniformemente con espacio entre ellos
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Primer acceso directo: Añadir Ingresos
          Flexible(
            child: ShortcutBox(
              label: 'Añadir\nIngresos',
              iconPath: 'assets/icons/paid.svg',
              onTap: () async {
                HapticFeedback.lightImpact(); // Vibración leve al pulsar
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFundsPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          // Segundo acceso directo: Añadir Gastos
          Flexible(
            child: ShortcutBox(
              label: 'Añadir\nGastos',
              iconPath: 'assets/icons/pay.svg',
              onTap: () async {
                HapticFeedback.lightImpact(); // Vibración leve al pulsar
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpensePage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          // Tercer acceso directo: Más opciones
          Flexible(
            child: ShortcutBox(
              label: 'Más\nopciones',
              iconPath: 'assets/icons/options.svg',
              onTap: () async {
                HapticFeedback.lightImpact(); // Vibración leve al pulsar

                // Usa animación personalizada para abrir la pantalla de opciones
                await Navigator.push(
                  context,
                  transition(MoreOptionsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
