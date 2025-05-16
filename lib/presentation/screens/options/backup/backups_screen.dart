import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as cp;
import 'package:myapp/utils/db/services/backup_service.dart';
import 'package:myapp/utils/db/services/google_sign_in.dart';
import 'package:myapp/presentation/screens/options/backup/term.dart';

// Pantalla de respaldo de datos con Google Drive
class BackupsPage extends StatefulWidget {
  const BackupsPage({super.key});

  @override
  State<BackupsPage> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupsPage> {
  // Variables para guardar información de la cuenta de Google
  String _userEmail = '';
  String _userPhoto = '';
  bool _termsAccepted = false; // Indica si el usuario aceptó los términos

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Carga la información del usuario al iniciar la pantalla
  }

  // Función para verificar si hay conexión a Internet
  Future<bool> verificarConexion(BuildContext context) async {
    final List<cp.ConnectivityResult> results =
        await cp.Connectivity().checkConnectivity();

    // Si no hay ningún tipo de conexión
    if (results.contains(cp.ConnectivityResult.none)) {
      if (context.mounted) {
        // Muestra un diálogo informando al usuario que no hay conexión
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Sin conexión a Internet',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'No hay conexión a Internet. Verifica tu conexión y vuelve a intentarlo.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
      return false; // Retorna falso si no hay conexión
    }
    return true; // Retorna verdadero si hay conexión
  }

  // Función para mostrar un diálogo genérico de error
  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // No permite cerrar el diálogo tocando fuera
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text('¡Error!', style: TextStyle(color: Colors.white)),
            content: Text(
              "Ocurrió un error desconocido.",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // Carga la información del usuario almacenada previamente en preferencias
  Future<void> _loadUserInfo() async {
    final info = await UserPreferences.loadUserInfo(); // Obtiene los datos del usuario

    // Si hay un correo electrónico guardado, actualiza el estado con la info
    if (info['userEmail']!.isNotEmpty) {
      setState(() {
        _userEmail = info['userEmail']!;
        _userPhoto = info['userPhoto']!;
      });
    }
  }

  // Inicia sesión con Google y guarda la información del usuario
  Future<void> _signIn() async {
    if (!await verificarConexion(context)) return;

    if (!mounted) return;

    // Muestra un diálogo de carga mientras se realiza el inicio de sesión
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            content: Row(
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Iniciando sesión...\nPor favor espere.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );

    try {
      // Intenta iniciar sesión con Google
      final account = await BackupService.signInWithGoogle();

      if (!mounted) return;

      // Cierra el diálogo de carga
      Navigator.pop(context);

      if (account != null) {
        // Si el inicio de sesión fue exitoso, guarda la información del usuario
        await UserPreferences.saveUserInfo(
          name: account.displayName ?? '',
          userEmail: account.email,
          userPhoto: account.photoUrl ?? '',
        );

        // Actualiza el estado con la nueva información
        setState(() {
          _userEmail = account.email;
          _userPhoto = account.photoUrl ?? '';
        });
      } else {
        // Si no se obtuvo una cuenta, muestra un error
        Navigator.pop(context);
        _showErrorDialog();
      }
    } catch (e) {
      // En caso de error inesperado, cierra el diálogo y muestra error
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorDialog();
    }
  }

  // Cierra sesión del usuario y limpia la información guardada
  Future<void> _signOut() async {
    await BackupService.signOutFromGoogle(); // Cierra sesión de Google
    await UserPreferences.clearUserInfo(); // Elimina info local del usuario
    setState(() {
      _userEmail = ''; // Restablece las variables del estado
      _userPhoto = '';
    });
  }

  Future<void> _upload() async {
    // Solicita confirmación del usuario antes de subir la copia
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              '¿Realizar copia de seguridad?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Esta acción reemplazará los datos previamente guardados en su cuenta de Google Drive.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm != true) return; // Si no acepta, salir

    if (!mounted) return;
    if (!await verificarConexion(context)) return; // Verifica conexión a Internet

    if (!mounted) return;

    // Muestra diálogo de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            content: Row(
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Subiendo copia de seguridad...\nPor favor espere.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
    );

    try {
      // Realiza la subida a Drive
      await BackupService.uploadBackupToDrive();

      if (!mounted) return;

      Navigator.pop(context); // Cierra el diálogo de progreso

      if (!mounted) return;

      // Muestra mensaje de éxito
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text(
                '¡Copia de seguridad completada!',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Los datos se han respaldado correctamente en su cuenta de Google Drive.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Cierra el diálogo si hay error

      _showErrorDialog(); // Muestra diálogo de error
    }
  }

  Future<void> _restore() async {
    // Solicita confirmación para restaurar
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          '¿Restaurar datos?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción eliminará todos los datos guardados actualmente en su dispositivo y los reemplazará con los datos de su cuenta de Google Drive.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    if (!await verificarConexion(context)) return; // Verifica conexión

    final backupInfo = await BackupService.getLastBackupInfo(); // Verifica si hay backup disponible
    if (!mounted) return;

    if (backupInfo == null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Sin copia de seguridad',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Aún no tienes una copia de seguridad guardada en Google Drive.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Muestra diálogo de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        content: Row(
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'Restaurando datos...\nPor favor espere.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Realiza la restauración desde Drive
      await BackupService.restoreBackupFromDrive();

      if (!mounted) return;
      Navigator.pop(context); // Cierra diálogo de progreso

      // Muestra mensaje de éxito
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            '¡Restauración completada!',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Los datos fueron restaurados correctamente desde Google Drive.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cierra diálogo si hay error
      _showErrorDialog(); // Muestra error
    }
  }

  // Getter que determina si el usuario ha iniciado sesión (basado en si hay correo)
  bool get isLoggedIn => _userEmail.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldo de datos'),
        actions: [
          if (isLoggedIn) ...[
            if (_userPhoto.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(backgroundImage: NetworkImage(_userPhoto)),
              ),

            // Botón para cerrar sesión
            IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo de Google Drive con padding condicional
            SizedBox(height: isLoggedIn ? 10 : 100),
            Center(child: Image.asset('assets/logo/drive.png', height: 150)),

            // Contenido mostrado si el usuario ha iniciado sesión
            if (isLoggedIn) ...[
              const SizedBox(height: 20),
              Text('Copia de seguridad', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              Text('Guarda copia de de seguridad de tus transacciones en el almacenamiento de tu cuenta de Google. Puedes restaurarlos en cualquier momento. (No se guardan deudas ni categorías en esta copia)'),
              const SizedBox(height: 10),
            ],

            // Contenido mostrado si el usuario NO ha iniciado sesión
            if (!isLoggedIn) ...[
              const SizedBox(height: 180),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                    fillColor: WidgetStateProperty.all<Color>(Colors.white),
                    checkColor: Colors.black,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsPage()),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'He leído y acepto los ',
                          children: [
                            TextSpan(
                              text: 'términos y condiciones de uso',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Botón de inicio de sesión con Google (solo activo si se aceptan términos)
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: Image.asset('assets/logo/google.png', height: 34),
                  label: const Text('Iniciar sesión  '),
                  onPressed: _termsAccepted ? _signIn : null,
                ),
              ),
            ],

            // Información de almacenamiento si el usuario está logueado
            if (isLoggedIn) ...[
              FutureBuilder<Map<String, dynamic>?>(
                future: BackupService.getStorageInfo(),
                builder: (context, snapshot) {

                  final storageInfo = snapshot.data;
                  final usedBytes = storageInfo?['usedBytes'] ?? 0;
                  final totalBytes = storageInfo?['totalBytes'] ?? 1;
                  final usedGB = usedBytes / (1024 * 1024 * 1024);
                  final totalGB = totalBytes / (1024 * 1024 * 1024);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cuenta de Google:',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Administrar almacenamiento de Google',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${usedGB.toStringAsFixed(2)} GB de ${totalGB.toStringAsFixed(2)} GB de espacio utilizado',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),

              // Información de la última copia de seguridad
              FutureBuilder<Map<String, dynamic>?>(
                future: BackupService.getLastBackupInfo(),
                builder: (context, snapshot) {

                  final lastBackupInfo = snapshot.data;

                  if (lastBackupInfo != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última copia de seguridad:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fecha: ${formatDateTime(lastBackupInfo['createdTime'] ?? 'No disponible')}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Tamaño: ${lastBackupInfo['size']} bytes',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última copia de seguridad:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No se ha encontrado copia de seguridad.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 40),

              // Botones para subir y restaurar copia
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Subir copia de seguridad'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _upload,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.restore),
                        label: const Text('Restaurar copia'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _restore,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Función para formatear la fecha de la copia de seguridad a un formato legible en español
String formatDateTime(String dateTimeStr) {
  try {
    final dateTime = DateTime.parse(dateTimeStr);

    final DateFormat formatter = DateFormat("dd 'de' MMMM 'de' yyyy, h:mm a", 'es_ES');

    return formatter.format(dateTime);
  } catch (e) {
    return 'Fecha no válida';
  }
}