import 'package:shared_preferences/shared_preferences.dart';

class FavorisService {
  static const _key = 'favoris';

  Future<List<String>> getFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> toggleFavori(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final favoris = prefs.getStringList(_key) ?? [];
    if (favoris.contains(uid)) {
      favoris.remove(uid);
    } else {
      favoris.add(uid);
    }
    await prefs.setStringList(_key, favoris);
  }

  Future<bool> estFavori(String uid) async {
    final favoris = await getFavoris();
    return favoris.contains(uid);
  }
}
