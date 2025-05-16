import 'package:flutter/material.dart';

// Pantalla que se muestra cuando se rechaza una transacción (ingreso o gasto).
class FundsRejectedPage extends StatelessWidget {
  // Variable para saber si es un ingreso o un gasto.
  final bool isIncome;

  // Constructor que requiere el valor de isIncome.
  const FundsRejectedPage({super.key, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // Cuerpo principal de la pantalla, centrado.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de advertencia.
            const Icon(Icons.error_outline, color: Colors.white, size: 100),
            const SizedBox(height: 20),

            // Texto de título.
            Text(
              'Transacción rechazada',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Mensaje dependiendo si es ingreso o gasto.
            Text(
              isIncome
                  ? 'El balance no puede superar los \$9,999.99'
                  : 'El saldo no puede ser menor de \$-9,999.99',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 50),

            // Botón para volver a intentar la transacción.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Volver a intentarlo',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
