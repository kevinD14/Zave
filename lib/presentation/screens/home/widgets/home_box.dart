import 'package:flutter/material.dart';
import 'package:myapp/presentation/screens/home/widgets/box/widgets/home_shortcuts.dart';
import 'package:myapp/presentation/screens/home/widgets/box/widgets/home_transactions.dart';

// Widget sin estado que representa una caja en la parte inferior de la pantalla
class GreenBox extends StatelessWidget {
  const GreenBox({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Obtiene el espacio que ocupa el teclado (u otras vistas del sistema) en la parte inferior
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          // Padding animado para suavizar el movimiento cuando aparece o desaparece el teclado
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              // Previene el rebote al hacer scroll
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                // Asegura que la caja ocupe al menos todo el alto disponible
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 20),
                      HomeShortcuts(),
                      SizedBox(height: 8),
                      LastTransactionsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
