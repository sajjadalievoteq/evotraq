import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, ChangeNotifier;

/// Wired / HID scanner connection state.
enum ScannerAvailability {
  none,

  /// Native mobile device where camera is the primary capture path.
  camera,

  /// Keyboard wedge may be present; connection not yet confirmed by a burst.
  wiredUnknown,

  /// At least one wired scan burst has been observed this session.
  wiredConnected,
}

/// Camera scanning capability independent of wired state.
enum CameraScanCapability {
  /// Camera(s) confirmed present / previously usable.
  available,

  /// No camera or platform does not support mobile_scanner camera.
  unavailable,

  /// Camera may exist; browser permission / enumeration not completed yet.
  unknown,
}

class ScannerDetectionService extends ChangeNotifier {
  ScannerAvailability _availability = ScannerAvailability.none;
  CameraScanCapability _cameraCapability = CameraScanCapability.unavailable;

  ScannerAvailability get availability => _availability;

  CameraScanCapability get cameraCapability => _cameraCapability;

  bool get isScannable =>
      _availability == ScannerAvailability.camera ||
      _availability == ScannerAvailability.wiredConnected ||
      _availability == ScannerAvailability.wiredUnknown ||
      canOfferCamera;

  /// Whether the UI should offer "Scan with Camera".
  ///
  /// Includes [CameraScanCapability.unknown] so browsers that hide devices
  /// until permission can still start the permission flow.
  bool get hasCamera =>
      _cameraCapability == CameraScanCapability.available ||
      _cameraCapability == CameraScanCapability.unknown;

  bool get canOfferCamera => hasCamera;

  bool get supportsWired =>
      _availability == ScannerAvailability.wiredUnknown ||
      _availability == ScannerAvailability.wiredConnected;

  ScannerDetectionService() {
    final initial = _initialState();
    _availability = initial.$1;
    _cameraCapability = initial.$2;
  }

  static (ScannerAvailability, CameraScanCapability) _initialState() {
    if (kIsWeb) {
      // HID scanners work in any browser; webcam is often present but may be
      // hidden until getUserMedia permission is granted.
      return (
        ScannerAvailability.wiredUnknown,
        CameraScanCapability.unknown,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return (
        ScannerAvailability.camera,
        CameraScanCapability.available,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return (
        ScannerAvailability.wiredUnknown,
        CameraScanCapability.unknown,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // mobile_scanner has no Windows/Linux camera support; wired/manual only.
      return (
        ScannerAvailability.wiredUnknown,
        CameraScanCapability.unavailable,
      );
    }
    return (ScannerAvailability.none, CameraScanCapability.unavailable);
  }

  /// Mark camera as confirmed after a successful start.
  void reportCameraAvailable() {
    if (_cameraCapability != CameraScanCapability.available) {
      _cameraCapability = CameraScanCapability.available;
      notifyListeners();
    }
  }

  /// Mark camera unavailable after permission denied / no device / unsupported.
  void reportCameraUnavailable() {
    if (_cameraCapability != CameraScanCapability.unavailable) {
      _cameraCapability = CameraScanCapability.unavailable;
      notifyListeners();
    }
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
