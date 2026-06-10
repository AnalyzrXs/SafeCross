import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

import '../state/detection_state/detection_state.dart';
import 'audio_service/audio_service.dart';
import 'detection_service/detection_service.dart';
import 'flashlight_service/flashlight_service.dart';
import 'notification_service/notification_service.dart';
import 'vibration_service/vibration_service.dart';

/// Bootstraps and holds references to the long-lived background services.
class SafecrossServiceManager {
  SafecrossServiceManager._({
    required this.detectionState,
    required this.detectionService,
    required this.audioService,
    required this.vibrationService,
    required this.flashlightService,
    required this.notificationService,
  });

  final DetectionState detectionState;
  final DetectionService detectionService;
  final AudioService audioService;
  final VibrationService vibrationService;
  final FlashlightService flashlightService;
  final NotificationService notificationService;

  bool pushNotificationsEnabled = true;
  bool soundAlertsEnabled = true;
  bool flashBeaconEnabled = true;
  bool _assistServicesStarted = false;

  static SafecrossServiceManager? _instance;

  static SafecrossServiceManager get instance {
    final manager = _instance;
    if (manager == null) {
      throw StateError('Safecross services not initialized');
    }
    return manager;
  }

  static Future<SafecrossServiceManager> ensureInitialized() async {
    if (_instance != null) {
      return _instance!;
    }

    final detectionState = DetectionState();
    final detectionService = DetectionService(detectionState: detectionState);
    final audioService = AudioService(detectionState: detectionState);
    final vibrationService = VibrationService(detectionState: detectionState);
    final flashlightService = FlashlightService(detectionState: detectionState);
    final notificationService = NotificationService();

    await _requestRuntimePermissions();
    await notificationService.ensurePersistentNotification();
    await detectionService.start();
    final manager = SafecrossServiceManager._(
      detectionState: detectionState,
      detectionService: detectionService,
      audioService: audioService,
      vibrationService: vibrationService,
      flashlightService: flashlightService,
      notificationService: notificationService,
    );
    _instance = manager;
    return manager;
  }

  bool get _assistSwitchesReady =>
      pushNotificationsEnabled && soundAlertsEnabled && flashBeaconEnabled;

  Future<bool> ensureAssistFeaturesEnabled() async {
    if (!_assistSwitchesReady) {
      return false;
    }
    await _startAssistServicesIfNeeded();
    await _refreshAssistFeatureGates();
    return true;
  }

  static Future<void> _requestRuntimePermissions() async {
    final notification = await Permission.notification.status;
    if (notification.isDenied || notification.isRestricted) {
      await Permission.notification.request();
    }
  }

  Future<void> _startAssistServicesIfNeeded() async {
    if (_assistServicesStarted) {
      return;
    }
    await Future.wait([
      audioService.start(),
      vibrationService.start(),
      flashlightService.start(),
    ]);
    _assistServicesStarted = true;
  }

  Future<void> _refreshAssistFeatureGates() async {
    if (!_assistServicesStarted) {
      return;
    }
    final allow = _assistSwitchesReady;
    await Future.wait([
      audioService.updateEnabled(allow),
      vibrationService.updateEnabled(allow),
      flashlightService.updateEnabled(allow),
    ]);
  }

  void updateSoundAlerts(bool enabled) {
    soundAlertsEnabled = enabled;
    unawaited(_refreshAssistFeatureGates());
  }

  void updateFlashBeacon(bool enabled) {
    flashBeaconEnabled = enabled;
    unawaited(_refreshAssistFeatureGates());
  }

  void updatePushNotifications(bool enabled) {
    pushNotificationsEnabled = enabled;
    unawaited(_refreshAssistFeatureGates());
  }

  Future<void> dispose() async {
    await notificationService.dispose();
    await flashlightService.dispose();
    await vibrationService.dispose();
    await audioService.dispose();
    await detectionService.stop();
    await detectionState.dispose();
    _instance = null;
  }
}
