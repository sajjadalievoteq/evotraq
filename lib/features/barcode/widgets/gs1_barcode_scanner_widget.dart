import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/barcode/models/scan_mode.dart';
import 'package:traqtrace_app/features/barcode/widgets/camera_media_stream_stub.dart'
    if (dart.library.html)
        'package:traqtrace_app/features/barcode/widgets/camera_media_stream_web.dart';
import 'package:traqtrace_app/features/barcode/widgets/scanner_overlay.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/barcode/widgets/scanner_page_visibility_stub.dart'
    if (dart.library.html)
        'package:traqtrace_app/features/barcode/widgets/scanner_page_visibility_web.dart';

/// Camera acquisition for GS1 barcode scanning (Web + Android + iOS + macOS).
///
/// Public API (constructor, callbacks, overlay) is preserved. Downstream GS1
/// parsing is unchanged — this widget only delivers raw barcode strings.
///
/// Mounted only after an explicit "Scan with Camera" tap so browser permission
/// is never requested on page load.
///
/// **mobile_scanner 7.2.1 web lifecycle:** MediaStream tracks are released by
/// [MobileScannerController.stop] (ZXing `reset`). [dispose] also calls
/// platform `stop`. We disable [MobileScanner.useAppLifecycleState] and own
/// stop/start ourselves to avoid racing dispose vs the widget's observer.
class GS1BarcodeScannerWidget extends StatefulWidget {
  const GS1BarcodeScannerWidget({
    super.key,
    required this.onGS1BarcodeDetected,
    this.scanMode = ScanMode.single,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.loadingWidget,
    this.errorWidget,
    this.onCameraBecameAvailable,
    this.onCameraUnavailable,
  });

  final Function(String gs1ElementString) onGS1BarcodeDetected;
  final ScanMode scanMode;
  final bool showOverlay;
  final Color overlayColor;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  /// Optional: host can mark camera capability as available after start.
  final VoidCallback? onCameraBecameAvailable;

  /// Optional: host can mark camera capability as unavailable after failure.
  final VoidCallback? onCameraUnavailable;

  @override
  State<GS1BarcodeScannerWidget> createState() =>
      _GS1BarcodeScannerWidgetState();
}

