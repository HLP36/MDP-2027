class AppConfig {
  AppConfig._();

  static const String defaultDevelopmentApiUrl = 'http://localhost:3000/api';

  static const String defaultProductionApiUrl = 'https://api.mdp2027.com/api';

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static const String configuredApiUrl = String.fromEnvironment('MDP_API_URL');

  static String get apiBaseUrl {
    if (configuredApiUrl.trim().isNotEmpty) {
      return configuredApiUrl.trim();
    }

    return isProduction ? defaultProductionApiUrl : defaultDevelopmentApiUrl;
  }
}
