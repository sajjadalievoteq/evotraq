import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:traqtrace_app/features/epcis/providers/transformation_events_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/transformation_event_form_help.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gln_entry_field.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';
import 'package:uuid/uuid.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class TransformationEventFormScreen extends StatefulWidget {
  final TransformationEvent? event;
  
  final String? transformationEventId;

  const TransformationEventFormScreen({
    Key? key, 
    this.event,
    this.transformationEventId,
  }) : super(key: key);

  @override
  State<TransformationEventFormScreen> createState() => _TransformationEventFormScreenState();
}

class _TransformationEventFormScreenState extends State<TransformationEventFormScreen> with EventFormValidationMixin<TransformationEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _eventTime;
  String _eventTimeZoneOffset = '+00:00';
  Map<String, String> _bizData = {};
  
  String? _lastKnownGLNCode;
  
  bool _isLoading = false;
  bool _isEdit = false;
  bool _hasTriedToSubmit = false;
  Timer? _validationTimer;
  
  final _transformationIdController = TextEditingController();
  final _inputEpcsController = TextEditingController();
  final _outputEpcsController = TextEditingController();
  final _bizStepController = TextEditingController();
  final _dispositionController = TextEditingController();
  final _locationGLNController = TextEditingController();
  
  final _certificateNumberController = TextEditingController();
  final _certificationStandardController = TextEditingController();
  final _certificationAgencyController = TextEditingController();
  final _certificationTypeController = TextEditingController();
  
  final List<String> _standardBusinessSteps = [
    'transforming',
    'producing', 
    'assembling',
    'disassembling',
    'combining',
    'separating',
    'repackaging',
    'manufacturing',
    'processing',
    'blending',
    'mixing',
    'composing',
    'formulating',
    'distilling',
    'brewing',
    'processing',
    'blending',
    'mixing',
    'composing',
    'formulating',
    'distilling',
    'brewing'
  ];
  
  final List<String> _standardDispositions = [
    'active',
    'in_progress',
    'created',
    'encoded',
    'produced',
    'available',
    'consumed',
    'partially_consumed',
    'partially_destroyed',
    'transformed',
    'destroyed',
    'unusable',
    'expired',
    'in_transit',
    'reserved',
    'returned',
    'needs_replacement',
    'container_closed',
    'damaged',
    'disposed',
    'recalled'
  ];

  @override
  void initState() {
    super.initState();
    
    _eventTime = DateTime.now();
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    _eventTimeZoneOffset = "${offset.isNegative ? '-' : '+'}$hours:$minutes";
    
    _transformationIdController.addListener(_clearFieldErrors);
    _inputEpcsController.addListener(_clearFieldErrors);
    _outputEpcsController.addListener(_clearFieldErrors);
    _bizStepController.addListener(_clearFieldErrors);
    _dispositionController.addListener(_clearFieldErrors);
    _locationGLNController.addListener(_clearFieldErrors);
    
    _isEdit = widget.event != null || widget.transformationEventId != null;
    
    if (_isEdit && widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else if (_isEdit && widget.transformationEventId != null) {
      _loadEventData();
    }
  }
  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    
    try {
      final event = await context
          .read<TransformationEventsCubit>()
          .getTransformationEventById(widget.transformationEventId!);
      
      print('==== Event Data Received ====');
      print('Event ID: ${event.id}');
      print('Event Type: Transformation');
      print('Business Step: ${event.businessStep}');
      print('Disposition: ${event.disposition}');
      print('Business Location: ${event.businessLocation}');
      print('Biz Data: ${event.bizData}');
      print('===========================');
      
      _initializeWithEvent(event);
      
      if (event.bizData == null) {
        await _tryRestoreGLNFromBackend(event.eventId);
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        context.showError('Error loading event: ${error.toString()}');
      }
    }
  }
    void _initializeWithEvent(TransformationEvent event) {
    _eventTime = event.eventTime;
    _eventTimeZoneOffset = event.eventTimeZone;
    _transformationIdController.text = event.transformationID;
    _inputEpcsController.text = event.inputEPCList.join(', ');
    _outputEpcsController.text = event.outputEPCList.join(', ');
    
    if (event.businessStep != null && event.businessStep!.isNotEmpty) {
      if (event.businessStep!.contains(':')) {
        final parts = event.businessStep!.split(':');
        _bizStepController.text = parts.last;
      } else {
        _bizStepController.text = event.businessStep!;
      }
      
      print('Setting business step to: ${_bizStepController.text}');
    }
    
    if (event.disposition != null && event.disposition!.isNotEmpty) {
      if (event.disposition!.contains(':')) {
        final parts = event.disposition!.split(':');
        _dispositionController.text = parts.last;
      } else {
        _dispositionController.text = event.disposition!;
      }
      
      print('Setting disposition to: ${_dispositionController.text}');
    }
    String? glnCode;
    
    if (event.businessLocation != null) {
      if (event.businessLocation is Map && (event.businessLocation as Map).containsKey('glnCode')) {
        glnCode = (event.businessLocation as Map)['glnCode']?.toString();
      } else {
        try {
          final dynamic location = event.businessLocation;
          final dynamic locationGlnCode = location.glnCode;
          if (locationGlnCode != null) {
            glnCode = locationGlnCode.toString();
          }
        } catch (e) {
          print('Error accessing GLN code from business location: ${e.toString()}');
        }
      }
    }
    
    if (glnCode == null && event.bizData != null) {
      final possibleKeys = ['locationGLNCode', 'glnCode', 'businessLocationGLN', 'bizLocationGLN'];
      for (final key in possibleKeys) {
        if (event.bizData!.containsKey(key) && event.bizData![key] != null) {
          glnCode = event.bizData![key];
          print('Found GLN code in bizData with key $key: $glnCode');
          
          _lastKnownGLNCode = glnCode;
          
          break;
        }
      }
    }
    
    if (glnCode == null && _lastKnownGLNCode != null) {
      glnCode = _lastKnownGLNCode;
      print('Using cached GLN code: $glnCode (bizData was null in response)');
    }
    
    if (glnCode != null) {
      _locationGLNController.text = glnCode;
    } else {
      print('No GLN code found in event data');
    }
    
    _bizData = event.bizData != null ? Map.from(event.bizData!) : {};
    
    if (event.certificationInfo != null && event.certificationInfo!.isNotEmpty) {
      final firstCert = event.certificationInfo!.first;
      _certificateNumberController.text = firstCert.certificateId ?? '';
      _certificationStandardController.text = firstCert.certificationStandard ?? '';
      _certificationAgencyController.text = firstCert.certificationAgency ?? '';
      _certificationTypeController.text = firstCert.certificationType ?? '';
    }
  }
  
  void _clearFieldErrors() {
    if (_hasTriedToSubmit) {
      _validationTimer?.cancel();
      
      _validationTimer = Timer(const Duration(milliseconds: 500), () {
        if (_formKey.currentState != null && mounted) {
          _formKey.currentState!.validate();
        }
      });
    }
    
    context.read<ValidationCubit>().clearValidation();
  }
  
  @override
  void dispose() {
    _validationTimer?.cancel();
    
    _transformationIdController.removeListener(_clearFieldErrors);
    _inputEpcsController.removeListener(_clearFieldErrors);
    _outputEpcsController.removeListener(_clearFieldErrors);
    _bizStepController.removeListener(_clearFieldErrors);
    _dispositionController.removeListener(_clearFieldErrors);
    _locationGLNController.removeListener(_clearFieldErrors);
    
    _transformationIdController.dispose();
    _inputEpcsController.dispose();
    _outputEpcsController.dispose();
    _bizStepController.dispose();
    _dispositionController.dispose();
    _locationGLNController.dispose();
    _certificateNumberController.dispose();
    _certificationStandardController.dispose();
    _certificationAgencyController.dispose();
    _certificationTypeController.dispose();
    super.dispose();
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: TransformationEventFormHelp(),
      ),
    );
  }
  
  Future<void> _saveEvent() async {
    setState(() {
      _hasTriedToSubmit = true;
    });
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cubit = context.read<TransformationEventsCubit>();
      final validationCubit = context.read<ValidationCubit>();
      
      final inputEpcs = _inputEpcsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
          .toList();
          
      final outputEpcs = _outputEpcsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
          .toList();

      final Map<String, String> bizData = Map.from(_bizData);
      
      final String locationGLN = _locationGLNController.text.trim();
      if (locationGLN.isNotEmpty) {
        bizData['locationGLNCode'] = locationGLN;
        
        bizData['businessLocationGLN'] = locationGLN;
        bizData['bizLocationGLN'] = locationGLN;
      }
      
      String transformationId = _transformationIdController.text;
      if (!transformationId.startsWith('urn:') && 
          !transformationId.startsWith('http://') && 
          !transformationId.startsWith('https://')) {
        transformationId = 'urn:traqtrace:transformation:$transformationId';
      }
      
      String? bizStep = _bizStepController.text.isNotEmpty ? _bizStepController.text : null;
      String? disposition = _dispositionController.text.isNotEmpty ? _dispositionController.text : null;
      
      GLN? businessLocationGLN;
      GLN? readPointGLN;
      if (locationGLN.isNotEmpty) {
        businessLocationGLN = GLN.fromCode(locationGLN);
        readPointGLN = GLN.fromCode(locationGLN);
      }
      
      List<CertificationInfo>? certificationInfo;
      if (_certificateNumberController.text.isNotEmpty ||
          _certificationStandardController.text.isNotEmpty ||
          _certificationAgencyController.text.isNotEmpty ||
          _certificationTypeController.text.isNotEmpty) {
        certificationInfo = [
          CertificationInfo(
            certificateId: _certificateNumberController.text.isNotEmpty ? _certificateNumberController.text : null,
            certificationStandard: _certificationStandardController.text.isNotEmpty ? _certificationStandardController.text : null,
            certificationAgency: _certificationAgencyController.text.isNotEmpty ? _certificationAgencyController.text : null,
            certificationType: _certificationTypeController.text.isNotEmpty ? _certificationTypeController.text : null,
          ),
        ];
      }
      
      final event = TransformationEvent(
        id: _isEdit ? widget.event?.id : null,
        eventId: _isEdit ? widget.event?.eventId ?? '' : const Uuid().v4(),
        eventTime: _eventTime,
        recordTime: DateTime.now(),
        eventTimeZoneOffset: _eventTimeZoneOffset,
        bizStep: bizStep,
        disposition: disposition,
        readPoint: readPointGLN,
        bizLocation: businessLocationGLN,
        bizData: bizData,
        transformationID: transformationId,
        inputEPCList: inputEpcs,
        outputEPCList: outputEpcs,
        certificationInfo: certificationInfo,
      );
      
      final isValid = await validationCubit.validateTransformationEvent(event);
      
      if (!isValid && mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      if (_isEdit && widget.event != null) {
        await cubit.updateTransformationEvent(event);
      } else {
        await cubit.createTransformationEvent(event);
      }
      
      if (mounted) {
        context.showSuccess(
          'Transformation event ${_isEdit ? "updated" : "created"} successfully',
        );
        Navigator.pop(context, true);
      }
      
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        context.showError('Error: ${error.toString()}');
      }
    }
  }
  
  void _generateSampleInputEPC() {
    final sgtin = GS1Generator.generateRandomSGTIN('0614141', '107346');
    setState(() {
      final existingEpcs = _inputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _inputEpcsController.text = sgtin;
      } else {
        _inputEpcsController.text = '$existingEpcs, $sgtin';
      }
    });
  }

  void _generateBatchInputEPCs() {
    final batch = GS1Generator.generateBatchSGTINs('0614141', '107346', 3);
    setState(() {
      final existingEpcs = _inputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _inputEpcsController.text = batch.join(', ');
      } else {
        _inputEpcsController.text = '$existingEpcs, ${batch.join(', ')}';
      }
    });
  }

  void _generateSampleOutputEPC() {
    final sgtin = GS1Generator.generateRandomSGTIN('0614141', '207346');
    setState(() {
      final existingEpcs = _outputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _outputEpcsController.text = sgtin;
      } else {
        _outputEpcsController.text = '$existingEpcs, $sgtin';
      }
    });
  }

  void _generateBatchOutputEPCs() {
    final batch = GS1Generator.generateBatchSGTINs('0614141', '207346', 3);
    setState(() {
      final existingEpcs = _outputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _outputEpcsController.text = batch.join(', ');
      } else {
        _outputEpcsController.text = '$existingEpcs, ${batch.join(', ')}';
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transformation Event' : 'New Transformation Event'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: _isLoading && _isEdit ? 
        const Center(child: AppLoadingIndicator()) : 
        _buildMainContent(),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
                child: _isLoading ? 
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) : 
                  Text(_isEdit ? 'UPDATE' : 'SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainContent() {
    return BlocBuilder<ValidationCubit, ValidationState>(
      builder: (context, validationState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              if (validationState.error != null)
                _buildErrorMessage(validationState.error!),
              if (validationState.lastValidationResult != null &&
                  !(validationState.lastValidationResult!['valid'] as bool? ?? true))
                ValidationErrorWidget(
                  validationErrors: context.read<ValidationCubit>().validationErrors,
                  onDismiss: () => context.read<ValidationCubit>().clearValidation(),
                ),
              _buildForm(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(AppAssets.iconTransform, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Transformation Event',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Record how input items are transformed into output items according to GS1 EPCIS 2.0 standards.',
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _showHelpDialog,
              child: const Text('Need Help?'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              TraqIcon(AppAssets.iconAlert, color: Colors.red),
              const SizedBox(width: 16),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: _hasTriedToSubmit 
        ? AutovalidateMode.onUserInteraction 
        : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Information'),
          _buildTextField(
            controller: _transformationIdController, 
            label: 'Transformation ID *',
            helperText: 'Simple ID (transform_12345) or full URI (urn:epcglobal:cbv:bizstep:batch_123)',
            fieldName: 'transformationId',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Transformation ID is required';
              }
              
              if (value.contains(' ')) {
                return 'Transformation ID should not contain spaces';
              }
              
              return null;
            },
          ),
          const SizedBox(height: 24),
            _buildSectionHeader('Transformation Details'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildEpcTextField(
                  controller: _inputEpcsController, 
                  label: 'Input EPCs *',
                  helperText: 'Comma-separated list of input EPCs',
                  fieldName: 'inputEpcs',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'At least one input EPC is required';
                    }
                    
                    final epcList = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    for (final epc in epcList) {
                      if (!epc.startsWith('urn:epc:id:') && !RegExp(r'\(\d+\)').hasMatch(epc)) {
                        return 'Invalid EPC format: $epc';
                      }
                    }
                    
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _generateSampleInputEPC(),
                    child: const Text('Sample EPC'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _generateBatchInputEPCs(),
                    child: const Text('Sample Batch'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildEpcTextField(
                  controller: _outputEpcsController, 
                  label: 'Output EPCs *',
                  helperText: 'Comma-separated list of output EPCs',
                  fieldName: 'outputEpcs',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'At least one output EPC is required';
                    }
                    
                    final epcList = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    for (final epc in epcList) {
                      if (!epc.startsWith('urn:epc:id:') && !RegExp(r'\(\d+\)').hasMatch(epc)) {
                        return 'Invalid EPC format: $epc';
                      }
                    }
                    
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _generateSampleOutputEPC(),
                    child: const Text('Sample EPC'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _generateBatchOutputEPCs(),
                    child: const Text('Sample Batch'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Business Context'),
          _buildDropdownField(
            controller: _bizStepController,
            label: 'Business Step',
            options: _standardBusinessSteps,
            helperText: 'The type of business process step',
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                setState(() {
                  _bizStepController.text = value;
                  _dispositionController.text = '';
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            controller: _dispositionController,
            label: 'Disposition',
            options: _getValidDispositionsForCurrentBusinessStep(),
            helperText: 'The business state of the objects',
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                setState(() {
                  _dispositionController.text = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          GlnEntryField(
            controller: _locationGLNController,
            label: 'Business Location GLN',
            helperText:
                'GLN code where the transformation occurred (must exist in master data)',
            fieldName: 'locationGLN',
            optional: true,
            validator: (value) =>
                EpcisGlnValidators.validateLocationGln(value, required: false),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Certification Information (EPCIS 2.0)'),
          _buildTextField(
            controller: _certificateNumberController,
            label: 'Certificate Number',
            helperText: 'Unique identifier for the certification',
            fieldName: 'certificateNumber',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _certificationStandardController,
            label: 'Certification Standard',
            helperText: 'E.g., ISO 14001, HACCP, Organic, Fair Trade',
            fieldName: 'certificationStandard',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _certificationAgencyController,
            label: 'Certification Agency',
            helperText: 'Name of the issuing organization',
            fieldName: 'certificationAgency',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _certificationTypeController,
            label: 'Certification Type',
            helperText: 'Type or category of certification',
            fieldName: 'certificationType',
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Event Time'),
          _buildDateTimePicker(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    String? Function(String?)? validator,
    String? fieldName,
  }) {
    return ValidatedTextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (validator != null) {
          final error = validator(value);
          if (fieldName != null) {
            setFieldError(fieldName, error);
          }
          return error;
        }
        return null;
      },
    );
  }
    Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    String? helperText,
    void Function(String?)? onChanged,
  }) {
    String? selectedValue = controller.text.isEmpty ? null : controller.text;
    
    if (selectedValue != null && !options.contains(selectedValue)) {
      selectedValue = null;
    }
    
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(_formatForDisplay(value)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }
  
  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: TraqIcon(AppAssets.iconClock),
            label: Text(DateFormat('yyyy-MM-dd').format(_eventTime)),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _eventTime,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              
              if (pickedDate != null) {
                setState(() {
                  _eventTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    _eventTime.hour,
                    _eventTime.minute,
                  );
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: TraqIcon(AppAssets.iconClock),
            label: Text(DateFormat('HH:mm').format(_eventTime)),
            onPressed: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_eventTime),
              );
              
              if (pickedTime != null) {
                setState(() {
                  _eventTime = DateTime(
                    _eventTime.year,
                    _eventTime.month,
                    _eventTime.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }
  String _formatForDisplay(String value) {
    return value.split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  List<String> _getValidDispositionsForCurrentBusinessStep() {
    if (_bizStepController.text.isEmpty) {
      return _standardDispositions;
    }

    Map<String, List<String>> businessStepToDispositions = {
      'transforming': ['in_progress', 'transformed', 'active'],
      'producing': ['produced', 'active', 'in_progress', 'created'],
      'assembling': ['active', 'in_progress', 'created', 'produced'],
      'disassembling': ['active', 'in_progress', 'created', 'partially_destroyed'],
      'combining': ['active', 'in_progress', 'transformed'],
      'separating': ['active', 'in_progress', 'partially_consumed', 'created'],
      'repackaging': ['active', 'in_progress', 'created', 'produced', 'encoded'],
      'manufacturing': ['active', 'in_progress', 'created', 'produced'],
      'processing': ['active', 'in_progress', 'transformed'],
      'blending': ['active', 'in_progress', 'transformed'],
      'mixing': ['active', 'in_progress', 'transformed'],
      'composing': ['active', 'in_progress', 'transformed'],
      'formulating': ['active', 'in_progress', 'produced'],
      'distilling': ['active', 'in_progress', 'produced'],
      'brewing': ['active', 'in_progress', 'produced'],
    };
    
    String currentBusinessStep = _bizStepController.text;
    if (businessStepToDispositions.containsKey(currentBusinessStep)) {
      return businessStepToDispositions[currentBusinessStep]!;
    } else {
      return ['active', 'in_progress', 'created', 'transformed'];
    }
  }
  
  Future<void> _tryRestoreGLNFromBackend(String eventId) async {
    try {
      print('Trying to restore GLN code for event ID: $eventId');
      
    } catch (e) {
      print('Failed to restore GLN from backend: ${e.toString()}');
    }
  }
  
  Widget _buildEpcTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    String? fieldName,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpcEntryField(
          controller: controller,
          fieldName: fieldName ?? 'epc',
          label: label,
          helperText: helperText,
          required: true,
          validator: (value) {
            if (validator != null) {
              final error = validator(value);
              if (fieldName != null) {
                setFieldError(fieldName, error);
              }
              return error;
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text('Formats accepted:\n'
          '• URI: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber\n'
          '• GS1: (01)05415062325810(21)70005188444899',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
