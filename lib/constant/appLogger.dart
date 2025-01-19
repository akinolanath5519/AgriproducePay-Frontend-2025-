import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger();

  // Reusable logging methods
  static void logInfo(String message) {
    _logger.i(message);  // Logs informational message
  }

  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    // Correctly log the error with named parameters
    _logger.e(message, error: error, stackTrace: stackTrace);  // Log with named parameters
  }

  static void logWarning(String message) {
    _logger.w(message);  // Logs warning message
  }
}
