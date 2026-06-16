import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/object_event_help_widget.dart';

class ObjectEventFormEntryDialogs {
  ObjectEventFormEntryDialogs._();

  static Future<void> showHelpDialog({required BuildContext context}) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('GS1 Object Event Help'),
                centerTitle: true,
                automaticallyImplyLeading: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: const ObjectEventHelpWidget(),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showValidationErrors({
    required BuildContext context,
    required List<String> errors,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Validation Errors'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...errors
                  .map(
                    (error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              if (errors.any(
                (error) =>
                    error.contains('409') ||
                    error.contains('Enhanced validation failed'),
              )) ...[
                const Divider(height: 20),
                const Text(
                  'Troubleshooting Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('• Ensure all required fields are filled'),
                const Text('• Check GLN formats (13 digits)'),
                const Text('• Verify EPC format if using EPCs'),
                const Text('• Ensure proper business step format (CBV)'),
                const Text(
                  '• Check that only one of EPC List or Quantity List is used',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Future<void> showSchemaValidationTestResults({
    required BuildContext context,
    required bool passed,
    String? error,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Schema Validation Test Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minimal event test: ${passed ? "PASSED" : "FAILED"}'),
              if (!passed)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Errors: ${error ?? "Unknown error"}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
