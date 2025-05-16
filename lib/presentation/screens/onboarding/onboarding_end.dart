import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/db/db_category.dart';
import 'package:myapp/presentation/screens/home/home_page.dart';

// Clase que representa la última pantalla del onboarding
class OnboardingPageEnd extends StatelessWidget {
  const OnboardingPageEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/logo/cerdito.png',
                    width: 175,
                    height: 175,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "¡Todo Listo!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                // Botón que finaliza el onboarding
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
                  'Finalizar',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
              const SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }

  // Función privada que se ejecuta al finalizar el onboarding
  void _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance(); // Accede a las preferencias del usuario
    final db = CategoryDatabase.instance; // Instancia de la base de datos de categorías

    // Verifica si las categorías predeterminadas ya se insertaron
    final inserted = prefs.getBool('defaultCategoriesInserted') ?? false;
    if (!inserted) {
      await db.insertDefaultCategoriesIfEmpty();
      await prefs.setBool('defaultCategoriesInserted', true);
    }

    // Marca que el usuario ya ha visto el onboarding
    await prefs.setBool('seenOnboarding', true);

    // Si el contexto ya no está montado, no hace nada
    if (!context.mounted) return;

    // Reemplaza la pantalla actual por la pantalla principal (HomePage)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
