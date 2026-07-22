import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, ChangeNotifier;


enum ScannerAvailability {
  none,

  
  camera,

  
  wiredUnknown,

  
  wiredConnected,
}


enum CameraScanCapability {
  
  available,

  
  unavailable,

  
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
      
      return (
        ScannerAvailability.wiredUnknown,
        CameraScanCapability.unavailable,
      );
    }
    return (ScannerAvailability.none, CameraScanCapability.unavailable);
  }

  
  void reportCameraAvailable() {
    if (_cameraCapability != CameraScanCapability.available) {
      _cameraCapability = CameraScanCapability.available;
      notifyListeners();
    }
  }

  
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
