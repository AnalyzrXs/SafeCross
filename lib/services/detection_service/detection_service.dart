import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import '../../state/detection_state/detection_state.dart';
import '../../utils/logger/logger.dart';

/// Runs the dummy detection algorithm on its own isolate so it behaves like a
/// background/foreground service. The isolate keeps ticking even when the UI is
/// torn down and only communicates through [DetectionState].
class DetectionService {
  DetectionService({
    required DetectionState detectionState,
    Duration cycleDuration = const Duration(milliseconds: 2500),
  }) : _detectionState = detectionState,
       _cycleDuration = cycleDuration;

  final DetectionState _detectionState;
  final Duration _cycleDuration;

  ReceivePort? _receivePort;
  StreamSubscription<dynamic>? _subscription;
  Isolate? _isolate;
  bool _running = false;

  Future<void> start() async {
    if (_running) {
      return;
    }
    _receivePort = ReceivePort('SafcrossDetectionChannel');
    _isolate = await Isolate.spawn<_DetectionIsolateConfig>(
      _DetectionIsolate.run,
      _DetectionIsolateConfig(
        sendPort: _receivePort!.sendPort,
        cycleDuration: _cycleDuration,
      ),
      debugName: 'SafcrossDetectionIsolate',
    );
    _subscription = _receivePort!.listen((message) {
      if (message is bool) {
        _detectionState.updateVehicleDetected(message);
        safcrossLogger.detection(
          message ? 'Vehicle detected' : 'No vehicle detected',
        );
      }
    });
    _running = true;
  }

  Future<void> stop() async {
    if (!_running) {
      return;
    }
    await _subscription?.cancel();
    _subscription = null;
    _receivePort?.close();
    _receivePort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _running = false;
  }
}

class _DetectionIsolateConfig {
  const _DetectionIsolateConfig({
    required this.sendPort,
    required this.cycleDuration,
  });

  final SendPort sendPort;
  final Duration cycleDuration;
}

class _DetectionIsolate {
  static void run(_DetectionIsolateConfig config) {
    final random = Random();
    Timer.periodic(config.cycleDuration, (_) {
      final value = random.nextInt(101) > 70;
      config.sendPort.send(value);
    });
  }
}
