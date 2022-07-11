import 'dart:io';

abstract class AppEnv {
  AppEnv._();

  static final secretKey = _env('SECRET_KEY');
  static final port = _env('PORT');
  static final dbUsername = _env('DB_USERNAME');
  static final dbPassword = _env('DB_PASSWORD');
  static final dbHost = _env('DB_HOST');
  static final dbPort = _env('DB_PORT');
  static final dbName = _env('DB_NAME');

  static String _env(String key) => Platform.environment[key] ?? '';
}
