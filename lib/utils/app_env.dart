import 'dart:io';

abstract class AppEnv {
  AppEnv._();

  static final secretKey = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';

  static final port = Platform.environment['PORT'] ?? '8080';

  static final dbUsername = Platform.environment['DB_USERNAME'] ?? 'admin';
  static final dbPassword = Platform.environment['DB_PASSWORD'] ?? 'root';
  static final dbHost = Platform.environment['DB_HOST'] ?? '127.0.0.1';
  static final dbPort = Platform.environment['DB_PORT'] ?? '6101';
  static final dbName = Platform.environment['DB_NAME'] ?? 'postgres';
}
