import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Usuario';
  }
}

final db = DBHelper();
