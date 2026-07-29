import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/services/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/ai_element_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/barcode_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/validate_tool.dart';

/// The instructions card must describe the mode that is actually selected.
void main() {
  Gs1ToolsCubit buildCubit() {
    final dio = DioService();
    return Gs1ToolsCubit(
      epcConversionService: EPCConversionService(dioService: dio),
      barcodeGenerationService: BarcodeGenerationService(dioService: dio),
      gs1BarcodeApiService: GS1BarcodeApiService(dioService: dio),
      serializationService: EPCISSerializationService(dioService: dio),
    );
  }

  Future<void> pumpTool(WidgetTester tester, Widget tool) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1200, 900),
            disableAnimations: true,
          ),
          child: BlocProvider.value(
            value: buildCubit(),
            child: Scaffold(body: tool),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> selectSegment(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<String>),
        matching: find.text(label),
      ),
    );
    await tester.pump();
  }

  Future<void> selectFromModeDropdown(
    WidgetTester tester,
    String label,
  ) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pump();
    await tester.tap(find.text(label).last);
    await tester.pump();
  }

  testWidgets('Application Identifier Parser help follows the mode', (
    tester,
  ) async {
    await pumpTool(tester, const AiElementTool());
    expect(find.textContaining('Decode a GS1 element string'), findsOneWidget);

    await selectSegment(tester, 'Build');
    expect(find.textContaining('Decode a GS1 element string'), findsNothing);
    expect(
      find.textContaining('Assemble a GS1 element string'),
      findsOneWidget,
    );

    await selectSegment(tester, 'AI table');
    expect(
      find.textContaining('Browse the bundled GS1 Application Identifier'),
      findsOneWidget,
    );
  });

  testWidgets('Validate help follows the mode', (tester) async {
    await pumpTool(tester, const ValidateTool());
    expect(find.textContaining('Check one GS1 identifier'), findsOneWidget);

    await selectFromModeDropdown(tester, 'Batch');
    expect(find.textContaining('Check one GS1 identifier'), findsNothing);
    expect(find.textContaining('Check a whole list'), findsOneWidget);

    await selectFromModeDropdown(tester, 'Anatomy');
    expect(
      find.textContaining('Break an identifier into its parts'),
      findsOneWidget,
    );
  });

  testWidgets('Barcode help follows the symbology', (tester) async {
    await pumpTool(tester, const BarcodeTool());
    expect(find.textContaining('GS1 DataMatrix'), findsWidgets);

    await selectFromModeDropdown(tester, 'Verify');
    expect(
      find.textContaining('Decode an existing barcode'),
      findsOneWidget,
    );

    await selectFromModeDropdown(tester, 'EAN-13');
    expect(find.textContaining('EAN‑13 retail barcode'), findsOneWidget);
  });
}
