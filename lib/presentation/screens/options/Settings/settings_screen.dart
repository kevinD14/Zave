import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/db/db_name.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/theme/themes.dart';
import 'package:myapp/utils/config/event_bus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppThemeOption _currentTheme = AppThemeOption.claroVerde;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme') ?? 'verde';
    setState(() {
      _currentTheme =
          {
            'verde': AppThemeOption.claroVerde,
            'azul': AppThemeOption.claroAzul,
            'oscuro': AppThemeOption.oscuro,
          }[saved]!;
    });
  }

  Future<void> _saveTheme(AppThemeOption theme) async {
    final prefs = await SharedPreferences.getInstance();
    final str =
        {
          AppThemeOption.claroVerde: 'verde',
          AppThemeOption.claroAzul: 'azul',
          AppThemeOption.oscuro: 'oscuro',
        }[theme]!;
    await prefs.setString('theme', str);
  }

  void _selectTheme(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Selecciona un tema',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  AppThemeOption.values.map((opt) {
                    final label =
                        {
                          AppThemeOption.claroVerde: 'Claro Verde',
                          AppThemeOption.claroAzul: 'Claro Azul',
                          AppThemeOption.oscuro: 'Oscuro',
                        }[opt]!;
                    return ListTile(
                      title: Text(
                        label,
                        style: const TextStyle(color: Colors.white),
                      ),
                      selected: _currentTheme == opt,
                      onTap: () {
                        setState(() => _currentTheme = opt);
                        _saveTheme(opt);
                        themeController.setTheme(opt);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _editUsername(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String newName = '';

        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Editar nombre de usuario',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            autofocus: true,
            onChanged: (v) => newName = v.trim(),
            decoration: const InputDecoration(
              hintText: 'Nuevo nombre',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            cursorColor: Colors.white,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newName.isEmpty) return;

                final navigator = Navigator.of(dialogContext);

                await db.saveName(newName);
                EventBus().notifyUsernameUpdated();

                navigator.pop(true);
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    String title,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              '¿Estás seguro?',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Esta acción eliminará $title. ¿Deseas continuar?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

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
        appBar: AppBar(
          title: const Text('Ajustes'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Nombre de usuario',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Toca para editar',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              onTap: () => _editUsername(context),
            ),
            const SizedBox(height: 32),
            const Text(
              'Preferencias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.white),
              title: const Text(
                'Seleccionar tema',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                {
                  AppThemeOption.claroVerde: 'Claro Verde',
                  AppThemeOption.claroAzul: 'Claro Azul',
                  AppThemeOption.oscuro: 'Oscuro',
                }[_currentTheme]!,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              onTap: () => _selectTheme(context),
            ),
            const SizedBox(height: 32),
            const Text(
              'Datos y almacenamiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.white),
              title: const Text(
                'Borrar todas las transacciones',
                style: TextStyle(color: Colors.white),
              ),
              onTap:
                  () => _confirmDelete(
                    context,
                    'todas las transacciones',
                    () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      await TransactionDB().deleteAllTransactions();
                      EventBus().notifyTransactionsUpdated();

                      if (!mounted) return;

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            '¡Todas las transacciones han sido eliminadas!',
                          ),
                        ),
                      );

                      await Future.delayed(const Duration(milliseconds: 600));

                      if (mounted) {
                        navigator.pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      }
                    },
                  ),
            ),
            const SizedBox(height: 320),
            const Padding(
              padding: EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Zave v1.0.4 (17)',
                  style: TextStyle(fontSize: 13, color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
