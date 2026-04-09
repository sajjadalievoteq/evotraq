import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

/// Screen for bulk importing object events
class ObjectEventBatchImportScreen extends StatefulWidget {
  const ObjectEventBatchImportScreen({Key? key}) : super(key: key);

  @override
  State<ObjectEventBatchImportScreen> createState() => _ObjectEventBatchImportScreenState();
}

class _ObjectEventBatchImportScreenState extends State<ObjectEventBatchImportScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Manual entry fields
  final _formKey = GlobalKey<FormState>();
  final _epcController = TextEditingController();
  final _businessStepController = TextEditingController();
  final _dispositionController = TextEditingController();
  final _businessLocationController = TextEditingController();
  final _readPointController = TextEditingController();
  final _lotController = TextEditingController();
  
  String _selectedAction = 'ADD';
  List<String> _epcList = [];
  List<ObjectEvent> _pendingEvents = [];
  
  // CSV import
  final _csvController = TextEditingController();
  List<Map<String, dynamic>> _csvData = [];
  
  // Import results
  bool _isImporting = false;
  String? _importError;
  Map<String, dynamic>? _importResults;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _epcController.dispose();
    _businessStepController.dispose();
    _dispositionController.dispose();
    _businessLocationController.dispose();
    _readPointController.dispose();
    _lotController.dispose();
    _csvController.dispose();
    super.dispose();
  }
  
  void _addManualEvent() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      
      // Create ILMD data
      final ilmd = <String, dynamic>{};
      if (_lotController.text.isNotEmpty) {
        ilmd['LOT'] = _lotController.text;
      }
      
      for (String epc in _epcList) {
        final event = ObjectEvent(
          eventId: 'urn:epcglobal:cbv:epcis:event:${DateTime.now().millisecondsSinceEpoch}-${_pendingEvents.length}',
          eventTime: now,
          recordTime: now,
          eventTimeZone: '+00:00',
          epcisVersion: EPCISVersion.v2_0,
          action: _selectedAction,
          businessStep: _businessStepController.text,
          disposition: _dispositionController.text,
          businessLocation: _businessLocationController.text.isNotEmpty 
              ? GLN.fromCode(_businessLocationController.text) 
              : null,
          readPoint: _readPointController.text.isNotEmpty 
              ? GLN.fromCode(_readPointController.text) 
              : null,
          epcList: [epc],
          ilmd: ilmd.isNotEmpty ? ilmd : null,
        );
        
        _pendingEvents.add(event);
      }
      
      setState(() {
        _epcList.clear();
        _epcController.clear();
        _lotController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${_epcList.length} events to batch')),
      );
    }
  }
  
  void _addEPC() {
    final epc = _epcController.text.trim();
    if (epc.isNotEmpty) {
      // Format EPC to URI if it's in GS1 barcode format
      final formattedEpc = EPCFormatter.formatToEPCUri(epc);
      
      if (!_epcList.contains(formattedEpc)) {
        setState(() {
          _epcList.add(formattedEpc);
          _epcController.clear();
        });
      }
    }
  }
  
  void _removeEPC(String epc) {
    setState(() {
      _epcList.remove(epc);
    });
  }
  
  void _parseCsvData() {
    try {
      final csvText = _csvController.text.trim();
      if (csvText.isEmpty) return;
      
      final lines = csvText.split('\n');
      if (lines.isEmpty) return;
      
      final headers = lines.first.split(',').map((h) => h.trim()).toList();
      final dataRows = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
      
      _csvData.clear();
      
      for (String line in dataRows) {
        final values = line.split(',').map((v) => v.trim()).toList();
        Map<String, dynamic> row = {};
        
        for (int i = 0; i < headers.length && i < values.length; i++) {
          row[headers[i]] = values[i];
        }
        
        _csvData.add(row);
      }
      
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parsed ${_csvData.length} rows from CSV')),
      );
      
    } catch (e) {
      setState(() {
        _importError = 'Error parsing CSV: $e';
      });
    }
  }
  
  List<ObjectEvent> _createEventsFromCsv() {
    List<ObjectEvent> events = [];
    
    for (Map<String, dynamic> row in _csvData) {
      try {
        final now = DateTime.now();
        
        // Extract required fields - adjust column names as needed
        String? epc = row['EPC'] ?? row['epc'];
        String? action = row['Action'] ?? row['action'] ?? 'ADD';
        String? businessStep = row['BusinessStep'] ?? row['businessStep'] ?? row['business_step'];
        String? disposition = row['Disposition'] ?? row['disposition'];
        String? businessLocation = row['BusinessLocation'] ?? row['businessLocation'] ?? row['business_location'];
        String? readPoint = row['ReadPoint'] ?? row['readPoint'] ?? row['read_point'];
        String? lot = row['Lot'] ?? row['lot'] ?? row['LOT'];
        
        if (epc == null || epc.isEmpty) continue;
        if (businessStep == null || businessStep.isEmpty) continue;
        if (disposition == null || disposition.isEmpty) continue;
        
        // Convert EPC to URI format if it's in GS1 barcode format
        final formattedEpc = EPCFormatter.formatToEPCUri(epc);
        
        // Create ILMD
        final ilmd = <String, dynamic>{};
        if (lot != null && lot.isNotEmpty) {
          ilmd['LOT'] = lot;
        }
        
        final event = ObjectEvent(
          eventId: 'urn:epcglobal:cbv:epcis:event:${now.millisecondsSinceEpoch}-${events.length}',
          eventTime: now,
          recordTime: now,
          eventTimeZone: '+00:00',
          epcisVersion: EPCISVersion.v2_0,
          action: action?.toUpperCase() ?? 'ADD',
          businessStep: businessStep,
          disposition: disposition,
          businessLocation: businessLocation != null && businessLocation.isNotEmpty 
              ? GLN.fromCode(businessLocation) 
              : null,
          readPoint: readPoint != null && readPoint.isNotEmpty 
              ? GLN.fromCode(readPoint) 
              : null,
          epcList: [formattedEpc],
          ilmd: ilmd.isNotEmpty ? ilmd : null,
        );
        
        events.add(event);
      } catch (e) {
        // Skip invalid rows
        continue;
      }
    }
    
    return events;
  }
  
  Future<void> _importEvents() async {
    List<ObjectEvent> eventsToImport = [];
    
    // Combine manual events and CSV events
    eventsToImport.addAll(_pendingEvents);
    
    if (_tabController.index == 1 && _csvData.isNotEmpty) {
      eventsToImport.addAll(_createEventsFromCsv());
    }
    
    if (eventsToImport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No events to import')),
      );
      return;
    }
    
    setState(() {
      _isImporting = true;
      _importError = null;
      _importResults = null;
    });
    
    try {
      final cubit = context.read<ObjectEventsCubit>();
      final results = await cubit.createEventsBatch(eventsToImport);
      
      setState(() {
        _importResults = {
          'success': true,
          'totalEvents': eventsToImport.length,
          'successfulEvents': results.length,
          'failedEvents': eventsToImport.length - results.length,
        };
        _pendingEvents.clear();
        _csvData.clear();
        _csvController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported ${results.length} events'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      setState(() {
        _importError = e.toString();
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Import Object Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Manual Entry', icon: Icon(Icons.edit)),
            Tab(text: 'CSV Import', icon: Icon(Icons.upload_file)),
          ],
        ),
        actions: [
          if (_pendingEvents.isNotEmpty || (_tabController.index == 1 && _csvData.isNotEmpty))
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              onPressed: _isImporting ? null : _importEvents,
              tooltip: 'Import Events',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isImporting
          ? const Center(child: AppLoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildManualEntryTab(),
                _buildCsvImportTab(),
              ],
            ),
    );
  }
  
  Widget _buildManualEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Action dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Action *',
                        border: OutlineInputBorder(),
                      ),
                      items: ['ADD', 'OBSERVE', 'DELETE'].map((action) {
                        return DropdownMenuItem(value: action, child: Text(action));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Business Step
                    TextFormField(
                      controller: _businessStepController,
                      decoration: const InputDecoration(
                        labelText: 'Business Step *',
                        hintText: 'e.g., urn:epcglobal:cbv:bizstep:commissioning',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Business step is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Disposition
                    TextFormField(
                      controller: _dispositionController,
                      decoration: const InputDecoration(
                        labelText: 'Disposition *',
                        hintText: 'e.g., urn:epcglobal:cbv:disp:active',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Disposition is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Business Location
                    TextFormField(
                      controller: _businessLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Business Location GLN',
                        hintText: 'e.g., 6290360400006',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Read Point
                    TextFormField(
                      controller: _readPointController,
                      decoration: const InputDecoration(
                        labelText: 'Read Point GLN',
                        hintText: 'e.g., 6290360400006',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // EPCs card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EPCs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _epcController,
                            decoration: const InputDecoration(
                              labelText: 'EPC',
                              hintText: 'URI: urn:epc:id:sgtin:5415062.32581.70007488444899\nGS1: (01)05415062325810(21)70007488444899',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) => _addEPC(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addEPC,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    
                    if (_epcList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Added EPCs:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _epcList.map((epc) {
                          return Chip(
                            label: Text(epc),
                            onDeleted: () => _removeEPC(epc),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ILMD card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instance/Lot Master Data (ILMD)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _lotController,
                      decoration: const InputDecoration(
                        labelText: 'Lot Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Add to batch button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _epcList.isNotEmpty ? _addManualEvent : null,
                child: const Text('Add to Batch'),
              ),
            ),
            
            if (_pendingEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Events: ${_pendingEvents.length}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._pendingEvents.take(5).map((event) {
                        return ListTile(
                          title: Text('${event.action}: ${event.epcList?.first ?? 'No EPC'}'),
                          subtitle: Text(event.businessStep ?? 'No business step'),
                          dense: true,
                        );
                      }).toList(),
                      if (_pendingEvents.length > 5)
                        Text('... and ${_pendingEvents.length - 5} more'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCsvImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CSV input
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
                    controller: _csvController,
                    decoration: const InputDecoration(
                      labelText: 'Paste CSV data here',
                      hintText: 'EPC,Action,BusinessStep,Disposition,BusinessLocation,ReadPoint,Lot\nurn:epc:id:sgtin:5415062.32581.70007488444899,ADD,urn:epcglobal:cbv:bizstep:commissioning,urn:epcglobal:cbv:disp:active,6290360400006,,LOT123\n(01)05415062325810(21)70007488444899,ADD,urn:epcglobal:cbv:bizstep:commissioning,urn:epcglobal:cbv:disp:active,6290360400006,,LOT123',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: _parseCsvData,
                    child: const Text('Parse CSV'),
                  ),
                ],
              ),
            ),
          ),
          
          // Preview
          if (_csvData.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview (${_csvData.length} rows)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _csvData.isNotEmpty 
                            ? _csvData.first.keys.map((key) => DataColumn(label: Text(key))).toList()
                            : [],
                        rows: _csvData.take(5).map((row) {
                          return DataRow(
                            cells: row.values.map((value) {
                              return DataCell(Text(value?.toString() ?? ''));
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    if (_csvData.length > 5)
                      Text('... and ${_csvData.length - 5} more rows'),
                  ],
                ),
              ),
            ),
          ],
          
          // Import results
          if (_importResults != null) ...[
            const SizedBox(height: 16),
            Card(
              color: _importResults!['success'] ? Colors.green[50] : Colors.red[50],
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
                        color: _importResults!['success'] ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total Events: ${_importResults!['totalEvents']}'),
                    Text('Successful: ${_importResults!['successfulEvents']}'),
                    Text('Failed: ${_importResults!['failedEvents']}'),
                  ],
                ),
              ),
            ),
          ],
          
          if (_importError != null) ...[
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
                    Text(_importError!),
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
