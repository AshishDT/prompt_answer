import 'package:get/get.dart';

import '../../../generated/locales.g.dart';


/// AppTranslations
class AppTranslations extends Translations {
  /// Map
  late Map<String, Map<String, String>> map;

  @override
  Map<String, Map<String, String>> get keys => map;
}

/// TranslationApi
class TranslationApi {
  /// Load translations
  static void loadTranslations() {
    final Map<String, Map<String, String>> map = AppTranslation.translations;
    Get.find<AppTranslations>().map = map;
  }
}
