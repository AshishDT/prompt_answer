/// Environment configuration
class EnvConfig {
  /// Environment
  static String env = const String.fromEnvironment('env');

  /// Is production
  static bool get isProd => env == 'prod';

  /// Is development
  static bool get isDev => env == 'dev';

  /// Base URL
  static String baseUrl = const String.fromEnvironment('base_url');
}
