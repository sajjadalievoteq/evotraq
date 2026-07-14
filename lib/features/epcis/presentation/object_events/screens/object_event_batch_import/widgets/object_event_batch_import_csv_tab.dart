import 'package:flutter/material.dart';

class ObjectEventBatchImportCsvTab extends StatelessWidget {
  const ObjectEventBatchImportCsvTab({
    super.key,
    required this.csvController,
    required this.csvData,
    required this.importResults,
    required this.importError,
    required this.onParseCsv,
  });

  final TextEditingController csvController;
  final List<Map<String, dynamic>> csvData;
  final Map<String, dynamic>? importResults;
  final String? importError;
  final VoidCallback onParseCsv;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CSV Data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Expected CSV format:\nEPC,Action,BusinessStep,Disposition,BusinessLocation,ReadPoint,Lot',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: csvController,
                    decoration: const InputDecoration(
                      labelText: 'Paste CSV data here',
                      hintText:
                          'EPC,Action,BusinessStep,Disposition,BusinessLocation,ReadPoint,Lot\nhttps://id.gs1.org/01/05415062325810/21/70007488444899,ADD,urn:epcglobal:cbv:bizstep:commissioning,urn:epcglobal:cbv:disp:active,6290360400006,,LOT123\n(01)05415062325810(21)70007488444899,ADD,urn:epcglobal:cbv:bizstep:commissioning,urn:epcglobal:cbv:disp:active,6290360400006,,LOT123',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onParseCsv,
                    child: const Text('Parse CSV'),
                  ),
                ],
              ),
            ),
          ),
          if (csvData.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview (${csvData.length} rows)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: csvData.isNotEmpty
                            ? csvData.first.keys
                                .map((key) => DataColumn(label: Text(key)))
                                .toList()
                            : [],
                        rows: csvData.take(5).map((row) {
                          return DataRow(
                            cells: row.values.map((value) {
                              return DataCell(Text(value?.toString() ?? ''));
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                    if (csvData.length > 5)
                      Text('... and ${csvData.length - 5} more rows'),
                  ],
                ),
              ),
            ),
          ],
          if (importResults != null) ...[
            const SizedBox(height: 16),
            Card(
              color: importResults!['success']
                  ? Colors.green[50]
                  : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: importResults!['success']
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total Events: ${importResults!['totalEvents']}'),
                    Text('Successful: ${importResults!['successfulEvents']}'),
                    Text('Failed: ${importResults!['failedEvents']}'),
                  ],
                ),
              ),
            ),
          ],
          if (importError != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(importError!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
