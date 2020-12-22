import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences prefs;
  static List<String> recentPath = [];

  static List<String> previousPath = [];

  static const String RECENT_PATH = "recent.path";
  static const String PREVIOUS_PATH = "previous.path";
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    readRecentList();
    getPreviousPath();
  }

  static Future<List<String>> save(String path) async {
    if (recentPath.contains(path)) {
      return null;
    }
    recentPath.add(path);
    await prefs.setStringList(RECENT_PATH, recentPath);
    return recentPath;
  }

  static void readRecentList() async {
    recentPath = prefs.getStringList(RECENT_PATH) ?? [];
  }

  static Future<bool> clearAll() async {
    recentPath.clear();
    return await prefs.clear();
  }

  static Future<void> savePreviousPath(
      String excel, String json, String locale) async {
    previousPath = [excel, json, locale];
    await save(excel);
    await save(json);
    await save(locale);

    await prefs.setStringList(PREVIOUS_PATH, previousPath);
  }

  static void getPreviousPath() async {
    previousPath = prefs.getStringList(PREVIOUS_PATH) ?? [];
  }
}
