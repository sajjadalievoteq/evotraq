import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_document_provider.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class TransactionDocumentScreen extends StatefulWidget {
  const TransactionDocumentScreen({Key? key}) : super(key: key);

  @override
  _TransactionDocumentScreenState createState() => _TransactionDocumentScreenState();
}

class _TransactionDocumentScreenState extends State<TransactionDocumentScreen> {
  final _documentTypeController = TextEditingController();
  final _documentIdController = TextEditingController();
  final _sourceTypeController = TextEditingController();
  final _sourceIdController = TextEditingController();
  final _targetTypeController = TextEditingController();
  final _targetIdController = TextEditingController();
  final _relationshipTypeController = TextEditingController();
  final _epcController = TextEditingController();
  
  final List<String> _standardDocumentTypes = [
    'urn:epcglobal:cbv:btt:inv',
    'urn:epcglobal:cbv:btt:po',
    'urn:epcglobal:cbv:btt:desadv',
    'urn:epcglobal:cbv:btt:packing-list',
    'urn:epcglobal:cbv:btt:receipt',
    'urn:epcglobal:cbv:btt:bol',
    'urn:epcglobal:cbv:btt:cert',
    'urn:epcglobal:cbv:btt:pedigree',
    'urn:epcglobal:cbv:btt:prodorder',
    'urn:epcglobal:cbv:btt:transdoc',
    'urn:epcglobal:cbv:btt:customs',
    'urn:epcglobal:cbv:btt:contract',
  ];
  
  final List<String> _standardRelationshipTypes = [
    'references',
    'replaces',
    'fulfills',
    'contains',
    'origin',
    'destination',
    'related',
  ];
  
