import 'dart:async';

/// Single source of truth for the current crossing safety signal.
/// All services talk to this state object instead of referencing each other.
class DetectionState {
  DetectionState();

  final _controller = StreamController<bool>.broadcast(sync: true);
  bool _vehicleDetected = false;

  bool get vehicleDetected => _vehicleDetected;

  Stream<bool> get stream => _controller.stream;

  /// Updates the flag and notifies listeners only when the value changes.
  void updateVehicleDetected(bool nextValue) {
    if (_vehicleDetected == nextValue) {
      return;
    }
    _vehicleDetected = nextValue;
    _controller.add(_vehicleDetected);
  }

  StreamSubscription<bool> listen(void Function(bool) onData) {
    return _controller.stream.listen(onData);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
