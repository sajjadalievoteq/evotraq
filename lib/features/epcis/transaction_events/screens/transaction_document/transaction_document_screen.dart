import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/epcis/cubit/transaction_document_cubit.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_events_list.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_related_documents_card.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_section.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_status_card.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_text_field.dart';

class TransactionDocumentScreen extends StatefulWidget {
  const TransactionDocumentScreen({Key? key}) : super(key: key);

  @override
  _TransactionDocumentScreenState createState() =>
      _TransactionDocumentScreenState();
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
                    Builder(
                      builder: (context) {
                        final error = AppColorMapper.errorColor(context);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(8),
                          color: error.withValues(alpha: 0.2),
                          child: Row(
                            children: [
                              TraqIcon(AppAssets.iconAlert, color: error),
                              const SizedBox(width: 8),
                              Expanded(child: Text(documentState.error!)),
                              IconButton(
                                icon: TraqIcon(AppAssets.iconX),
                                onPressed: () => documentCubit.clearError(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  TransactionDocumentSection(
                    title: 'Find Events by Document',
                    children: [
                      TransactionDocumentDropdownField(
                        controller: _documentTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Document Type',
                        formatDocumentTypes: true,
                      ),
                      TransactionDocumentTextField(
                        controller: _documentIdController,
                        label: 'Document ID',
                      ),
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

                          documentCubit.getTransactionEventsForDocument(
                            type,
                            id,
                          );
                        },
                        child: const Text('Find Events'),
                      ),
                      if (documentState.events.isNotEmpty)
                        TransactionDocumentEventsList(
                          events: documentState.events,
                        ),
                    ],
                  ),

                  TransactionDocumentSection(
                    title: 'Validate Document Reference',
                    children: [
                      TransactionDocumentDropdownField(
                        controller: _documentTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Document Type',
                        formatDocumentTypes: true,
                      ),
                      TransactionDocumentTextField(
                        controller: _documentIdController,
                        label: 'Document ID',
                      ),
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
                            final isValid = await documentCubit
                                .validateDocumentReference(type, id);
                            if (!mounted) return;

                            if (isValid) {
                              context.showSuccess(
                                'Document reference is valid',
                              );
                            } else {
                              context.showError(
                                'Document reference is not valid',
                              );
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

                  TransactionDocumentSection(
                    title: 'Get Document Status',
                    children: [
                      TransactionDocumentDropdownField(
                        controller: _documentTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Document Type',
                        formatDocumentTypes: true,
                      ),
                      TransactionDocumentTextField(
                        controller: _documentIdController,
                        label: 'Document ID',
                      ),
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
                        TransactionDocumentStatusCard(
                          status: documentState.documentStatus,
                        ),
                    ],
                  ),

                  TransactionDocumentSection(
                    title: 'Get Related Documents',
                    children: [
                      TransactionDocumentDropdownField(
                        controller: _documentTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Document Type',
                        formatDocumentTypes: true,
                      ),
                      TransactionDocumentTextField(
                        controller: _documentIdController,
                        label: 'Document ID',
                      ),
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
                        TransactionDocumentRelatedDocumentsCard(
                          documents: documentState.relatedDocuments,
                        ),
                    ],
                  ),

                  TransactionDocumentSection(
                    title: 'Create Document Link',
                    children: [
                      TransactionDocumentDropdownField(
                        controller: _sourceTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Source Document Type',
                        formatDocumentTypes: true,
                      ),
                      TransactionDocumentTextField(
                        controller: _sourceIdController,
                        label: 'Source Document ID',
                      ),
                      TransactionDocumentDropdownField(
                        controller: _targetTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Target Document Type',
                        formatDocumentTypes: true,
                      ),
                      TransactionDocumentTextField(
                        controller: _targetIdController,
                        label: 'Target Document ID',
                      ),
                      TransactionDocumentDropdownField(
                        controller: _relationshipTypeController,
                        options: _standardRelationshipTypes,
                        hint: 'Select Relationship Type',
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final sourceType = _sourceTypeController.text.trim();
                          final sourceId = _sourceIdController.text.trim();
                          final targetType = _targetTypeController.text.trim();
                          final targetId = _targetIdController.text.trim();
                          final relationshipType = _relationshipTypeController
                              .text
                              .trim();

                          if (sourceType.isEmpty ||
                              sourceId.isEmpty ||
                              targetType.isEmpty ||
                              targetId.isEmpty ||
                              relationshipType.isEmpty) {
                            context.showError('All fields are required');
                            return;
                          }

                          try {
                            final success = await documentCubit
                                .createDocumentLink(
                                  sourceType,
                                  sourceId,
                                  targetType,
                                  targetId,
                                  relationshipType,
                                );
                            if (!mounted) return;

                            if (success) {
                              context.showSuccess(
                                'Document link created successfully',
                              );
                            } else {
                              context.showError(
                                'Failed to create document link',
                              );
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

                  TransactionDocumentSection(
                    title: 'Find Original Document for EPC',
                    children: [
                      TransactionDocumentTextField(
                        controller: _epcController,
                        label:
                            'EPC (e.g., https://id.gs1.org/01/…/21/…)',
                      ),
                      TransactionDocumentDropdownField(
                        controller: _documentTypeController,
                        options: _standardDocumentTypes,
                        hint: 'Select Document Type (optional)',
                        formatDocumentTypes: true,
                        includeAnyOption: true,
                      ),
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
                            final document = await documentCubit
                                .findOriginalDocumentForEPC(epc, type: type);
                            if (!mounted) return;

                            if (document != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Original Document'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Type: ${document['type'] ?? 'N/A'}',
                                      ),
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
}
