import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/field_validation_indicator.dart';

void main() {
  group('FieldValidationIndicator Widget Tests', () {
    testWidgets('should show nothing when not validated', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: false,
            ),
          ),
        ),
      );
      
      
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Valid'), findsNothing);
      expect(find.text('Invalid'), findsNothing);
    });
    
    testWidgets('should show help text when available', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: false,
              helpText: 'Enter a valid value',
            ),
          ),
        ),
      );
      
      
      expect(find.text('Enter a valid value'), findsOneWidget);
    });
    
    testWidgets('should show valid indicator when valid', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: true,
              isValid: true,
            ),
          ),
        ),
      );
      
      
      expect(find.text('Valid'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is TraqIcon && widget.asset == AppAssets.iconCheck,
        ),
        findsOneWidget,
      );
    });
    
    testWidgets('should show error message when invalid', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: true,
              isValid: false,
              errorMessage: 'This field is required',
            ),
          ),
        ),
      );
      
      
      expect(find.text('This field is required'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is TraqIcon && widget.asset == AppAssets.iconXCircle,
        ),
        findsOneWidget,
      );
    });
    
    testWidgets('should show invalid indicator when no error message', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: true,
              isValid: false,
              errorMessage: null,
            ),
          ),
        ),
      );
      
      
      expect(find.text('Invalid'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is TraqIcon && widget.asset == AppAssets.iconXCircle,
        ),
        findsOneWidget,
      );
    });
  });
}
