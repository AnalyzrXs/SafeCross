import 'dart:async';

import 'package:torch_light/torch_light.dart';

import '../../state/detection_state/detection_state.dart';
import '../../utils/logger/logger.dart';

/// Blinks the device torch rapidly whenever it is safe to cross.
class FlashlightService {
  FlashlightService({required DetectionState detectionState})
    : _detectionState = detectionState;

  final DetectionState _detectionState;

  StreamSubscription<bool>? _subscription;
  Timer? _blinkTimer;
  bool _initialized = false;
  bool _enabled = false;
  bool _torchEnabled = false;
  bool? _hardwareAvailable;

  Future<void> start() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _subscription = _detectionState.stream.listen(
      (value) => unawaited(_handleStateChange(value)),
    );
    await _handleStateChange(_detectionState.vehicleDetected);
  }

  Future<void> updateEnabled(bool enabled) async {
    if (_enabled == enabled) {
      return;
    }
    _enabled = enabled;
    if (!_enabled) {
      await _stopBlinking(forceDisableTorch: true);
    } else {
      await _handleStateChange(_detectionState.vehicleDetected);
    }
  }

  Future<void> _handleStateChange(bool vehicleDetected) async {
    if (!_enabled) {
      return;
    }
    _hardwareAvailable ??= await _probeHardware();
    if (_hardwareAvailable != true) {
      return;
    }

    if (!vehicleDetected) {
      _startBlinking();
    } else {
      await _stopBlinking(forceDisableTorch: true);
    }
  }

  Future<bool> _probeHardware() async {
    try {
      return await TorchLight.isTorchAvailable();
    } catch (error, stackTrace) {
      safcrossLogger.error('Torch hardware unavailable', error, stackTrace);
      return false;
    }
  }

  void _startBlinking() {
    _blinkTimer ??= Timer.periodic(
      const Duration(milliseconds: 180),
      (_) => unawaited(_toggleTorch()),
    );
  }

  Future<void> _toggleTorch() async {
    try {
      if (_torchEnabled) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      _torchEnabled = !_torchEnabled;
    } catch (error, stackTrace) {
      safcrossLogger.error('Unable to toggle torch', error, stackTrace);
      await _stopBlinking(forceDisableTorch: true);
    }
  }

  Future<void> _stopBlinking({bool forceDisableTorch = false}) async {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    if (_torchEnabled || forceDisableTorch) {
      try {
        await TorchLight.disableTorch();
      } catch (error, stackTrace) {
        safcrossLogger.error('Unable to disable torch', error, stackTrace);
      } finally {
        _torchEnabled = false;
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _stopBlinking(forceDisableTorch: true);
  }
}
