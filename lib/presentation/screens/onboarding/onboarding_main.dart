import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/db/db_category.dart';
import 'package:myapp/presentation/screens/onboarding/onboarding_name.dart';

// Widget principal de la pantalla de introducción (Onboarding)
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Personaliza la apariencia de la barra de estado y navegación
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).appBarTheme.backgroundColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Theme.of(context).appBarTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), // Espacio flexible superior

              // Círculo decorativo con imagen centrada
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                  Image.asset(
                    'assets/logo/cerdito.png',
                    width: 175,
                    height: 175,
                  ),
                ],
              ),
              const Spacer(),

              // Botón para iniciar el onboarding
              ElevatedButton(
                onPressed: () => _completeOnboarding(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Iniciar',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Porque tus finanzas también\nmerecen paz interior',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // Función que se ejecuta al presionar "Iniciar"
  void _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final db = CategoryDatabase.instance;

    // Inserta las categorías por defecto si aún no se han insertado
    final inserted = prefs.getBool('defaultCategoriesInserted') ?? false;
    if (!inserted) {
      await db.insertDefaultCategoriesIfEmpty();
      await prefs.setBool('defaultCategoriesInserted', true);
    }

     // Si el contexto aún está montado, se navega a la siguiente pantalla del onboarding
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NameScreen()),
    );
  }
}
