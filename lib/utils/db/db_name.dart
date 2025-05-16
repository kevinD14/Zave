import 'package:shared_preferences/shared_preferences.dart';

/// Clase para manejar el almacenamiento y recuperación del nombre de usuario.
class DBHelper {
  // Guarda el nombre del usuario en las preferencias compartidas.
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    // Guarda el nombre bajo la clave 'userName'.
    await prefs.setString('userName', name);
  }

  // Recupera el nombre del usuario almacenado, o 'Usuario' si no existe.
  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    // Retorna el nombre guardado o 'Usuario' por defecto si no hay ninguno.
    return prefs.getString('userName') ?? 'Usuario';
  }
}

// Instancia global de DBHelper para acceder fácilmente a los métodos de guardado y recuperación del nombre.
final db = DBHelper();
