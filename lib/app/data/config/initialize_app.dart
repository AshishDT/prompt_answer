import 'package:nigerian_igbo/app/data/config/logger.dart';
import 'package:nigerian_igbo/app/data/local/locale_provider.dart';
import 'package:nigerian_igbo/app/data/local/theme_provider.dart';
import 'package:nigerian_igbo/app/data/local/user_provider.dart';
import 'package:nigerian_igbo/app/data/remote/api_service/init_api_service.dart';
import 'package:get_storage/get_storage.dart';


/// Initialize all core functionalities
Future<void> initializeCoreApp({
  required String? developmentApiBaseUrl,
  required String? productionApiBaseUrl,
  bool firebaseApp = true,
  bool setupLocalNotifications = false,
  bool encryption = false,
}) async {
  initLogger();

  await GetStorage.init();
  UserProvider.loadUser();
  LocaleProvider.loadCurrentLocale();
  await ThemeProvider.getThemeModeFromStore();

  if (productionApiBaseUrl != null && developmentApiBaseUrl != null) {
    APIService.initializeAPIService(
      encryptData: encryption,
    );
  }
}
