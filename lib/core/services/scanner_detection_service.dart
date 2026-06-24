import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, ChangeNotifier;

/// How a GS1 barcode can be captured on the current platform.
enum ScannerAvailability {
  /// Platform cannot scan (no camera and no keyboard-wedge path).
  none,

  /// Native camera scanning (Android / iOS).
  camera,

  /// Web or desktop: USB keyboard-wedge scanner may be connected (not yet confirmed).
  wiredUnknown,

  /// Web or desktop: scanner burst detected — connection confirmed.
  wiredConnected,
}

/// Tracks whether scanning is possible and whether a wired scanner has been seen.
class ScannerDetectionService extends ChangeNotifier {
  ScannerAvailability _availability = ScannerAvailability.none;

  ScannerAvailability get availability => _availability;

  bool get isScannable =>
      _availability == ScannerAvailability.camera ||
      _availability == ScannerAvailability.wiredConnected ||
      _availability == ScannerAvailability.wiredUnknown;

  bool get hasCamera => _availability == ScannerAvailability.camera;

  bool get supportsWired =>
      _availability == ScannerAvailability.wiredUnknown ||
      _availability == ScannerAvailability.wiredConnected;

  ScannerDetectionService() {
    _availability = _initialAvailability();
  }

  static ScannerAvailability _initialAvailability() {
    if (kIsWeb) {
      return ScannerAvailability.wiredUnknown;
    }
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return ScannerAvailability.camera;
    }
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return ScannerAvailability.wiredUnknown;
    }
    return ScannerAvailability.none;
  }

  /// Call when a rapid keyboard-wedge burst is observed or a wired scan succeeds.
  void onWiredScannerBurst() {
    if (_availability == ScannerAvailability.wiredUnknown) {
      _availability = ScannerAvailability.wiredConnected;
      notifyListeners();
    }
  }

  /// Reset wired confirmation (e.g. after "Scan again").
  void resetWiredConfirmation() {
    if (_availability == ScannerAvailability.wiredConnected) {
      _availability = ScannerAvailability.wiredUnknown;
      notifyListeners();
    }
  }
}
