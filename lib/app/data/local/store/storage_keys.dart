// ignore_for_file: public_member_api_docs

part of 'local_store.dart';

/// Local storage keys with built in helpers
class LocalStore {
  /// current locale
  static final _StoreObject<String> currentLocale =
      _StoreObject<String>(key: 'current_locale');

  /// theme mode
  static final _StoreObject<int> themeMode =
      _StoreObject<int>(key: 'theme_mode');

  /// User data
  static final _StoreObject<String> user =
      _StoreObject<String>(key: 'user_data');

  /// Auth token
  static final _StoreObject<String> authToken =
      _StoreObject<String>(key: 'auth_token');

  /// Erase all data from local storage
  static Future<void> erase() async {
    await _Store.erase();
  }
}
