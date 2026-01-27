import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado para SharedPreferences
class SharedPrefsService {
  SharedPrefsService._();
  static final SharedPrefsService instance = SharedPrefsService._();

  SharedPreferences? _prefs;

  /// Inicializar antes de usar (en main)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // =============================================================
  // 🔹 Setters tipados
  // =============================================================
  Future<bool> setString(String key, String value) async {
    return _prefs!.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return _prefs!.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return _prefs!.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return _prefs!.setDouble(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs!.setStringList(key, value);
  }

  // =============================================================
  // 🔹 Getters tipados
  // =============================================================
  String? getString(String key) => _prefs!.getString(key);

  bool? getBool(String key) => _prefs!.getBool(key);

  int? getInt(String key) => _prefs!.getInt(key);

  double? getDouble(String key) => _prefs!.getDouble(key);

  List<String>? getStringList(String key) => _prefs!.getStringList(key);

  // =============================================================
  // 🔹 Eliminar una key
  // =============================================================
  Future<bool> remove(String key) async {
    return _prefs!.remove(key);
  }

  // =============================================================
  // 🔹 Limpiar todo
  // =============================================================
  Future<bool> clear() async {
    return _prefs!.clear();
  }

  // =============================================================
  // 🔹 Helpers de uso frecuente
  // =============================================================

  /// Token JWT
  Future<void> saveToken(String token) async {
    await setString("derivant_auth_token", token);
  }

  String? getToken() {
    return getString("derivant_auth_token");
  }

  Future<void> deleteToken() async {
    await remove("derivant_auth_token");
  }

  /// Guardar tema Oscuro/Claro
  Future<void> setDarkMode(bool value) async {
    await setBool("derivant_dark_mode", value);
  }

  bool isDarkMode() {
    return getBool("derivant_dark_mode") ?? false;
  }
}
