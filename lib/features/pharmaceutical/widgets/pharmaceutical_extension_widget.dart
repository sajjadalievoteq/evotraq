import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/services/pharmaceutical_service.dart';
import '../models/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import '../../../core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

/// Widget that displays/edits pharmaceutical extension data for a GTIN
/// Can be embedded in GTIN detail screens or used standalone
class PharmaceuticalExtensionWidget extends StatefulWidget {
  final int? gtinId;
  final String? gtinCode;
  final bool isEditing;
  final Function(GTINPharmaceuticalExtension?)? onSaved;
  final GTINPharmaceuticalExtension? initialExtension;

  const PharmaceuticalExtensionWidget({
    Key? key,
    this.gtinId,
    this.gtinCode,
    this.isEditing = false,
    this.onSaved,
    this.initialExtension,
  }) : super(key: key);

  @override
  State<PharmaceuticalExtensionWidget> createState() =>
      PharmaceuticalExtensionWidgetState();
}

/// State class for PharmaceuticalExtensionWidget - made public to allow GlobalKey access
class PharmaceuticalExtensionWidgetState
    extends State<PharmaceuticalExtensionWidget> {
  GTINPharmaceuticalExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  // Form controllers - Drug Identification
  final _ndcNumberController = TextEditingController();
  final _dinNumberController = TextEditingController();
  final _eanPharmaCodeController = TextEditingController();

  // Drug Classification
  final _drugClassController = TextEditingController();
  final _therapeuticClassController = TextEditingController();
  final _pharmacologicalClassController = TextEditingController();
  final _atcCodeController = TextEditingController();

  // Controlled Substance
  bool _isControlledSubstance = false;
  DeaSchedule _deaSchedule = DeaSchedule.none;
  final _controlClassController = TextEditingController();

  // Dosage Information
  final _dosageFormController = TextEditingController();
  final _strengthController = TextEditingController();
  final _strengthUnitController = TextEditingController();
  final _routeOfAdministrationController = TextEditingController();

  // Storage Requirements
  final _storageConditionsController = TextEditingController();
  final _minStorageTempController = TextEditingController();
  final _maxStorageTempController = TextEditingController();
  bool _requiresRefrigeration = false;
  bool _requiresFreezing = false;
  bool _lightSensitive = false;
  bool _humiditySensitive = false;

  // Prescription Requirements
  bool _requiresPrescription = true;
  final _prescriptionTypeController = TextEditingController();

  // Regulatory
  DateTime? _fdaApprovalDate;
  final _fdaApplicationNumberController = TextEditingController();
  DateTime? _emaApprovalDate;
  final _emaProcedureNumberController = TextEditingController();

  // Warnings
  bool _blackBoxWarning = false;
  final _blackBoxWarningTextController = TextEditingController();
  final _contraindicationsController = TextEditingController();
  final _drugInteractionsController = TextEditingController();
  PregnancyCategory _pregnancyCategory = PregnancyCategory.notClassified;

  final List<String> _dosageFormOptions = [
    'Tablet',
    'Capsule',
    'Injection',
    'Solution',
    'Suspension',
    'Syrup',
    'Cream',
    'Ointment',
    'Gel',
    'Patch',
    'Suppository',
    'Inhaler',
    'Spray',
    'Drops',
    'Powder',
    'Other',
  ];

  final List<String> _routeOptions = [
    'Oral',
    'Intravenous (IV)',
    'Intramuscular (IM)',
    'Subcutaneous (SC)',
    'Topical',
    'Transdermal',
    'Inhalation',
    'Rectal',
    'Vaginal',
    'Ophthalmic',
    'Otic',
    'Nasal',
    'Sublingual',
    'Buccal',
    'Intradermal',
    'Other',
  ];

  // ---------------------------------------------------------------------------
  // Documentation-aligned pharma extension fields (UI-only for now)
  // ---------------------------------------------------------------------------
  final _regulatedProductNameController = TextEditingController();
  final _dosageFormTypeCodeController = TextEditingController();
  final _routeOfAdministrationCodeController = TextEditingController();

  final _mahGlnController = TextEditingController();
  final _mahNameController = TextEditingController();
  final _mahCountryController = TextEditingController();

  final _maNumberController = TextEditingController();
  DateTime? _maValidFrom;
  DateTime? _maValidTo;
  final _maValidFromDisplay = TextEditingController();
  final _maValidToDisplay = TextEditingController();

  final _regulatoryStatusController = TextEditingController();

  String _prescriptionStatus = 'RX';
  bool _controlledSubstance = false;
  final _controlledSubstanceScheduleController = TextEditingController();
  bool _additionalMonitoring = false;

  final _shelfLifeMonthsController = TextEditingController();
  final _shelfLifeAfterOpenDaysController = TextEditingController();

  final _countryOfManufactureController = TextEditingController();
  final _packSizeDescriptionController = TextEditingController();

  static final _docDateFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.initialExtension != null) {
      _populateFormFromExtension(widget.initialExtension!);
      _extension = widget.initialExtension;
      _hasExtension = true;
      _isLoading = false;
    } else {
      _loadExtension();
    }
  }

  @override
  void dispose() {
    _ndcNumberController.dispose();
    _dinNumberController.dispose();
    _eanPharmaCodeController.dispose();
    _drugClassController.dispose();
    _therapeuticClassController.dispose();
    _pharmacologicalClassController.dispose();
    _atcCodeController.dispose();
    _controlClassController.dispose();
    _dosageFormController.dispose();
    _strengthController.dispose();
    _strengthUnitController.dispose();
    _routeOfAdministrationController.dispose();
    _storageConditionsController.dispose();
    _minStorageTempController.dispose();
    _maxStorageTempController.dispose();
    _prescriptionTypeController.dispose();
    _fdaApplicationNumberController.dispose();
    _emaProcedureNumberController.dispose();
    _blackBoxWarningTextController.dispose();
    _contraindicationsController.dispose();
    _drugInteractionsController.dispose();

    _regulatedProductNameController.dispose();
    _dosageFormTypeCodeController.dispose();
    _routeOfAdministrationCodeController.dispose();
    _mahGlnController.dispose();
    _mahNameController.dispose();
    _mahCountryController.dispose();
    _maNumberController.dispose();
    _maValidFromDisplay.dispose();
    _maValidToDisplay.dispose();
    _regulatoryStatusController.dispose();
    _controlledSubstanceScheduleController.dispose();
    _shelfLifeMonthsController.dispose();
    _shelfLifeAfterOpenDaysController.dispose();
    _countryOfManufactureController.dispose();
    _packSizeDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDocDate({
    required DateTime? current,
    required ValueChanged<DateTime?> setValue,
    required TextEditingController display,
  }) async {
    final initial = current ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        setValue(picked);
        display.text = _docDateFmt.format(picked);
      });
    }
  }

  Future<void> _loadExtension() async {
    // Skip loading if no valid GTIN code or ID is provided (e.g., when creating a new GTIN)
    final hasValidGtinCode = widget.gtinCode != null && widget.gtinCode!.isNotEmpty;
    final hasValidGtinId = widget.gtinId != null;
    
    if (!hasValidGtinCode && !hasValidGtinId) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final service = getIt<PharmaceuticalService>();

      GTINPharmaceuticalExtension? ext;
      if (hasValidGtinCode) {
        ext = await service.getExtensionByGtinCode(widget.gtinCode!);
      } else if (widget.gtinId != null) {
        ext = await service.getExtensionByGtinId(widget.gtinId!);
      }

      if (!mounted) return;

      if (ext != null) {
        _populateFormFromExtension(ext);
        setState(() {
          _extension = ext;
          _hasExtension = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pharmaceutical extension: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFormFromExtension(GTINPharmaceuticalExtension ext) {
    _ndcNumberController.text = ext.ndcNumber ?? '';
    _dinNumberController.text = ext.dinNumber ?? '';
    _eanPharmaCodeController.text = ext.eanPharmaCode ?? '';
    _drugClassController.text = ext.drugClass ?? '';
    _therapeuticClassController.text = ext.therapeuticClass ?? '';
    _pharmacologicalClassController.text = ext.pharmacologicalClass ?? '';
    _atcCodeController.text = ext.atcCode ?? '';
    _isControlledSubstance = ext.isControlledSubstance;
    _deaSchedule = ext.deaSchedule;
    _controlClassController.text = ext.controlClass ?? '';
    _dosageFormController.text = ext.dosageForm ?? '';
    _strengthController.text = ext.strength ?? '';
    _strengthUnitController.text = ext.strengthUnit ?? '';
    _routeOfAdministrationController.text = ext.routeOfAdministration ?? '';
    _storageConditionsController.text = ext.storageConditions ?? '';
    _minStorageTempController.text = ext.minStorageTempCelsius?.toString() ?? '';
    _maxStorageTempController.text = ext.maxStorageTempCelsius?.toString() ?? '';
    _requiresRefrigeration = ext.requiresRefrigeration;
    _requiresFreezing = ext.requiresFreezing;
    _lightSensitive = ext.lightSensitive;
    _humiditySensitive = ext.humiditySensitive;
    _requiresPrescription = ext.requiresPrescription;
    _prescriptionTypeController.text = ext.prescriptionType ?? '';
    _fdaApprovalDate = ext.fdaApprovalDate;
    _fdaApplicationNumberController.text = ext.fdaApplicationNumber ?? '';
    _emaApprovalDate = ext.emaApprovalDate;
    _emaProcedureNumberController.text = ext.emaProcedureNumber ?? '';
    _blackBoxWarning = ext.blackBoxWarning;
    _blackBoxWarningTextController.text = ext.blackBoxWarningText ?? '';
    _contraindicationsController.text = ext.contraindications ?? '';
    _drugInteractionsController.text = ext.drugInteractions ?? '';
    _pregnancyCategory = ext.pregnancyCategory;
  }

  /// Check if user has entered any pharmaceutical data
  bool get hasData => 
      _drugClassController.text.isNotEmpty ||
      _dosageFormController.text.isNotEmpty ||
      _ndcNumberController.text.isNotEmpty ||
      _strengthController.text.isNotEmpty;

  /// Validate the pharmaceutical extension form
  /// Returns null if valid, error message if invalid
  String? validate() {
    // No required fields for pharmaceutical extension
    // All fields are optional
    return null;
  }

  /// Build the extension object from form data
  /// Returns null if no data has been entered
  GTINPharmaceuticalExtension? buildExtension({int? gtinId, String? gtinCode}) {
    if (!hasData) return null;
    
    return GTINPharmaceuticalExtension(
      id: _extension?.id,
      gtinId: gtinId ?? widget.gtinId ?? 0,
      gtinCode: gtinCode ?? widget.gtinCode,
      ndcNumber: _ndcNumberController.text.isEmpty ? null : _ndcNumberController.text,
      dinNumber: _dinNumberController.text.isEmpty ? null : _dinNumberController.text,
      eanPharmaCode: _eanPharmaCodeController.text.isEmpty ? null : _eanPharmaCodeController.text,
      drugClass: _drugClassController.text.isEmpty ? null : _drugClassController.text,
      therapeuticClass: _therapeuticClassController.text.isEmpty ? null : _therapeuticClassController.text,
      pharmacologicalClass: _pharmacologicalClassController.text.isEmpty ? null : _pharmacologicalClassController.text,
      atcCode: _atcCodeController.text.isEmpty ? null : _atcCodeController.text,
      isControlledSubstance: _isControlledSubstance,
      deaSchedule: _deaSchedule,
      controlClass: _controlClassController.text.isEmpty ? null : _controlClassController.text,
      dosageForm: _dosageFormController.text.isEmpty ? null : _dosageFormController.text,
      strength: _strengthController.text.isEmpty ? null : _strengthController.text,
      strengthUnit: _strengthUnitController.text.isEmpty ? null : _strengthUnitController.text,
      routeOfAdministration: _routeOfAdministrationController.text.isEmpty ? null : _routeOfAdministrationController.text,
      storageConditions: _storageConditionsController.text.isEmpty ? null : _storageConditionsController.text,
      minStorageTempCelsius: double.tryParse(_minStorageTempController.text),
      maxStorageTempCelsius: double.tryParse(_maxStorageTempController.text),
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      requiresPrescription: _requiresPrescription,
      prescriptionType: _prescriptionTypeController.text.isEmpty ? null : _prescriptionTypeController.text,
      fdaApprovalDate: _fdaApprovalDate,
      fdaApplicationNumber: _fdaApplicationNumberController.text.isEmpty ? null : _fdaApplicationNumberController.text,
      emaApprovalDate: _emaApprovalDate,
      emaProcedureNumber: _emaProcedureNumberController.text.isEmpty ? null : _emaProcedureNumberController.text,
      blackBoxWarning: _blackBoxWarning,
      blackBoxWarningText: _blackBoxWarningTextController.text.isEmpty ? null : _blackBoxWarningTextController.text,
      contraindications: _contraindicationsController.text.isEmpty ? null : _contraindicationsController.text,
      drugInteractions: _drugInteractionsController.text.isEmpty ? null : _drugInteractionsController.text,
      pregnancyCategory: _pregnancyCategory,
    );
  }

  GTINPharmaceuticalExtension _buildExtensionFromForm() {
    return GTINPharmaceuticalExtension(
      id: _extension?.id,
      gtinId: widget.gtinId ?? 0,
      gtinCode: widget.gtinCode,
      ndcNumber: _ndcNumberController.text.isEmpty ? null : _ndcNumberController.text,
      dinNumber: _dinNumberController.text.isEmpty ? null : _dinNumberController.text,
      eanPharmaCode: _eanPharmaCodeController.text.isEmpty ? null : _eanPharmaCodeController.text,
      drugClass: _drugClassController.text.isEmpty ? null : _drugClassController.text,
      therapeuticClass: _therapeuticClassController.text.isEmpty ? null : _therapeuticClassController.text,
      pharmacologicalClass: _pharmacologicalClassController.text.isEmpty ? null : _pharmacologicalClassController.text,
      atcCode: _atcCodeController.text.isEmpty ? null : _atcCodeController.text,
      isControlledSubstance: _isControlledSubstance,
      deaSchedule: _deaSchedule,
      controlClass: _controlClassController.text.isEmpty ? null : _controlClassController.text,
      dosageForm: _dosageFormController.text.isEmpty ? null : _dosageFormController.text,
      strength: _strengthController.text.isEmpty ? null : _strengthController.text,
      strengthUnit: _strengthUnitController.text.isEmpty ? null : _strengthUnitController.text,
      routeOfAdministration: _routeOfAdministrationController.text.isEmpty ? null : _routeOfAdministrationController.text,
      storageConditions: _storageConditionsController.text.isEmpty ? null : _storageConditionsController.text,
      minStorageTempCelsius: double.tryParse(_minStorageTempController.text),
      maxStorageTempCelsius: double.tryParse(_maxStorageTempController.text),
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      requiresPrescription: _requiresPrescription,
      prescriptionType: _prescriptionTypeController.text.isEmpty ? null : _prescriptionTypeController.text,
      fdaApprovalDate: _fdaApprovalDate,
      fdaApplicationNumber: _fdaApplicationNumberController.text.isEmpty ? null : _fdaApplicationNumberController.text,
      emaApprovalDate: _emaApprovalDate,
      emaProcedureNumber: _emaProcedureNumberController.text.isEmpty ? null : _emaProcedureNumberController.text,
      blackBoxWarning: _blackBoxWarning,
      blackBoxWarningText: _blackBoxWarningTextController.text.isEmpty ? null : _blackBoxWarningTextController.text,
      contraindications: _contraindicationsController.text.isEmpty ? null : _contraindicationsController.text,
      drugInteractions: _drugInteractionsController.text.isEmpty ? null : _drugInteractionsController.text,
      pregnancyCategory: _pregnancyCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show if in pharmaceutical mode
    // Use listen: false to avoid rebuilding when provider changes and to prevent
    // "Looking up a deactivated widget's ancestor" errors during navigation
    // Wrap in try-catch to handle case when widget is deactivated during mode change
    bool isPharmaceuticalMode = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      isPharmaceuticalMode = settings.isPharmaceuticalMode;
    } catch (e) {
      // Widget is deactivated, return empty
      return const SizedBox.shrink();
    }
    
    if (!isPharmaceuticalMode) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        collapsedBackgroundColor: const Color(0xFF121F17),
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        // Default expanded [shape] uses [ThemeData.dividerColor] top/bottom — removes that line.
        shape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        leading: Icon(
          Icons.medical_services,
          color: _hasExtension ? const Color(0xFF121F17) : Colors.grey,
        ),
        title: Text(
          'Pharmaceutical Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _hasExtension ? const Color(0xFF121F17) : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        //subtitle: _hasExtension
        //    ? Text('${_drugClassController.text} - ${_dosageFormController.text}')
        //    : const Text('No pharmaceutical extension'),
        initiallyExpanded: _hasExtension,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drug Identification Section
                _buildSectionHeader('Drug Identification'),
                _buildTextField(_ndcNumberController, 'NDC Number',
                    helperText: 'National Drug Code (US)', maxLength: 20),
                _buildTextField(_dinNumberController, 'DIN Number',
                    helperText: 'Drug Identification Number (Canada)', maxLength: 20),
                _buildTextField(_eanPharmaCodeController, 'EAN Pharma Code',
                    helperText: 'European Pharmaceutical Code', maxLength: 20),
                const SizedBox(height: 16),

                // Drug Classification Section
                _buildSectionHeader('Drug Classification'),
                _buildTextField(_drugClassController, 'Drug Class',
                    helperText: 'e.g., Antibiotic, Analgesic', maxLength: 100),
                _buildTextField(_therapeuticClassController, 'Therapeutic Class', maxLength: 100),
                _buildTextField(_pharmacologicalClassController, 'Pharmacological Class', maxLength: 100),
                _buildTextField(_atcCodeController, 'ATC Code',
                    helperText: 'Anatomical Therapeutic Chemical code', maxLength: 10),
                const SizedBox(height: 16),

                // Controlled Substance Section
                _buildSectionHeader('Controlled Substance'),
                SwitchListTile(
                  title: const Text('Is Controlled Substance'),
                  value: _isControlledSubstance,
                  onChanged: widget.isEditing
                      ? (value) => setState(() {
                            _isControlledSubstance = value;
                            if (!value) {
                              _deaSchedule = DeaSchedule.none;
                            }
                          })
                      : null,
                ),
                if (_isControlledSubstance)
                  DropdownButtonFormField<DeaSchedule>(
                    value: _deaSchedule,
                    decoration: const InputDecoration(
                      labelText: 'DEA Schedule',
                      border: OutlineInputBorder(),
                    ),
                    items: DeaSchedule.values
                        .map((schedule) => DropdownMenuItem(
                              value: schedule,
                              child: Text(schedule.displayName),
                            ))
                        .toList(),
                    onChanged: widget.isEditing
                        ? (value) => setState(() {
                              _deaSchedule = value ?? DeaSchedule.none;
                            })
                        : null,
                  ),
                const SizedBox(height: 16),

                // Dosage Information Section
                _buildSectionHeader('Dosage Information'),
                DropdownButtonFormField<String>(
                  value: _dosageFormController.text.isEmpty
                      ? null
                      : _dosageFormOptions.contains(_dosageFormController.text)
                          ? _dosageFormController.text
                          : null,
                  decoration: const InputDecoration(
                    labelText: 'Dosage Form',
                    border: OutlineInputBorder(),
                  ),
                  items: _dosageFormOptions
                      .map((form) => DropdownMenuItem(
                            value: form,
                            child: Text(form),
                          ))
                      .toList(),
                  onChanged: widget.isEditing
                      ? (value) => setState(() {
                            _dosageFormController.text = value ?? '';
                          })
                      : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(_strengthController, 'Strength',
                          helperText: 'e.g., 500', maxLength: 100),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(_strengthUnitController, 'Unit',
                          helperText: 'e.g., mg', maxLength: 20),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _routeOfAdministrationController.text.isEmpty
                      ? null
                      : _routeOptions.contains(_routeOfAdministrationController.text)
                          ? _routeOfAdministrationController.text
                          : null,
                  decoration: const InputDecoration(
                    labelText: 'Route of Administration',
                    border: OutlineInputBorder(),
                  ),
                  items: _routeOptions
                      .map((route) => DropdownMenuItem(
                            value: route,
                            child: Text(route),
                          ))
                      .toList(),
                  onChanged: widget.isEditing
                      ? (value) => setState(() {
                            _routeOfAdministrationController.text = value ?? '';
                          })
                      : null,
                ),
                const SizedBox(height: 16),

                // Storage Requirements Section
                _buildSectionHeader('Storage Requirements'),
                _buildTextField(_storageConditionsController, 'Storage Conditions',
                    helperText: 'Detailed storage instructions', maxLines: 2, maxLength: 500),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_minStorageTempController, 'Min Temp (°C)', maxLength: 10),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(_maxStorageTempController, 'Max Temp (°C)', maxLength: 10),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildCheckbox('Refrigeration', _requiresRefrigeration,
                        (v) => setState(() => _requiresRefrigeration = v ?? false)),
                    _buildCheckbox('Freezing', _requiresFreezing,
                        (v) => setState(() => _requiresFreezing = v ?? false)),
                    _buildCheckbox('Light Sensitive', _lightSensitive,
                        (v) => setState(() => _lightSensitive = v ?? false)),
                    _buildCheckbox('Humidity Sensitive', _humiditySensitive,
                        (v) => setState(() => _humiditySensitive = v ?? false)),
                  ],
                ),
                const SizedBox(height: 16),

                // Prescription Requirements Section
                _buildSectionHeader('Prescription Requirements'),
                SwitchListTile(
                  title: const Text('Requires Prescription'),
                  value: _requiresPrescription,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _requiresPrescription = value)
                      : null,
                ),
                if (_requiresPrescription)
                  _buildTextField(_prescriptionTypeController, 'Prescription Type',
                      helperText: 'e.g., Standard, Special, Controlled', maxLength: 50),
                const SizedBox(height: 16),

                // Warnings Section
                _buildSectionHeader('Warnings & Precautions'),
                SwitchListTile(
                  title: const Text('Black Box Warning'),
                  subtitle: const Text('FDA\'s most serious warning'),
                  value: _blackBoxWarning,
                  activeColor: Colors.red,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _blackBoxWarning = value)
                      : null,
                ),
                if (_blackBoxWarning)
                  _buildTextField(
                    _blackBoxWarningTextController,
                    'Black Box Warning Text',
                    maxLines: 3,
                    maxLength: 1000,
                  ),
                DropdownButtonFormField<PregnancyCategory>(
                  value: _pregnancyCategory,
                  decoration: const InputDecoration(
                    labelText: 'Pregnancy Category',
                    border: OutlineInputBorder(),
                  ),
                  items: PregnancyCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.displayName),
                          ))
                      .toList(),
                  onChanged: widget.isEditing
                      ? (value) => setState(() {
                            _pregnancyCategory =
                                value ?? PregnancyCategory.notClassified;
                          })
                      : null,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  _contraindicationsController,
                  'Contraindications',
                  maxLines: 2,
                  maxLength: 1000,
                ),
                _buildTextField(
                  _drugInteractionsController,
                  'Drug Interactions',
                  maxLines: 2,
                  maxLength: 1000,
                ),
                const SizedBox(height: 24),

                // -------------------------------------------------------------------
                // Pharma extension fields from documentation (UI-only)
                // -------------------------------------------------------------------
                _buildSectionHeader('Pharma Extension Fields (Documentation)'),
                Text(
                  'UI-only for now (not sent to the server). Labels and validations match the GTIN technical specification.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  _regulatedProductNameController,
                  'Regulated Product Name (Generic / INN) *',
                  maxLength: 200,
                  validator: PharmaFieldValidators.validateRegulatedProductName,
                ),
                _buildTextField(
                  _dosageFormTypeCodeController,
                  'Dosage Form Type Code *',
                  helperText: 'EDQM Standard Terms code (up to 30 chars)',
                  maxLength: 30,
                  validator: PharmaFieldValidators.validateDosageFormTypeCode,
                ),
                _buildTextField(
                  _routeOfAdministrationCodeController,
                  'Route of Administration Code *',
                  helperText: 'EDQM Standard Terms code (up to 30 chars)',
                  maxLength: 30,
                  validator: PharmaFieldValidators.validateRouteOfAdministrationCode,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  _mahGlnController,
                  'Marketing Authorization Holder (MAH) GLN *',
                  helperText: '13 digits; Mod-10 check digit',
                  maxLength: 13,
                  keyboardType: TextInputType.number,
                  validator: PharmaFieldValidators.validateMahGln,
                ),
                _buildTextField(
                  _mahNameController,
                  'MAH Name *',
                  maxLength: 200,
                  validator: PharmaFieldValidators.validateMahName,
                ),
                GtinCountryCodePickerField(
                  controller: _mahCountryController,
                  labelText: 'MAH Country *',
                  helperText: 'ISO 3166-1 numeric (3 digits)',
                  enabled: widget.isEditing,
                  validator: PharmaFieldValidators.validateMahCountry,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  _maNumberController,
                  'Marketing Authorization Number',
                  maxLength: 50,
                  validator: PharmaFieldValidators.validateMaNumber,
                ),
                GestureDetector(
                  onTap: widget.isEditing
                      ? () => _pickDocDate(
                            current: _maValidFrom,
                            setValue: (v) => _maValidFrom = v,
                            display: _maValidFromDisplay,
                          )
                      : null,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _maValidFromDisplay,
                      decoration: const InputDecoration(
                        labelText: 'Marketing Authorization Validity From Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: widget.isEditing
                      ? () => _pickDocDate(
                            current: _maValidTo,
                            setValue: (v) => _maValidTo = v,
                            display: _maValidToDisplay,
                          )
                      : null,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _maValidToDisplay,
                      decoration: const InputDecoration(
                        labelText: 'Marketing Authorization Validity To Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      validator: (_) {
                        if (_maValidFrom != null &&
                            _maValidTo != null &&
                            _maValidTo!.isBefore(_maValidFrom!)) {
                          return 'ma_valid_to must be >= ma_valid_from';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _regulatoryStatusController,
                  'Regulatory Status *',
                  helperText: 'Code value (up to 20 chars)',
                  maxLength: 20,
                  validator: PharmaFieldValidators.validateRegulatoryStatus,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _prescriptionStatus,
                  decoration: const InputDecoration(
                    labelText: 'Prescription Status *',
                    border: OutlineInputBorder(),
                  ),
                  items: PharmaFieldValidators.prescriptionStatusCodes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: widget.isEditing
                      ? (v) => setState(() => _prescriptionStatus = v ?? 'RX')
                      : null,
                  validator: widget.isEditing
                      ? PharmaFieldValidators.validatePrescriptionStatus
                      : null,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Controlled Substance Indicator'),
                  value: _controlledSubstance,
                  onChanged: widget.isEditing
                      ? (v) => setState(() => _controlledSubstance = v)
                      : null,
                ),
                _buildTextField(
                  _controlledSubstanceScheduleController,
                  'Controlled Substance Schedule',
                  helperText: 'Required when Controlled Substance Indicator = true',
                  maxLength: 10,
                  validator: (v) => PharmaFieldValidators
                      .validateControlledSubstanceSchedule(v, controlled: _controlledSubstance),
                ),
                SwitchListTile(
                  title: const Text(
                    'Black Triangle / Additional Monitoring Indicator',
                  ),
                  value: _additionalMonitoring,
                  onChanged: widget.isEditing
                      ? (v) => setState(() => _additionalMonitoring = v)
                      : null,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  _shelfLifeMonthsController,
                  'Shelf Life from Production (months) *',
                  helperText: 'Numeric, 1–360',
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                  validator: PharmaFieldValidators.validateShelfLifeMonths,
                ),
                _buildTextField(
                  _shelfLifeAfterOpenDaysController,
                  'Shelf Life After Opening (days)',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: PharmaFieldValidators.validateShelfLifeAfterOpenDays,
                ),
                GtinCountryCodePickerField(
                  controller: _countryOfManufactureController,
                  labelText: 'Country of Manufacture *',
                  helperText: 'ISO 3166-1 numeric (3 digits)',
                  enabled: widget.isEditing,
                  validator: PharmaFieldValidators.validateCountryOfManufacture,
                ),
                _buildTextField(
                  _packSizeDescriptionController,
                  'Pack Size Description (free text)',
                  helperText: 'Up to 100 chars',
                  maxLength: 100,
                  validator: PharmaFieldValidators.validatePackSizeDescription,
                ),

                // Note: Save button removed - pharmaceutical extension is saved with the main GTIN form
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF121F17),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? helperText,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
        readOnly: !widget.isEditing,
        validator: validator,
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: widget.isEditing ? onChanged : null,
        ),
        Text(label),
      ],
    );
  }
}
