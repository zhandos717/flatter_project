

enum Environment { dev, staging, prod, local }

class EnvironmentConfig {
  static Environment _environment = Environment.local;

  // URLs для разных окружений
  static final Map<Environment, String> _baseUrls = {
    Environment.local: 'http://10.0.2.2:3000/api', // Для разработки
    Environment.dev: 'https://myfin.dualse.kz/api', // Для разработки
    Environment.staging: 'https://myfin.dualse.kz/api', // Тестовый сервер
    Environment.prod: 'https://myfin.dualse.kz/api', // Продакшн сервер
  };

  // Метод для установки окружения
  static void setEnvironment(Environment environment) {
    _environment = environment;
  }

  // Получение базового URL API в зависимости от окружения
  static String get baseApiUrl => _baseUrls[_environment]!;

  // Флаг включения логирования для отладки
  static bool get enableLogging => _environment != Environment.prod;

  // Другие параметры конфигурации
  static Duration get apiTimeout => const Duration(seconds: 30);
}
