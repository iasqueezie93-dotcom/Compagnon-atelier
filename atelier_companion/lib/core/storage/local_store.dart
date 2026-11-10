import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stockage local simple (préférences + JSON). Base de l'historique et des réglages.
/// À remplacer par `drift` (SQLite) pour de gros volumes au jalon suivant.
class LocalStore {
  LocalStore(this._prefs);
  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? const [];
  Future<void> setStringList(String key, List<String> v) => _prefs.setStringList(key, v);

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));
}

/// Injecté au démarrage (voir main.dart).
final localStoreProvider = Provider<LocalStore>((_) {
  throw UnimplementedError('localStoreProvider doit être surchargé dans main()');
});
