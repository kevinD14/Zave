import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/presentation/screens/onboarding/onboarding_main.dart';
import 'package:myapp/presentation/screens/home/home_page.dart';
import 'package:myapp/utils/db/db_category.dart';
import 'package:myapp/utils/theme/themes.dart';
import 'package:myapp/utils/theme/theme_controller.dart';

// Se inicializa el controlador del tema con un valor por defecto (verde claro)
final themeController = ThemeController(AppThemeOption.claroVerde);

void main() async {
  // Se asegura de que Flutter esté completamente inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Se bloquea la orientación del dispositivo a modo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Se inicializan los símbolos de fecha para la localización en español
  await initializeDateFormatting('es_ES', null);

  // Se obtiene la preferencia del tema guardada por el usuario
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme') ?? 'verde';

  // Se asigna el tema inicial según la preferencia guardada
  final initialTheme = {
    'verde': AppThemeOption.claroVerde,
    'azul': AppThemeOption.claroAzul,
    'oscuro': AppThemeOption.oscuro,
  }[saved]!;

  themeController.value = initialTheme;

  // Se inicia la aplicación
  runApp(const MyApp());
}

// Widget principal de la app
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Variable para saber si el usuario ya vio el onboarding
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _initializeApp(); // Carga inicial de datos y preferencias

    // Precarga las imágenes al finalizar el primer frame para mejorar rendimiento
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precargarImagenes(context);
    });
  }

  // Precarga de imágenes para que estén disponibles al instante al usarlas
  void precargarImagenes(BuildContext context) {
    precacheImage(const AssetImage('assets/logo/cerdito_cool.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito_triste.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito_feliz.png'), context);
    precacheImage(
      const AssetImage('assets/logo/cerdito_feliz_brillo.png'),
      context,
    );
    precacheImage(const AssetImage('assets/logo/drive.png'), context);
    precacheImage(const AssetImage('assets/logo/google.png'), context);
  }

  // Inicialización de configuración al arrancar la app
  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();

    // Inserta categorías por defecto si no se han insertado aún
    final hasInsertedDefaults =
        prefs.getBool('defaultCategoriesInserted') ?? false;
    if (!hasInsertedDefaults) {
      await CategoryDatabase.instance.insertDefaultCategoriesIfEmpty();
      await prefs.setBool('defaultCategoriesInserted', true);
    }

    // Revisa si el usuario ya ha visto el onboarding
    final seen = prefs.getBool('seenOnboarding') ?? false;
    setState(() => _seenOnboarding = seen);
  }

  @override
  Widget build(BuildContext context) {
    // Mientras no se haya determinado si mostrar onboarding o no
    if (_seenOnboarding == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black, // Fondo negro
          body: Center(
            child: Container(), // solo el fondo
          ),
        ),
      );
    }

    // Construcción principal de la app con cambio dinámico de tema
    return ValueListenableBuilder<AppThemeOption>(
      valueListenable: themeController,
      builder: (context, themeOpt, _) {
        return MaterialApp(
          routes: {'/home': (context) => HomePage()},
          debugShowCheckedModeBanner: false,
          theme: AppThemes.getTheme(themeOpt),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES')],

          // Muestra el onboarding si es la primera vez, si no, va a la pantalla principal
          home: _seenOnboarding! ? const HomePage() : const OnboardingPage(),
        );
      },
    );
  }
}
