import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;

class HiveService {
  static var box;
  static var searchHistory;

  static Future<void> initHive() async {
    var dir = await pathprovider.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    box = await Hive.openBox('appData');
    searchHistory = await Hive.openBox('searchHistory');
  }

  ///    App Theme Controller
  static T? read<T>(String key) {
    return box?.get(key) as T?;
  }

  static void write(String key, dynamic value) {
    box?.put(key, value);
  }


  // /// User ID
  // static setUserID(int id) {
  //   box.put('id', id);
  // }
  // static Future<int?> getUserID() async {
  //   return await box.get('id');
  // }
  // static deleteUserID() {
  //   box.delete('id');
  // }
  //
  // /// User Token
  // static setToken(String token) {
  //   box.put('token', token);
  // }
  // static deleteToken() {
  //   box.delete('token');
  // }
  // static Future<String?> getToken() async {
  //   return await box.get('token');
  // }
  //
  // /// User Firebase token
  // static setFirebaseToken(String firebaseToken) {
  //   box.put('firebaseToken', firebaseToken);
  // }
  //
  // static deleteFirebaseToken() {
  //   box.delete('firebaseToken');
  // }
  //
  // static Future<String?> getFirebaseToken() async {
  //   return await box.get('firebaseToken');
  // }

  /// Is Alert Showed
  static bool getAlertShowed() {
    final lastShownDate = box?.get('alert_last_shown_date');

    if (lastShownDate == null) {
      return false;
    }
    final now = DateTime.now();
    final difference = now.difference(lastShownDate).inDays;
    return difference < 1;
  }

  static void setAlertShowed(bool value) {
    if (value) {
      box?.put('alert_last_shown_date', DateTime.now());
    } else {
      box?.delete('alert_last_shown_date');
    }
  }

  /// Onboard Screen
  static Future<bool> getOnBoardShowed() async {
    return box?.get('onboard') ?? false;
  }

  static void setOnBoardShowed(bool value) {
    if (value) {
      box?.put('onboard', value);
    } else {
      box?.delete('onboard');
    }
  }

  static void setLanguage(String language) {
    box.put('language', language);
  }

  static dynamic getLanguage() {
    return box.get('language', defaultValue: 'en_en');
  }

  /// Search History
  static List<String> getSearchHistory() {
    final history = searchHistory?.get('history');
    if (history == null) return <String>[];
    return List<String>.from(history);
  }

  static void addSearchHistory(String keyword) {
    if (keyword.trim().isEmpty) return;
    List<String> history = getSearchHistory();
    // Remove if exists to push it to the top
    history.removeWhere((item) => item.toLowerCase() == keyword.toLowerCase());
    history.insert(0, keyword);
    // Keep max 15 items
    if (history.length > 15) {
      history = history.sublist(0, 15);
    }
    searchHistory?.put('history', history);
  }

  static void deleteSearchHistory(String keyword) {
    List<String> history = getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == keyword.toLowerCase());
    searchHistory?.put('history', history);
  }

  static void clearSearchHistory() {
    searchHistory?.delete('history');
  }


}



