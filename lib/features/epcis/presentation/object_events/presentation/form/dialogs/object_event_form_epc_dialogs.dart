import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';

/// EPC-related dialogs: add, bulk add, generate, and scan.
class ObjectEventFormEpcDialogs {
  ObjectEventFormEpcDialogs._();

  static Future<void> showAddEpc({
    required BuildContext context,
    required void Function(String epc) onAdd,
    required VoidCallback onScanBarcode,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String epc = '';
        return AlertDialog(
          title: const Text('Add EPC'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'EPC',
                  hintText: 'Enter EPC value or scan barcode',
                ),
                onChanged: (value) => epc = value,
              ),
              const SizedBox(height: 10),
              const Text(
                'Formats accepted:\n'
                '• URI: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber\n'
                '• GS1: (01)05415062325810(21)70005188444899',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  onScanBarcode();
                },
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
                if (epc.isNotEmpty) {
                  onAdd(EPCFormatter.formatToEPCUri(epc));
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

  static Future<void> showBulkAddEpcs({
    required BuildContext context,
    required void Function(List<String> epcs) onAddAll,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String bulkEpcs = '';
        return AlertDialog(
          title: const Text('Bulk Add EPCs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'EPCs (one per line)',
                  hintText: 'Enter multiple EPCs, one per line',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => bulkEpcs = value,
              ),
              const SizedBox(height: 10),
              const Text(
                'Each line should contain one EPC. Format: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber',
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
                if (bulkEpcs.isNotEmpty) {
                  final lines = bulkEpcs
                      .split('\n')
                      .map((line) => line.trim())
                      .where((line) => line.isNotEmpty)
                      .map(EPCFormatter.formatToEPCUri)
                      .toList();
                  onAddAll(lines);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Add All'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showGenerateEpcs({
    required BuildContext context,
    required void Function(List<String> epcs) onGenerate,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        String companyPrefix = '0614141';
        String itemReference = '107346';
        int count = 1;
        int startSerial = 1000;

        return AlertDialog(
          title: const Text('Generate GS1 EPCs'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Company Prefix',
                        hintText: 'Enter GS1 Company Prefix',
                      ),
                      initialValue: companyPrefix,
                      onChanged: (value) => companyPrefix = value,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Item Reference',
                        hintText: 'Enter Item Reference',
                      ),
                      initialValue: itemReference,
                      onChanged: (value) => itemReference = value,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Count',
                              hintText: 'Number of EPCs',
                            ),
                            initialValue: '1',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setDialogState(() {
                                count = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Serial',
                              hintText: 'Starting serial number',
                            ),
                            initialValue: '1000',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setDialogState(() {
                                startSerial = int.tryParse(value) ?? 1000;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Will generate $count SGTIN(s) starting from $startSerial',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SGTINs follow format: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (companyPrefix.isNotEmpty && itemReference.isNotEmpty) {
                  onGenerate(
                    GS1Generator.generateBatchSGTINs(
                      companyPrefix,
                      itemReference,
                      count,
                      startSerial: startSerial,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showScanBarcode({
    required BuildContext context,
    required void Function(String epc) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Barcode Scanner'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 48),
              SizedBox(height: 16),
              Text('This is a placeholder for the barcode scanner.'),
              SizedBox(height: 8),
              Text(
                'In a production app, this would launch the device camera to scan GS1 barcodes.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final demoEpc =
                    'urn:epc:id:sgtin:0614141.107346.${DateTime.now().millisecondsSinceEpoch % 10000}';
                onAdd(demoEpc);
                Navigator.pop(dialogContext);
              },
              child: const Text('Simulate URI Scan'),
            ),
            TextButton(
              onPressed: () {
                final demoGS1 =
                    '(01)00614141107346(21)${DateTime.now().millisecondsSinceEpoch % 10000}';
                onAdd(EPCFormatter.formatToEPCUri(demoGS1));
                Navigator.pop(dialogContext);
              },
              child: const Text('Simulate GS1 Scan'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
