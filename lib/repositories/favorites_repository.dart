import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const _key = 'favorites_v1';
  final SharedPreferences _prefs;

  FavoritesRepository._(this._prefs);

  static Future<FavoritesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesRepository._(prefs);
  }

  Set<String> loadFavorites() {
    return _prefs.getStringList(_key)?.toSet() ?? <String>{};
  }

  Future<void> saveFavorites(Set<String> ids) async {
    await _prefs.setStringList(_key, ids.toList());
  }
}
