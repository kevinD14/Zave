import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/animations/animations.dart';
import 'package:myapp/utils/widgets/shortcuts.dart';
import 'package:myapp/presentation/screens/transactions/income/add_funds_screen.dart';
import 'package:myapp/presentation/screens/transactions/expense/subtract_funds_screen.dart';
import 'package:myapp/presentation/screens/options/more_options_screen.dart';

class HomeShortcuts extends StatelessWidget {
  final VoidCallback? onTransactionsChanged;
  const HomeShortcuts({super.key, this.onTransactionsChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ShortcutBox(
              label: 'Añadir\nFondos',
              iconPath: 'assets/icons/paid.svg',
              onTap: () async {
                HapticFeedback.lightImpact();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFundsPage()),
                );
                if (result == true && onTransactionsChanged != null) {
                  onTransactionsChanged!();
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: ShortcutBox(
              label: 'Añadir\nGastos',
              iconPath: 'assets/icons/pay.svg',
              onTap: () async {
                HapticFeedback.lightImpact();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpensePage(),
                  ),
                );
                if (result == true && onTransactionsChanged != null) {
                  onTransactionsChanged!();
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: ShortcutBox(
              label: 'Más\nopciones',
              iconPath: 'assets/icons/options.svg',
              onTap: () async {
                HapticFeedback.lightImpact();
                final result = await Navigator.push(
                  context,
                  transition(MoreOptionsScreen()),
                );
                if (result == true && onTransactionsChanged != null) {
                  onTransactionsChanged!();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
