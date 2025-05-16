import 'package:flutter/material.dart';

/// Pantalla que se muestra cuando una transacción es rechazada por exceder los límites permitidos.
class FundsRejectedPage extends StatelessWidget {
  /// Indica si la transacción rechazada es un ingreso (true) o un gasto/deuda (false).
  final bool isIncome;

  /// Constructor que recibe si la transacción es ingreso o gasto.
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
      body: Center(
        // Contiene el contenido principal centrado verticalmente.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de error para indicar rechazo.
            const Icon(Icons.error_outline, color: Colors.white, size: 100),
            const SizedBox(height: 20),
            // Título de la pantalla.
            const Text(
              'Transacción rechazada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Mensaje que indica el motivo del rechazo según el tipo.
            Text(
              isIncome
                  ? 'El balance no puede superar los \$9,999.99'
                  : 'El saldo no puede ser menor de \$-9,999.99',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 50),
            // Botón para volver a intentar la operación.
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
                // Vuelve a la pantalla anterior.
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

/// Pantalla que se muestra cuando una transacción se actualiza correctamente.
class FundsSuccessPage extends StatelessWidget {
  /// Constructor sin parámetros para la pantalla de éxito.
  const FundsSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        // Contiene el contenido principal centrado verticalmente.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de éxito para indicar que la operación fue correcta.
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 100,
            ),
            const SizedBox(height: 20),
            // Título de la pantalla.
            const Text(
              '¡Transacción actualizada!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Mensaje de confirmación de guardado.
            const Text(
              'Los cambios se guardaron correctamente.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 50),
            // Botón para volver al inicio de la aplicación.
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
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Volver al inicio',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
