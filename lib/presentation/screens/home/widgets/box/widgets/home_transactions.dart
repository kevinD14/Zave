import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/presentation/screens/home/widgets/box/widgets/home_transactions_list.dart';
import 'package:myapp/presentation/screens/transactions_all/transactions_list_screen.dart';

// Widget que representa la sección de "Últimas transacciones" en la pantalla de inicio
class LastTransactionsSection extends StatelessWidget {
  const LastTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene el espacio inferior del teclado si está visible
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Obtiene el tema actual para aplicar estilos
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Fila con el título y el botón "Ver todas"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: const Text(
                    'Últimas transacciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Botón que navega a la pantalla de todas las transacciones
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () async {
                    HapticFeedback.lightImpact();

                    // Navegación a la pantalla de todas las transacciones
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllTransactionsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Ver todas',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contenedor con fondo y bordes redondeados donde se muestra la lista
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),

                // Widget que muestra la lista de transacciones recientes
                child: const TransactionsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
