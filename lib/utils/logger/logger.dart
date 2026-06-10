import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized lightweight logger that stays alive even when the UI is paused.
/// It fans out entries to both [debugPrint] (for foreground visibility) and the
/// VM service log stream so they remain available if the screen is locked.
class SafcrossLogger {
  const SafcrossLogger();

  void detection(String message) {
    final formatted = '[Safcross] $message';
    _dispatch(formatted);
  }

  void info(String message) {
    _dispatch('[Safcross] $message');
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    final formatted = '[Safcross] $message';
    _dispatch(formatted);
    if (error != null) {
      developer.log(
        formatted,
        name: 'Safcross',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _dispatch(String message) {
    debugPrint(message);
    developer.log(message, name: 'Safcross');
  }
}

const safcrossLogger = SafcrossLogger();
