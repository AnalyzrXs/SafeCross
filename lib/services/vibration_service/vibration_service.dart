import 'dart:async';

import 'package:vibration/vibration.dart';

import '../../state/detection_state/detection_state.dart';
import '../../utils/logger/logger.dart';

/// Handles haptic feedback independently of all other services.
class VibrationService {
  VibrationService({required DetectionState detectionState})
    : _detectionState = detectionState;

  final DetectionState _detectionState;

  static const List<int> _pattern = [0, 450, 150, 450];
  static const List<int> _intensities = [64, 255, 64, 255];

  StreamSubscription<bool>? _subscription;
  bool _initialized = false;
  bool _isVibrating = false;
  bool _enabled = false;

  Future<void> start() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _subscription = _detectionState.stream.listen(
      (detected) => unawaited(_handleStateChange(detected)),
    );
    await _handleStateChange(_detectionState.vehicleDetected);
  }

  Future<void> _handleStateChange(bool detected) async {
    if (!_enabled) {
      if (_isVibrating) {
        await Vibration.cancel();
        _isVibrating = false;
      }
      return;
    }
    final shouldVibrate = !detected;
    if (shouldVibrate) {
      if (_isVibrating) {
        return;
      }
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) {
        safcrossLogger.info('Device does not expose vibration hardware');
        return;
      }
      await Vibration.vibrate(
        pattern: _pattern,
        intensities: _intensities,
        repeat: 0,
      );
      _isVibrating = true;
      return;
    }

    if (_isVibrating) {
      await Vibration.cancel();
      _isVibrating = false;
    }
  }

  Future<void> updateEnabled(bool enabled) async {
    if (_enabled == enabled) {
      return;
    }
    _enabled = enabled;
    if (!_enabled && _isVibrating) {
      await Vibration.cancel();
      _isVibrating = false;
    } else if (_enabled) {
      await _handleStateChange(_detectionState.vehicleDetected);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    if (_isVibrating) {
      await Vibration.cancel();
      _isVibrating = false;
    }
  }
}
