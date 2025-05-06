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

final themeController = ThemeController(AppThemeOption.claroVerde);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting('es_ES', null);

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme') ?? 'verde';
  final initialTheme =
      {
        'verde': AppThemeOption.claroVerde,
        'azul': AppThemeOption.claroAzul,
        'oscuro': AppThemeOption.oscuro,
      }[saved]!;

  themeController.value = initialTheme;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precargarImagenes(context);
    });
  }

  void precargarImagenes(BuildContext context) {
    precacheImage(const AssetImage('assets/logo/cerdito_cool.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito_triste.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito_feliz.png'), context);
    precacheImage(const AssetImage('assets/logo/cerdito_feliz_brillo.png'), context);
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();

    final hasInsertedDefaults =
        prefs.getBool('defaultCategoriesInserted') ?? false;
    if (!hasInsertedDefaults) {
      await CategoryDatabase.instance.insertDefaultCategoriesIfEmpty();
      await prefs.setBool('defaultCategoriesInserted', true);
    }

    final seen = prefs.getBool('seenOnboarding') ?? false;
    setState(() => _seenOnboarding = seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_seenOnboarding == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

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
          home: _seenOnboarding! ? HomePage() : const OnboardingPage(),
        );
      },
    );
  }
}
