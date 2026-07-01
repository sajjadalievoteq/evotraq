import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_batch_import/widgets/object_event_batch_import_csv_tab.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_batch_import/widgets/object_event_batch_import_manual_tab.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class ObjectEventBatchImportScreen extends StatefulWidget {
  const ObjectEventBatchImportScreen({Key? key}) : super(key: key);

  @override
  State<ObjectEventBatchImportScreen> createState() => _ObjectEventBatchImportScreenState();
}

class _ObjectEventBatchImportScreenState extends State<ObjectEventBatchImportScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
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
  
  final _csvController = TextEditingController();
  List<Map<String, dynamic>> _csvData = [];
  
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
      
      context.showInfo('Added ${_epcList.length} events to batch');
    }
  }
  
  void _addEPC() {
    final epc = _epcController.text.trim();
    if (epc.isNotEmpty) {
      final formattedEpc = EPCFormatter.formatToEPCUri(epc) ?? epc;
      
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
      
      context.showInfo('Parsed ${_csvData.length} rows from CSV');
      
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
        
        final formattedEpc = EPCFormatter.formatToEPCUri(epc) ?? epc;
        
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
        continue;
      }
    }
    
    return events;
  }
  
  Future<void> _importEvents() async {
    List<ObjectEvent> eventsToImport = [];
    
    eventsToImport.addAll(_pendingEvents);
    
    if (_tabController.index == 1 && _csvData.isNotEmpty) {
      eventsToImport.addAll(_createEventsFromCsv());
    }
    
    if (eventsToImport.isEmpty) {
      context.showInfo('No events to import');
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
      
      context.showSuccess('Successfully imported ${results.length} events');
      
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
            Tab(text: 'Manual Entry', icon: TraqIcon(AppAssets.iconEdit)),
            Tab(text: 'CSV Import', icon: TraqIcon(AppAssets.iconUpload)),
          ],
        ),
        actions: [
          if (_pendingEvents.isNotEmpty || (_tabController.index == 1 && _csvData.isNotEmpty))
            IconButton(
              icon: const TraqIcon(AppAssets.iconCloudUpload),
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
                ObjectEventBatchImportManualTab(
                  formKey: _formKey,
                  selectedAction: _selectedAction,
                  onActionChanged: (value) =>
                      setState(() => _selectedAction = value),
                  businessStepController: _businessStepController,
                  dispositionController: _dispositionController,
                  businessLocationController: _businessLocationController,
                  readPointController: _readPointController,
                  epcController: _epcController,
                  epcList: _epcList,
                  onAddEpc: _addEPC,
                  onRemoveEpc: _removeEPC,
                  lotController: _lotController,
                  onAddManualEvent: _addManualEvent,
                  pendingEvents: _pendingEvents,
                ),
                ObjectEventBatchImportCsvTab(
                  csvController: _csvController,
                  csvData: _csvData,
                  importResults: _importResults,
                  importError: _importError,
                  onParseCsv: _parseCsvData,
                ),
              ],
            ),
    );
  }
}