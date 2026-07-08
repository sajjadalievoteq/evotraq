import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, ChangeNotifier;

enum ScannerAvailability {
  none,

  camera,

  wiredUnknown,

  wiredConnected,
}

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

  void onWiredScannerBurst() {
    if (_availability == ScannerAvailability.wiredUnknown) {
      _availability = ScannerAvailability.wiredConnected;
      notifyListeners();
    }
  }

  void resetWiredConfirmation() {
    if (_availability == ScannerAvailability.wiredConnected) {
      _availability = ScannerAvailability.wiredUnknown;
      notifyListeners();
    }
  }
}
