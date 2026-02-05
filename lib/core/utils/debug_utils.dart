import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class DebugUtils {
  static bool get isDebugMode => kDebugMode;

  static void logInfo(String message, {String? tag}) {
    if (isDebugMode) {
      final logTag = tag ?? 'MatrixAccounts';
      developer.log(message, name: logTag, level: 800);
      print('[$logTag] INFO: $message');
    }
  }

  static void logWarning(String message, {String? tag, Object? error}) {
    if (isDebugMode) {
      final logTag = tag ?? 'MatrixAccounts';
      developer.log(message, name: logTag, level: 900, error: error);
      print(
          '[$logTag] WARNING: $message${error != null ? ' - Error: $error' : ''}');
    }
  }

  static void logError(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag ?? 'MatrixAccounts';
    developer.log(message,
        name: logTag, level: 1000, error: error, stackTrace: stackTrace);
    print(
        '[$logTag] ERROR: $message${error != null ? ' - Error: $error' : ''}');

    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }

  static void logMemoryUsage({String? context}) {
    if (!isDebugMode) return;

    try {
      // This is a basic memory usage indicator
      final message =
          'Memory usage check${context != null ? ' - $context' : ''}';
      developer.log(message, name: 'MemoryMonitor', level: 800);
      print('[MemoryMonitor] $message');
    } catch (e) {
      logError('Failed to log memory usage', error: e);
    }
  }

  static void logLifecycleEvent(String event, {String? context}) {
    if (isDebugMode) {
      final message =
          'Lifecycle: $event${context != null ? ' - $context' : ''}';
      developer.log(message, name: 'Lifecycle', level: 800);
      print('[Lifecycle] $message');
    }
  }

  static void logNavigationEvent(String event, {String? route}) {
    if (isDebugMode) {
      final message =
          'Navigation: $event${route != null ? ' - Route: $route' : ''}';
      developer.log(message, name: 'Navigation', level: 800);
      print('[Navigation] $message');
    }
  }

  static void logDatabaseOperation(String operation,
      {String? table, Object? error}) {
    if (isDebugMode) {
      final message =
          'DB: $operation${table != null ? ' - Table: $table' : ''}';
      if (error != null) {
        logError(message, tag: 'Database', error: error);
      } else {
        developer.log(message, name: 'Database', level: 800);
        print('[Database] $message');
      }
    }
  }
}
