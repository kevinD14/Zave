import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/presentation/screens/options/widgets/options_appbar.dart';
import 'package:myapp/presentation/screens/options/widgets/cerdito_con_globo.dart';
import 'package:myapp/presentation/screens/options/widgets/options_shortcuts.dart';

// Pantalla de opciones adicionales
class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  State<MoreOptionsScreen> createState() => _MoreOptionsScreenState();
}

class _MoreOptionsScreenState extends State<MoreOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Establece el estilo de la barra de estado y navegación para que coincida con el color del AppBar
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).appBarTheme.backgroundColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Theme.of(context).appBarTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: const CustomOptionsAppBar(), // AppBar personalizado
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                CerditoConGlobo(), // Widget decorativo
                SizedBox(height: 20),
                OptionsShortcuts(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
