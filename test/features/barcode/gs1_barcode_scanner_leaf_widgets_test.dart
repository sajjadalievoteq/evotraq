import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';
import 'package:traqtrace_app/core/services/scanner_detection_service.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_details_view.dart';
import 'package:traqtrace_app/features/barcode/models/scan_mode.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_scanner_view.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_error_banner.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_manual_input_section.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_type_chip.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_verification_card.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/wired_scanner_ready_view.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('barcode type chip preserves the GS1 type label', (tester) async {
    await tester.pumpWidget(
      _host(const BarcodeTypeChip(type: Gs1BarcodeType.sgtin)),
    );
    expect(find.text('SGTIN'), findsOneWidget);
  });

  testWidgets('verification card preserves result status and message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const BarcodeVerificationCard(
          result: {'verified': true, 'message': 'Valid barcode'},
        ),
      ),
    );
    expect(find.text('Backend Verified'), findsOneWidget);
    expect(find.text('Valid barcode'), findsOneWidget);
  });

  testWidgets('manual input trims and submits the barcode', (tester) async {
    final controller = TextEditingController(text: '  barcode-value  ');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    String? submitted;

    await tester.pumpWidget(
      _host(
        BarcodeManualInputSection(
          controller: controller,
          focusNode: focusNode,
          isProcessing: false,
          onSubmit: (value) => submitted = value,
        ),
      ),
    );
    await tester.tap(find.text('Parse Barcode'));
    expect(submitted, 'barcode-value');
  });

  testWidgets('error banner preserves dismiss callback', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        BarcodeErrorBanner(message: 'Scan failed', onDismiss: () => calls++),
      ),
    );
    expect(find.text('Scan failed'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(calls, 1);
  });

  testWidgets('details view preserves parsed fields and actions', (
    tester,
  ) async {
    var scanAgainCalls = 0;
    var useCalls = 0;
    const details = BarcodeDetails(
      type: Gs1BarcodeType.sgtin,
      rawBarcode: 'raw',
      gs1ElementString: '(01)12345678901234(21)SN001',
      isValid: true,
      gtin: '12345678901234',
      serial: 'SN001',
      allFields: {'01': '12345678901234', '21': 'SN001'},
    );

    await tester.pumpWidget(
      _host(
        BarcodeDetailsView(
          details: details,
          isProcessing: false,
          onScanAgain: () => scanAgainCalls++,
          onUse: () => useCalls++,
        ),
      ),
    );

    expect(find.text('Valid'), findsOneWidget);
    await tester.tap(find.text('Scan Again'));
    await tester.tap(find.text('Use Barcode'));
    expect(scanAgainCalls, 1);
    expect(useCalls, 1);
  });

  testWidgets('wired scanner view preserves connected status', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          height: 400,
          child: WiredScannerReadyView(
            availability: ScannerAvailability.wiredConnected,
            isProcessing: false,
          ),
        ),
      ),
    );

    expect(find.text('Scanner ready — waiting for scan'), findsOneWidget);
    expect(find.text('Scanner active'), findsOneWidget);
  });

  testWidgets('scanner view delegates camera and wired toggles', (
    tester,
  ) async {
    final wiredFocusNode = FocusNode();
    final manualFocusNode = FocusNode();
    final manualController = TextEditingController();
    addTearDown(wiredFocusNode.dispose);
    addTearDown(manualFocusNode.dispose);
    addTearDown(manualController.dispose);
    var cameraCalls = 0;
    var wiredCalls = 0;

    await tester.pumpWidget(
      _host(
        BarcodeScannerView(
          wiredFocusNode: wiredFocusNode,
          manualController: manualController,
          manualFocusNode: manualFocusNode,
          scannerKey: const ValueKey('scanner'),
          scanMode: ScanMode.single,
          availability: ScannerAvailability.wiredUnknown,
          isScannable: true,
          showCameraButton: true,
          showWiredToggle: true,
          isCameraActive: false,
          isWiredActive: false,
          isProcessing: false,
          errorMessage: null,
          onKeyEvent: (_) {},
          onToggleCamera: () => cameraCalls++,
          onToggleWired: () => wiredCalls++,
          onDetected: (_) {},
          onCameraBecameAvailable: () {},
          onCameraUnavailable: () {},
          onDismissError: () {},
        ),
      ),
    );

    await tester.tap(find.text('Scan with Camera'));
    await tester.tap(find.text('Wired Scanner'));
    expect(cameraCalls, 1);
    expect(wiredCalls, 1);
  });
}
