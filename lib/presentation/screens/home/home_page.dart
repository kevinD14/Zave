import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/presentation/screens/home/widgets/home_appbar.dart';
import 'package:myapp/presentation/screens/home/widgets/home_box.dart';
import 'package:myapp/presentation/screens/home/widgets/home_balance.dart';

// Widget de página principal que contiene la estructura general de la pantalla de inicio
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
  with SingleTickerProviderStateMixin {
  // Controlador de animación para gestionar animaciones en la página
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Inicializa el controlador de animación con duración de 600ms
    _controller = AnimationController(
      vsync: this, // Usamos el tickerProvider de este widget para las animaciones
      duration: const Duration(milliseconds: 600), // Duración de la animación
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberamos el controlador de animación al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false, // Deshabilita la capacidad de hacer pop (volver a la pantalla anterior)
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        // Muestra un cuadro de diálogo de confirmación cuando el usuario intenta salir
        final shouldExit = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('¿Salir de la app?'),
                content: Text(
                  '¿Estás seguro de que quieres salir de la aplicación?',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Sí'),
                  ),
                ],
              ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop(); // Cierra la app si el usuario confirma salir
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).appBarTheme.backgroundColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              Theme.of(context).appBarTheme.backgroundColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          appBar: CustomHomeAppBar(), // Barra de navegación personalizada
          body: Column(
            children: [
              BalanceCard(), // Widget que muestra el balance
              Expanded(
                child: const GreenBox(), // Widget principal de la pantalla con la caja
              ),
            ],
          ),
        ),
      ),
    );
  }
}
