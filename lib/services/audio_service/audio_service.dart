import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../state/detection_state/detection_state.dart';
import '../../utils/logger/logger.dart';

enum _AudioChannelState { idle, cross, stop }

/// Keeps audio playback completely decoupled from detection logic. It simply
/// mirrors the detection state and loops the correct asset without overlap.
class AudioService {
  AudioService({required DetectionState detectionState})
    : _detectionState = detectionState;

  final DetectionState _detectionState;
  final AudioPlayer _player = AudioPlayer(playerId: 'SafcrossAudio');

  StreamSubscription<bool>? _subscription;
  _AudioChannelState _currentState = _AudioChannelState.idle;
  bool _initialized = false;
  bool _enabled = false;

  Future<void> start() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    _subscription = _detectionState.stream.listen(
      (detected) => unawaited(_handleStateChange(detected)),
    );
    await _handleStateChange(_detectionState.vehicleDetected);
  }

  Future<void> _handleStateChange(bool detected) async {
    if (!_enabled) {
      return;
    }
    final desiredState = detected
        ? _AudioChannelState.cross
        : _AudioChannelState.stop;
    if (_currentState == desiredState) {
      return;
    }

    if (_currentState != _AudioChannelState.idle) {
      await _player.stop();
    }

    final asset = detected ? 'audio/cross.mp3' : 'audio/stop.mp3';
    try {
      await _player.setSourceAsset(asset);
      await _player.resume();
      _currentState = desiredState;
    } catch (error, stackTrace) {
      safcrossLogger.error(
        'Audio playback failed for $asset',
        error,
        stackTrace,
      );
      _currentState = _AudioChannelState.idle;
    }
  }

  Future<void> updateEnabled(bool enabled) async {
    if (_enabled == enabled) {
      return;
    }
    _enabled = enabled;
    if (!_enabled) {
      if (_currentState != _AudioChannelState.idle) {
        await _player.stop();
        _currentState = _AudioChannelState.idle;
      }
      return;
    }
    await _handleStateChange(_detectionState.vehicleDetected);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _player.stop();
    await _player.dispose();
  }
}
