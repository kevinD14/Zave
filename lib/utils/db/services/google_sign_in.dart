import 'package:shared_preferences/shared_preferences.dart';

// Clase para manejar el almacenamiento y recuperación de información del usuario (nombre, correo y foto).
class UserPreferences {
  // Clave para guardar el nombre completo del usuario.
  static const _keyUserName = 'userFullName';
  // Clave para guardar el correo electrónico del usuario.
  static const _keyUserEmail = 'userEmail';
  // Clave para guardar la URL de la foto del usuario.
  static const _keyUserPhoto = 'userPhoto';

  // Guarda la información del usuario en las preferencias compartidas.
  static Future<void> saveUserInfo({
    required String name,
    required String userEmail,
    required String userPhoto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Guarda el nombre del usuario.
    await prefs.setString(_keyUserName, name);
    // Guarda el correo electrónico del usuario.
    await prefs.setString(_keyUserEmail, userEmail);
    // Guarda la URL de la foto del usuario.
    await prefs.setString(_keyUserPhoto, userPhoto);
  }

  // Recupera la información del usuario almacenada, retorna un mapa con los valores.
  static Future<Map<String, String>> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    // Recupera el nombre, correo y foto; si no existen retorna string vacío.
    final userName = prefs.getString(_keyUserName) ?? '';
    final userEmail = prefs.getString(_keyUserEmail) ?? '';
    final userPhoto = prefs.getString(_keyUserPhoto) ?? '';

    // Retorna un mapa con la información recuperada.
    return {
      'userName': userName,
      'userEmail': userEmail,
      'userPhoto': userPhoto,
    };
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhoto);
  }
}