  @override
  void dispose() {
    _documentTypeController.dispose();
    _documentIdController.dispose();
    _sourceTypeController.dispose();
    _sourceIdController.dispose();
    _targetTypeController.dispose();
    _targetIdController.dispose();
    _relationshipTypeController.dispose();
    _epcController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final documentCubit = context.read<TransactionDocumentCubit>();
    final documentState = context.watch<TransactionDocumentCubit>().state;
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Transaction Document Operations'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            tooltip: 'Help',
            onPressed: () {
              context.go('/epcis/transaction-documents/help');
            },
          ),
        ],
      ),
      body: documentState.isLoading 
        ? const Center(child: AppLoadingIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (documentState.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(8),
                    color: Colors.red[100],
                    child: Row(
                      children: [
                        TraqIcon(AppAssets.iconAlert, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(documentState.error!)),
                        IconButton(
                          icon: TraqIcon(AppAssets.iconX),
                          onPressed: () => documentCubit.clearError(),
                        ),
                      ],
                    ),
                  ),
                
                _buildSection(
                  title: 'Find Events by Document',
                  children: [
                    _buildDocumentTypeDropdown(_documentTypeController),
                    _buildTextField(_documentIdController, 'Document ID'),
                    ElevatedButton(
                      onPressed: () {
                        final type = _documentTypeController.text.trim();
                        final id = _documentIdController.text.trim();
                        
                        if (type.isEmpty || id.isEmpty) {
                          context.showError(
                            'Document type and ID cannot be empty',
                          );
                          return;
                        }
                        
                        documentCubit.getTransactionEventsForDocument(type, id);
                      },
                      child: const Text('Find Events'),
                    ),
                    if (documentState.events.isNotEmpty)
                      _buildEventsList(documentState.events)
                  ],
                ),
                
                _buildSection(
                  title: 'Validate Document Reference',
                  children: [
                    _buildDocumentTypeDropdown(_documentTypeController),
                    _buildTextField(_documentIdController, 'Document ID'),
                    ElevatedButton(
                      onPressed: () async {
                        final type = _documentTypeController.text.trim();
                        final id = _documentIdController.text.trim();
                        
                        if (type.isEmpty || id.isEmpty) {
                          context.showError(
                            'Document type and ID cannot be empty',
                          );
                          return;
                        }
                        
                        try {
                          final isValid = await documentCubit.validateDocumentReference(type, id);
                          if (!mounted) return;
                          
                          if (isValid) {
                            context.showSuccess('Document reference is valid');
                          } else {
                            context.showError('Document reference is not valid');
                          }
                        } catch (e) {
                          if (!mounted) return;
                          context.showError('Error: ${e.toString()}');
                        }
                      },
                      child: const Text('Validate'),
                    ),
                  ],
                ),
                
                _buildSection(
                  title: 'Get Document Status',
                  children: [
                    _buildDocumentTypeDropdown(_documentTypeController),
                    _buildTextField(_documentIdController, 'Document ID'),
                    ElevatedButton(
                      onPressed: () {
                        final type = _documentTypeController.text.trim();
                        final id = _documentIdController.text.trim();
                        
                        if (type.isEmpty || id.isEmpty) {
                          context.showError(
                            'Document type and ID cannot be empty',
                          );
                          return;
                        }
                        
                        documentCubit.getDocumentStatus(type, id);
                      },
                      child: const Text('Get Status'),
                    ),
                    if (documentState.documentStatus.isNotEmpty)
                      _buildStatusCard(documentState.documentStatus)
                  ],
                ),
                
                _buildSection(
                  title: 'Get Related Documents',
                  children: [
                    _buildDocumentTypeDropdown(_documentTypeController),
                    _buildTextField(_documentIdController, 'Document ID'),
                    ElevatedButton(
                      onPressed: () {
                        final type = _documentTypeController.text.trim();
                        final id = _documentIdController.text.trim();
                        
                        if (type.isEmpty || id.isEmpty) {
                          context.showError(
                            'Document type and ID cannot be empty',
                          );
                          return;
                        }
                        
                        documentCubit.getRelatedDocuments(type, id);
                      },
                      child: const Text('Get Related Documents'),
                    ),
                    if (documentState.relatedDocuments.isNotEmpty)
                      _buildRelatedDocumentsCard(documentState.relatedDocuments)
                  ],
                ),
                
                _buildSection(
                  title: 'Create Document Link',
                  children: [
                    _buildDocumentTypeField(_sourceTypeController, 'Source Document Type'),
                    _buildTextField(_sourceIdController, 'Source Document ID'),
                    _buildDocumentTypeField(_targetTypeController, 'Target Document Type'),
                    _buildTextField(_targetIdController, 'Target Document ID'),
                    _buildRelationshipTypeDropdown(_relationshipTypeController),
                    ElevatedButton(
                      onPressed: () async {
                        final sourceType = _sourceTypeController.text.trim();
                        final sourceId = _sourceIdController.text.trim();
                        final targetType = _targetTypeController.text.trim();
                        final targetId = _targetIdController.text.trim();
                        final relationshipType = _relationshipTypeController.text.trim();
                        
                        if (sourceType.isEmpty || sourceId.isEmpty || 
                            targetType.isEmpty || targetId.isEmpty ||
                            relationshipType.isEmpty) {
                          context.showError('All fields are required');
                          return;
                        }
                        
                        try {
                          final success = await documentCubit.createDocumentLink(
                            sourceType,
                            sourceId,
                            targetType,
                            targetId,
                            relationshipType
                          );
                          if (!mounted) return;
                          
                          if (success) {
                            context.showSuccess('Document link created successfully');
                          } else {
                            context.showError('Failed to create document link');
                          }
                        } catch (e) {
                          if (!mounted) return;
                          context.showError('Error: ${e.toString()}');
                        }
                      },
                      child: const Text('Create Link'),
                    ),
                  ],
                ),
                
                _buildSection(
                  title: 'Find Original Document for EPC',
                  children: [
                    _buildTextField(_epcController, 'EPC (e.g., urn:epc:id:sgtin:...)'),
                    _buildOptionalDocumentTypeDropdown(_documentTypeController),
                    ElevatedButton(
                      onPressed: () async {
                        final epc = _epcController.text.trim();
                        final type = _documentTypeController.text.isEmpty 
                          ? null 
                          : _documentTypeController.text.trim();
                          
                        if (epc.isEmpty) {
                          context.showError('EPC cannot be empty');
                          return;
                        }
                        
                        try {
                          final document = await documentCubit.findOriginalDocumentForEPC(epc, type: type);
                          if (!mounted) return;
                          
                          if (document != null) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Original Document'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Type: ${document['type'] ?? 'N/A'}'),
                                    Text('ID: ${document['id'] ?? 'N/A'}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            context.showWarning(
                              'No original document found for this EPC',
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          context.showError('Error: ${e.toString()}');
                        }
                      },
                      child: const Text('Find Original Document'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  
  Widget _buildDocumentTypeDropdown(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        initialValue: controller.text,
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            isEmpty: controller.text.isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isNotEmpty ? controller.text : null,
                isDense: true,
                isExpanded: true,
                hint: const Text('Select Document Type'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.text = newValue;
                    state.didChange(newValue);
                  }
                },
                items: _standardDocumentTypes.map((String value) {
                  String displayName = value;
                  
                  if (value.startsWith('urn:epcglobal:cbv:btt:')) {
                    String shortName = value.substring('urn:epcglobal:cbv:btt:'.length);
                    
                    switch (shortName) {
                      case 'inv': displayName = 'Invoice'; break;
                      case 'po': displayName = 'Purchase Order'; break;
                      case 'desadv': displayName = 'Despatch Advice'; break;
                      case 'packing-list': displayName = 'Packing List'; break;
                      case 'receipt': displayName = 'Receipt Advice'; break;
                      case 'bol': displayName = 'Bill of Lading'; break;
                      case 'cert': displayName = 'Certificate'; break;
                      case 'pedigree': displayName = 'Pedigree'; break;
                      case 'prodorder': displayName = 'Production Order'; break;
                      case 'transdoc': displayName = 'Transport Document'; break;
                      case 'customs': displayName = 'Customs Declaration'; break;
                      case 'contract': displayName = 'Contract'; break;
                      default: displayName = shortName; break;
                    }
                  }
                  
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(displayName),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOptionalDocumentTypeDropdown(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        initialValue: controller.text,
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            isEmpty: controller.text.isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isNotEmpty ? controller.text : null,
                isDense: true,
                isExpanded: true,
                hint: const Text('Select Document Type (optional)'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.text = newValue;
                    state.didChange(newValue);
                  }
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Any document type'),
                  ),
                  ..._standardDocumentTypes.map((String value) {
                    String displayName = value;
                    
                    if (value.startsWith('urn:epcglobal:cbv:btt:')) {
                      String shortName = value.substring('urn:epcglobal:cbv:btt:'.length);
                      
                      switch (shortName) {
                        case 'inv': displayName = 'Invoice'; break;
                        case 'po': displayName = 'Purchase Order'; break;
                        case 'desadv': displayName = 'Despatch Advice'; break;
                        case 'packing-list': displayName = 'Packing List'; break;
                        case 'receipt': displayName = 'Receipt Advice'; break;
                        case 'bol': displayName = 'Bill of Lading'; break;
                        case 'cert': displayName = 'Certificate'; break;
                        case 'pedigree': displayName = 'Pedigree'; break;
                        case 'prodorder': displayName = 'Production Order'; break;
                        case 'transdoc': displayName = 'Transport Document'; break;
                        case 'customs': displayName = 'Customs Declaration'; break;
                        case 'contract': displayName = 'Contract'; break;
                        default: displayName = shortName; break;
                      }
                    }
                    
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(displayName),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDocumentTypeField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        initialValue: controller.text,
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            isEmpty: controller.text.isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isNotEmpty ? controller.text : null,
                isDense: true,
                isExpanded: true,
                hint: Text('Select $label'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.text = newValue;
                    state.didChange(newValue);
                  }
                },
                items: _standardDocumentTypes.map((String value) {
                  String displayName = value;
                  
                  if (value.startsWith('urn:epcglobal:cbv:btt:')) {
                    String shortName = value.substring('urn:epcglobal:cbv:btt:'.length);
                    
                    switch (shortName) {
                      case 'inv': displayName = 'Invoice'; break;
                      case 'po': displayName = 'Purchase Order'; break;
                      case 'desadv': displayName = 'Despatch Advice'; break;
                      case 'packing-list': displayName = 'Packing List'; break;
                      case 'receipt': displayName = 'Receipt Advice'; break;
                      case 'bol': displayName = 'Bill of Lading'; break;
                      case 'cert': displayName = 'Certificate'; break;
                      case 'pedigree': displayName = 'Pedigree'; break;
                      case 'prodorder': displayName = 'Production Order'; break;
                      case 'transdoc': displayName = 'Transport Document'; break;
                      case 'customs': displayName = 'Customs Declaration'; break;
                      case 'contract': displayName = 'Contract'; break;
                      default: displayName = shortName; break;
                    }
                  }
                  
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(displayName),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRelationshipTypeDropdown(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        initialValue: controller.text,
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            isEmpty: controller.text.isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isNotEmpty ? controller.text : null,
                isDense: true,
                isExpanded: true,
                hint: const Text('Select Relationship Type'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.text = newValue;
                    state.didChange(newValue);
                  }
                },
                items: _standardRelationshipTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEventsList(List<TransactionEvent> events) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Events Found: ${events.length}', 
              style: Theme.of(context).textTheme.titleMedium),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.id ?? 'No ID'),
                subtitle: Text('${event.eventTime} | ${event.action}'),
                trailing: event.bizTransactionList.isNotEmpty
                  ? Text('${event.bizTransactionList.length} transactions')
                  : const Text('No transactions'),
                onTap: () {
                  if (event.bizTransactionList.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Transaction Documents'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: event.bizTransactionList.entries.map((entry) {
                            String displayType = entry.key;
                            if (displayType.startsWith('urn:epcglobal:cbv:btt:')) {
                              String shortName = displayType.substring('urn:epcglobal:cbv:btt:'.length);
                              switch (shortName) {
                                case 'inv': displayType = 'Invoice'; break;
                                case 'po': displayType = 'Purchase Order'; break;
                                case 'desadv': displayType = 'Despatch Advice'; break;
                                default: displayType = shortName; break;
                              }
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$displayType: ', 
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(entry.value)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(Map<String, dynamic> status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: status.entries.map((entry) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('${entry.key}: ', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(entry.value.toString())),
                ],
              ),
            )
          ).toList(),
        ),
      ),
    );
  }
  
  Widget _buildRelatedDocumentsCard(Map<String, List<String>> documents) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: documents.entries.map((entry) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key}: ', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...entry.value.map((doc) => 
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('• $doc'),
                    )
                  ).toList(),
                ],
              ),
            )
          ).toList(),
        ),
      ),
    );
  }
}
