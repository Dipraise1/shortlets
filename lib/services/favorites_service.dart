import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_property_ids';

  static Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<bool> isFavorite(String propertyId) async {
    final ids = await getFavoriteIds();
    return ids.contains(propertyId);
  }

  static Future<void> toggle(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    if (ids.contains(propertyId)) {
      ids.remove(propertyId);
    } else {
      ids.add(propertyId);
    }
    await prefs.setStringList(_key, ids.toList());
  }

  static Future<void> remove(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    ids.remove(propertyId);
    await prefs.setStringList(_key, ids.toList());
  }
}
