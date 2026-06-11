import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/object_event_help_widget.dart';
/// Entry dialogs for EPC class, quantity, source, destination, and ILMD.
class ObjectEventFormEntryDialogs {
  ObjectEventFormEntryDialogs._();

  static Future<void> showAddEpcClass({
    required BuildContext context,
    required void Function(String epcClass) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String epcClass = '';
        return AlertDialog(
          title: const Text('Add EPC Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'EPC Class',
                  hintText: 'Enter EPC class value',
                ),
                onChanged: (value) => epcClass = value,
              ),
              const SizedBox(height: 10),
              const Text(
                'Format: urn:epc:idpat:sgtin:CompanyPrefix.ItemReference.*',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (epcClass.isNotEmpty) onAdd(epcClass);
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAddQuantity({
    required BuildContext context,
    required void Function(types.QuantityElement quantity) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String epcClass = '';
        double quantity = 0;
        String? uom;
        return AlertDialog(
          title: const Text('Add Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'EPC Class',
                  hintText: 'Enter EPC class',
                ),
                onChanged: (value) => epcClass = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity value',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => quantity = double.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Unit of Measure (optional)',
                  hintText: 'E.g., KGM, EA, CS',
                ),
                onChanged: (value) => uom = value.isNotEmpty ? value : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (epcClass.isNotEmpty && quantity > 0) {
                  onAdd(
                    types.QuantityElement(
                      epcClass: epcClass,
                      quantity: quantity,
                      uom: uom,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAddIlmd({
    required BuildContext context,
    required void Function(String key, String value) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String key = '';
        String value = '';
        return AlertDialog(
          title: const Text('Add Instance/Lot Master Data (ILMD)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Key',
                  hintText: 'Enter key',
                ),
                onChanged: (val) => key = val,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter value',
                ),
                onChanged: (val) => value = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.isNotEmpty && value.isNotEmpty) onAdd(key, value);
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAddSource({
    required BuildContext context,
    required void Function(types.SourceDestination source) onAdd,
  }) {
    return _showSourceDestinationDialog(
      context: context,
      title: 'Add Source',
      typeLabel: 'Source Type',
      onAdd: onAdd,
    );
  }

  static Future<void> showAddDestination({
    required BuildContext context,
    required void Function(types.SourceDestination destination) onAdd,
  }) {
    return _showSourceDestinationDialog(
      context: context,
      title: 'Add Destination',
      typeLabel: 'Destination Type',
      onAdd: onAdd,
    );
  }

  static Future<void> _showSourceDestinationDialog({
    required BuildContext context,
    required String title,
    required String typeLabel,
    required void Function(types.SourceDestination entry) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String type = 'owning_party';
        String id = '';
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(labelText: typeLabel),
                items: const [
                  DropdownMenuItem(
                    value: 'owning_party',
                    child: Text('Owning Party'),
                  ),
                  DropdownMenuItem(
                    value: 'possessing_party',
                    child: Text('Possessing Party'),
                  ),
                  DropdownMenuItem(value: 'location', child: Text('Location')),
                ],
                onChanged: (value) => type = value!,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'GLN or Identifier',
                  hintText: 'e.g., 0614141000005',
                ),
                onChanged: (value) => id = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (id.isNotEmpty) {
                  onAdd(types.SourceDestination(type: type, id: id));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

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
                const Text('• For ADD action: lot number is required'),
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