class _GS1BarcodeScannerWidgetState extends State<GS1BarcodeScannerWidget>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  String? _errorMessage;
  bool _flashEnabled = false;
  bool _usingFrontCamera = false;
  bool _reportedAvailable = false;
  bool _controllerUpdateScheduled = false;
  String? _lastDetectedValue;
  DateTime? _lastDetectedAt;

  /// True while a live controller exists (not fully released).
  bool _cameraHeld = false;

  /// In-flight full release; prevents overlapping dispose / recreate.
  Future<void>? _releaseFuture;

  VoidCallback? _unsubscribeVisibility;

  static const _duplicateWindow = Duration(seconds: 1);

  static const _formats = [
    BarcodeFormat.dataMatrix,
    BarcodeFormat.code128,
    BarcodeFormat.qrCode,
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
  ];

  MobileScannerController get _requireController {
    final c = _controller;
    if (c == null) {
      throw StateError('MobileScannerController is not available');
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _unsubscribeVisibility = subscribePageVisibility(
      onHidden: _pauseCameraForLifecycle,
      onVisible: _resumeCameraAfterLifecycle,
    );
    _attachNewController();
  }

  void _attachNewController() {
    final controller = MobileScannerController(
      facing: CameraFacing.back,
      formats: _formats,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
    );
    controller.addListener(_onControllerChanged);
    _controller = controller;
    _cameraHeld = true;
    _releaseFuture = null;
  }

  /// Full release: stop (releases web MediaStream) then dispose. Idempotent.
  Future<void> _releaseFully() {
    return _releaseFuture ??= _doReleaseFully();
  }

  Future<void> _doReleaseFully() async {
    final controller = _controller;
    if (controller == null) {
      _cameraHeld = false;
      return;
    }

    _cameraHeld = false;
    try {
      controller.removeListener(_onControllerChanged);
    } catch (_) {}

    // mobile_scanner 7.2.1 web: stop() → ZXing reset() stops MediaStreamTracks.
    try {
      await controller.stop();
    } catch (e) {
      debugPrint('GS1BarcodeScanner: stop failed: $e');
    }
    try {
      await controller.dispose();
    } catch (e) {
      debugPrint('GS1BarcodeScanner: dispose failed: $e');
    }

    // Clear any leftover browser tracks after plugin teardown.
    forceStopActiveCameraTracks();

    _controller = null;
  }

  /// Pause only (keep controller) — matches mobile_scanner README lifecycle.
  Future<void> _pauseCameraForLifecycle() async {
    if (!_cameraHeld || _controller == null) return;
    // Permission dialogs also fire inactive; only stop if already running.
    if (!_controller!.value.isRunning) return;
    try {
      await _controller!.stop();
    } catch (_) {}
    forceStopActiveCameraTracks();
    if (mounted) setState(() {});
  }

  Future<void> _resumeCameraAfterLifecycle() async {
    if (!_cameraHeld || _controller == null || !mounted) return;
    if (_controller!.value.isRunning) return;
    try {
      await _controller!.start();
    } catch (e) {
      debugPrint('GS1BarcodeScanner: resume start failed: $e');
    }
    if (mounted) setState(() {});
  }

  /// MobileScanner can notify during mount/layout. Never setState or notify the
  /// parent synchronously from that path — it triggers `!_dirty` on ancestors.
  void _onControllerChanged() {
    if (!mounted || !_cameraHeld || _controllerUpdateScheduled) return;
    _controllerUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerUpdateScheduled = false;
      if (!mounted || !_cameraHeld || _controller == null) return;
      _applyControllerState();
    });
  }

  void _applyControllerState() {
    final state = _requireController.value;
    final error = state.error;

    if (error != null) {
      final message = _friendlyError(error);
      if (_errorMessage != message || _flashEnabled) {
        setState(() {
          _errorMessage = message;
          _flashEnabled = false;
        });
      }
      widget.onCameraUnavailable?.call();
      return;
    }

    if (state.isInitialized && !_reportedAvailable) {
      _reportedAvailable = true;
      widget.onCameraBecameAvailable?.call();
    }

    final flash = state.torchState == TorchState.on;
    final front = state.cameraDirection == CameraFacing.front;
    if (_flashEnabled != flash || _usingFrontCamera != front) {
      setState(() {
        _flashEnabled = flash;
        _usingFrontCamera = front;
      });
    }
  }

  String _friendlyError(MobileScannerException e) {
    switch (e.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera access is unavailable. Enable camera permission in your browser settings or continue using a wired scanner or manual entry.';
      case MobileScannerErrorCode.unsupported:
        return 'Camera scanning is not supported in this browser. Use a wired scanner or manual entry.';
      default:
        return 'Camera access is unavailable. Enable camera permission in your browser settings or continue using a wired scanner or manual entry.';
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_cameraHeld || _controller == null) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;

      final now = DateTime.now();
      if (_lastDetectedValue == raw &&
          _lastDetectedAt != null &&
          now.difference(_lastDetectedAt!) < _duplicateWindow) {
        return;
      }

      _lastDetectedValue = raw;
      _lastDetectedAt = now;

      final gs1ElementString = _processRawBarcode(raw);
      if (gs1ElementString != null) {
        unawaited(_handleValidGS1Barcode(gs1ElementString));
        break;
      }
    }
  }

  String? _processRawBarcode(String rawValue) {
    return rawValue.isNotEmpty ? rawValue : null;
  }

  /// Single-mode: fully release the MediaStream before notifying the parent
  /// (parent still switches to details / unmounts). Continuous mode keeps scanning.
  Future<void> _handleValidGS1Barcode(String gs1ElementString) async {
    if (widget.scanMode == ScanMode.single) {
      await _releaseFully();
      if (mounted) setState(() {});
    }
    widget.onGS1BarcodeDetected(gs1ElementString);
  }

  Future<void> toggleFlash() async {
    if (!_cameraHeld || _controller == null) return;
    try {
      await _controller!.toggleTorch();
      if (!mounted || !_cameraHeld || _controller == null) return;
      setState(() {
        _flashEnabled = _controller!.value.torchState == TorchState.on;
      });
    } catch (e) {
      debugPrint('Flash control not supported: $e');
      if (mounted) {
        context.showInfo(
          'Flash mode not supported on this device',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> toggleCamera() async {
    if (!_cameraHeld || _controller == null) return;
    try {
      await _controller!.switchCamera();
      if (!mounted || !_cameraHeld || _controller == null) return;
      setState(() {
        _usingFrontCamera =
            _controller!.value.cameraDirection == CameraFacing.front;
        _flashEnabled = _controller!.value.torchState == TorchState.on;
      });
    } catch (e) {
      debugPrint('Camera switch not supported: $e');
      if (mounted) {
        context.showInfo(
          'Switching camera is not supported on this device',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _retry() async {
    await _releaseFully();
    _lastDetectedValue = null;
    _lastDetectedAt = null;
    _reportedAvailable = false;
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _attachNewController();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Own lifecycle only — MobileScanner.useAppLifecycleState is false.
    // Do not dispose on inactive (permission popups); stop releases the stream.
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        unawaited(_pauseCameraForLifecycle());
      case AppLifecycleState.resumed:
        unawaited(_resumeCameraAfterLifecycle());
      case AppLifecycleState.detached:
        unawaited(_releaseFully());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unsubscribeVisibility?.call();
    _unsubscribeVisibility = null;
    // Kick off stop+dispose immediately; cannot await in State.dispose.
    unawaited(_releaseFully());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return widget.errorWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TraqIcon(AppAssets.iconAlert, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Use a wired scanner or manual barcode entry instead.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _retry,
                    icon: TraqIcon(AppAssets.iconCamera, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
    }

    final controller = _controller;
    if (!_cameraHeld || controller == null) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          // Avoid racing our WidgetsBindingObserver (dispose vs stop/start).
          useAppLifecycleState: false,
          onDetect: _onDetect,
          placeholderBuilder: (_) =>
              widget.loadingWidget ??
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error) {
            // errorBuilder runs during build — only schedule side effects.
            final message = _friendlyError(error);
            if (_errorMessage != message && !_controllerUpdateScheduled) {
              _controllerUpdateScheduled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _controllerUpdateScheduled = false;
                if (!mounted) return;
                setState(() => _errorMessage = message);
                widget.onCameraUnavailable?.call();
              });
            }
            return widget.loadingWidget ??
                const Center(child: CircularProgressIndicator());
          },
        ),
        if (widget.showOverlay)
          Positioned.fill(
            child: ScannerOverlay(
              borderColor: widget.overlayColor,
              cutOutWidth: 260,
              cutOutHeight: 200,
            ),
          ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: TraqIcon(
              _flashEnabled ? AppAssets.iconFlash : AppAssets.iconBlock,
              color: Colors.white,
              size: 32,
            ),
            onPressed: toggleFlash,
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: TraqIcon(AppAssets.iconCamera, color: Colors.white, size: 32),
            onPressed: toggleCamera,
          ),
        ),
        if (_usingFrontCamera)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Front camera active - Ensure good lighting',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Align barcode within the frame',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
