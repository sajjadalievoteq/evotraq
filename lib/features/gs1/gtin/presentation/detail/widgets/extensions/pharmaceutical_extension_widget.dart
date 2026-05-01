import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_dosage_route_composition_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_prescription_requirements_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_regulatory_approvals_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_storage_handling_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_national_identifiers_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_data_carrier_integrity_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_tech_dispensing_lifecycle_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_tech_mah_authorization_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_tech_product_coded_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_warnings_precautions_widget.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_controlled_substance_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_drug_classification_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharma_groups/pharma_group_drug_identification_widget.dart';


/// Widget that displays/edits pharmaceutical extension data for a GTIN
/// Can be embedded in GTIN detail screens or used standalone
class PharmaceuticalExtensionWidget extends StatefulWidget {
  final int? gtinId;
  final String? gtinCode;
  final bool isEditing;
  final String? targetMarketCountry;
  final Function(GTINPharmaceuticalExtension?)? onSaved;
  final GTINPharmaceuticalExtension? initialExtension;

  const PharmaceuticalExtensionWidget({
    Key? key,
    this.gtinId,
    this.gtinCode,
    this.isEditing = false,
    this.targetMarketCountry,
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

  // Drug Identification (owned by dedicated group widget)
  String _ndcNumber = '';
  String _dinNumber = '';
  String _eanPharmaCode = '';

  // Drug Classification
  String _drugClass = '';
  String _therapeuticClass = '';
  String _pharmacologicalClass = '';
  String _atcCode = '';

  // Controlled Substance
  bool _isControlledSubstance = false;
  DeaSchedule _deaSchedule = DeaSchedule.none;
  String _controlClass = '';

  // Dosage Information
  String _dosageForm = '';
  String _strength = '';
  String _strengthUnit = '';
  String _routeOfAdministration = '';
  List<ActiveIngredient> _activeIngredients = [];
  String _inactiveIngredients = '';

  // Storage Requirements
  String _storageConditions = '';
  String _minStorageTemp = '';
  String _maxStorageTemp = '';
  bool _requiresRefrigeration = false;
  bool _requiresFreezing = false;
  bool _lightSensitive = false;
  bool _humiditySensitive = false;

  // Prescription Requirements
  bool _requiresPrescription = true;
  String _prescriptionType = '';

  // Regulatory
  DateTime? _fdaApprovalDate;
  String _fdaApplicationNumber = '';
  DateTime? _emaApprovalDate;
  String _emaProcedureNumber = '';

  // Warnings
  bool _blackBoxWarning = false;
  String _blackBoxWarningText = '';
  String _contraindications = '';
  String _drugInteractions = '';
  PregnancyCategory _pregnancyCategory = PregnancyCategory.notClassified;

  // ---------------------------------------------------------------------------
  // Pharma technical spec (Section 5) — persisted via [GTINPharmaceuticalExtension.toJson]
  // ---------------------------------------------------------------------------
  String _regulatedProductName = '';
  String _dosageFormTypeCode = '';
  String _routeOfAdministrationCode = '';

  String _mahGln = '';
  String _mahName = '';
  String _mahCountry = '';
  String _licensedAgentGlns = '';
  String _additionalAtcCodes = '';

  String _maNumber = '';
  DateTime? _maValidFrom;
  DateTime? _maValidTo;

  String _regulatoryStatus = '';

  String _prescriptionStatus = 'RX';
  bool _controlledSubstance = false;
  String _controlledSubstanceSchedule = '';
  bool _additionalMonitoring = false;

  String _shelfLifeMonths = '';
  String _shelfLifeAfterOpenDays = '';

  String _countryOfManufacture = '';
  String _packSizeDescription = '';

  String _nhmnGermanyPzn = '';
  String _nhmnFranceCip = '';
  String _nhmnSpainCn = '';
  String _nhmnBrazilAnvisa = '';
  String _nhmnPortugalAim = '';
  String _nhmnUsaNdc = '';
  String _nhmnItalyAifa = '';
  String _localDrugCodeUaeGcc = '';

  String _dataCarrierTypeCode = '';
  bool _antiTamperingIndicator = false;
  bool _pseudoGtinNtinFlag = false;
  bool _coldChainRequired = false;

  String _activePotencyAi7004 = '';
  final _fdaApprovalDateDisplay = TextEditingController();
  final _emaApprovalDateDisplay = TextEditingController();

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

  void _applyState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }

  @override
  void dispose() {


    _fdaApprovalDateDisplay.dispose();
    _emaApprovalDateDisplay.dispose();
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

  static List<String> _splitDelimitedGlnsOrCodes(String raw) {
    if (raw.trim().isEmpty) return const [];
    final parts = raw.split(RegExp(r'[\s,;\n]+'));
    return parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  void _populateFormFromExtension(GTINPharmaceuticalExtension ext) {
    _ndcNumber = ext.ndcNumber ?? '';
    _dinNumber = ext.dinNumber ?? '';
    _eanPharmaCode = ext.eanPharmaCode ?? '';
    _drugClass = ext.drugClass ?? '';
    _therapeuticClass = ext.therapeuticClass ?? '';
    _pharmacologicalClass = ext.pharmacologicalClass ?? '';
    _atcCode = ext.atcCode ?? '';
    _isControlledSubstance = ext.isControlledSubstance;
    _deaSchedule = ext.deaSchedule;
    _controlClass = ext.controlClass ?? '';
    _dosageForm = ext.dosageForm ?? '';
    _strength = ext.strength ?? '';
    _strengthUnit = ext.strengthUnit ?? '';
    _routeOfAdministration = ext.routeOfAdministration ?? '';
    _storageConditions = ext.storageConditions ?? '';
    _minStorageTemp = ext.minStorageTempCelsius?.toString() ?? '';
    _maxStorageTemp = ext.maxStorageTempCelsius?.toString() ?? '';
    _requiresRefrigeration = ext.requiresRefrigeration;
    _requiresFreezing = ext.requiresFreezing;
    _lightSensitive = ext.lightSensitive;
    _humiditySensitive = ext.humiditySensitive;
    _requiresPrescription = ext.requiresPrescription;
    _prescriptionType = ext.prescriptionType ?? '';
    _fdaApprovalDate = ext.fdaApprovalDate;
    _fdaApplicationNumber = ext.fdaApplicationNumber ?? '';
    _emaApprovalDate = ext.emaApprovalDate;
    _emaProcedureNumber = ext.emaProcedureNumber ?? '';
    _fdaApprovalDateDisplay.text =
        ext.fdaApprovalDate != null ? _docDateFmt.format(ext.fdaApprovalDate!) : '';
    _emaApprovalDateDisplay.text =
        ext.emaApprovalDate != null ? _docDateFmt.format(ext.emaApprovalDate!) : '';
    _blackBoxWarning = ext.blackBoxWarning;
    _blackBoxWarningText = ext.blackBoxWarningText ?? '';
    _contraindications = ext.contraindications ?? '';
    _drugInteractions = ext.drugInteractions ?? '';
    _pregnancyCategory = ext.pregnancyCategory;

    _regulatedProductName = ext.regulatedProductName ?? '';
    _dosageFormTypeCode = ext.dosageFormTypeCode ?? '';
    _routeOfAdministrationCode = ext.routeOfAdministrationEdqmCode ?? '';
    _mahGln = ext.mahGln ?? '';
    _mahName = ext.mahName ?? '';
    _mahCountry = ext.mahCountry ?? '';
    _licensedAgentGlns = ext.licensedAgentGlns.join(', ');
    _additionalAtcCodes = ext.additionalAtcCodes.join(', ');
    _maNumber = ext.marketingAuthorizationNumber ?? '';
    _maValidFrom = ext.marketingAuthorizationValidFrom;
    _maValidTo = ext.marketingAuthorizationValidTo;
    _regulatoryStatus = ext.regulatoryStatus ?? '';
    _prescriptionStatus =
        (ext.prescriptionStatusCategory != null &&
                ext.prescriptionStatusCategory!.isNotEmpty &&
                PharmaFieldValidators.prescriptionStatusCodes
                    .contains(ext.prescriptionStatusCategory))
            ? ext.prescriptionStatusCategory!
            : 'RX';
    _controlledSubstance = ext.specControlledSubstanceIndicator;
    _controlledSubstanceSchedule = ext.specControlledSubstanceSchedule ?? '';
    _additionalMonitoring = ext.additionalMonitoringIndicator;
    _shelfLifeMonths = ext.shelfLifeMonths?.toString() ?? '';
    _shelfLifeAfterOpenDays = ext.shelfLifeAfterOpeningDays?.toString() ?? '';
    _countryOfManufacture = ext.countryOfManufactureNumeric ?? '';
    _packSizeDescription = ext.packSizeDescription ?? '';

    _nhmnGermanyPzn = ext.nhmnGermanyPzn ?? '';
    _nhmnFranceCip = ext.nhmnFranceCip ?? '';
    _nhmnSpainCn = ext.nhmnSpainCn ?? '';
    _nhmnBrazilAnvisa = ext.nhmnBrazilAnvisa ?? '';
    _nhmnPortugalAim = ext.nhmnPortugalAim ?? '';
    _nhmnUsaNdc = ext.nhmnUsaNdc ?? '';
    _nhmnItalyAifa = ext.nhmnItalyAifa ?? '';
    _localDrugCodeUaeGcc = ext.localDrugCodeUaeGcc ?? '';

    _dataCarrierTypeCode = ext.dataCarrierTypeCode ?? '';
    _antiTamperingIndicator = ext.antiTamperingIndicator;
    _pseudoGtinNtinFlag = ext.pseudoGtinNtinFlag;
    _coldChainRequired = ext.coldChainRequired;
    _activePotencyAi7004 = ext.activePotencyAi7004?.toString() ?? '';
    _inactiveIngredients = ext.inactiveIngredients ?? '';
    _activeIngredients = List<ActiveIngredient>.from(ext.activeIngredients);
  }

  /// True when any field should be persisted with the GTIN pharmaceutical extension.
  bool get hasData {
    bool nz(String s) => s.trim().isNotEmpty;

    final basics = nz(_ndcNumber) ||
        nz(_dinNumber) ||
        nz(_eanPharmaCode) ||
        nz(_drugClass) ||
        nz(_dosageForm) ||
        nz(_strength) ||
        nz(_therapeuticClass) ||
        nz(_pharmacologicalClass) ||
        nz(_atcCode);
    if (basics) return true;

    final spec = nz(_regulatedProductName) ||
        nz(_dosageFormTypeCode) ||
        nz(_routeOfAdministrationCode) ||
        nz(_mahGln) ||
        nz(_mahName) ||
        nz(_mahCountry) ||
        nz(_licensedAgentGlns) ||
        nz(_additionalAtcCodes) ||
        nz(_maNumber) ||
        nz(_regulatoryStatus) ||
        nz(_shelfLifeMonths) ||
        nz(_shelfLifeAfterOpenDays) ||
        nz(_countryOfManufacture) ||
        nz(_packSizeDescription) ||
        nz(_inactiveIngredients) ||
        nz(_fdaApplicationNumber) ||
        nz(_emaProcedureNumber) ||
        nz(_nhmnGermanyPzn) ||
        nz(_nhmnFranceCip) ||
        nz(_nhmnSpainCn) ||
        nz(_nhmnBrazilAnvisa) ||
        nz(_nhmnPortugalAim) ||
        nz(_nhmnUsaNdc) ||
        nz(_nhmnItalyAifa) ||
        nz(_localDrugCodeUaeGcc) ||
        nz(_dataCarrierTypeCode) ||
        nz(_activePotencyAi7004) ||
        nz(_contraindications) ||
        nz(_drugInteractions) ||
        nz(_blackBoxWarningText) ||
        nz(_storageConditions) ||
        nz(_strengthUnit) ||
        nz(_prescriptionType) ||
        nz(_controlClass) ||
        nz(_minStorageTemp) ||
        nz(_maxStorageTemp);
    if (spec) return true;

    if (_activeIngredients.any((r) => nz(r.name))) return true;

    if (_fdaApprovalDate != null || _emaApprovalDate != null) return true;
    if (_maValidFrom != null || _maValidTo != null) return true;

    if (_coldChainRequired ||
        _antiTamperingIndicator ||
        _pseudoGtinNtinFlag ||
        !_requiresPrescription ||
        _isControlledSubstance ||
        _deaSchedule != DeaSchedule.none ||
        _controlledSubstance ||
        _additionalMonitoring ||
        _blackBoxWarning ||
        _pregnancyCategory != PregnancyCategory.notClassified ||
        _requiresFreezing ||
        _requiresRefrigeration ||
        _lightSensitive ||
        _humiditySensitive) {
      return true;
    }

    return false;
  }

  /// Validate the pharmaceutical extension form
  /// Returns null if valid, error message if invalid
  String? validate() {
    // No required fields for pharmaceutical extension
    // All fields are optional
    return null;
  }

  GTINPharmaceuticalExtension _composeExtension({
    required int gtinId,
    String? gtinCode,
  }) {
    return GTINPharmaceuticalExtension(
      id: _extension?.id,
      gtinId: gtinId,
      gtinCode: gtinCode,
      ndcNumber: _ndcNumber.trim().isEmpty ? null : _ndcNumber.trim(),
      dinNumber: _dinNumber.trim().isEmpty ? null : _dinNumber.trim(),
      eanPharmaCode: _eanPharmaCode.trim().isEmpty ? null : _eanPharmaCode.trim(),
      drugClass: _drugClass.trim().isEmpty ? null : _drugClass.trim(),
      therapeuticClass: _therapeuticClass.trim().isEmpty ? null : _therapeuticClass.trim(),
      pharmacologicalClass:
          _pharmacologicalClass.trim().isEmpty ? null : _pharmacologicalClass.trim(),
      atcCode: _atcCode.trim().isEmpty ? null : _atcCode.trim(),
      isControlledSubstance: _isControlledSubstance,
      deaSchedule: _deaSchedule,
      controlClass: _controlClass.trim().isEmpty ? null : _controlClass.trim(),
      dosageForm: _dosageForm.trim().isEmpty ? null : _dosageForm.trim(),
      strength: _strength.trim().isEmpty ? null : _strength.trim(),
      strengthUnit: _strengthUnit.trim().isEmpty ? null : _strengthUnit.trim(),
      routeOfAdministration:
          _routeOfAdministration.trim().isEmpty ? null : _routeOfAdministration.trim(),
      storageConditions: _storageConditions.trim().isEmpty ? null : _storageConditions.trim(),
      minStorageTempCelsius: double.tryParse(_minStorageTemp),
      maxStorageTempCelsius: double.tryParse(_maxStorageTemp),
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      requiresPrescription: _requiresPrescription,
      prescriptionType: _prescriptionType.trim().isEmpty ? null : _prescriptionType.trim(),
      fdaApprovalDate: _fdaApprovalDate,
      fdaApplicationNumber:
          _fdaApplicationNumber.trim().isEmpty ? null : _fdaApplicationNumber.trim(),
      emaApprovalDate: _emaApprovalDate,
      emaProcedureNumber:
          _emaProcedureNumber.trim().isEmpty ? null : _emaProcedureNumber.trim(),
      activeIngredients: _activeIngredients
          .where((i) => i.name.trim().isNotEmpty)
          .toList(growable: false),
      inactiveIngredients:
          _inactiveIngredients.trim().isEmpty ? null : _inactiveIngredients.trim(),
      blackBoxWarning: _blackBoxWarning,
      blackBoxWarningText:
          _blackBoxWarningText.trim().isEmpty ? null : _blackBoxWarningText.trim(),
      contraindications: _contraindications.trim().isEmpty ? null : _contraindications.trim(),
      drugInteractions: _drugInteractions.trim().isEmpty ? null : _drugInteractions.trim(),
      pregnancyCategory: _pregnancyCategory,
      regulatedProductName:
          _regulatedProductName.trim().isEmpty ? null : _regulatedProductName.trim(),
      dosageFormTypeCode:
          _dosageFormTypeCode.trim().isEmpty ? null : _dosageFormTypeCode.trim(),
      routeOfAdministrationEdqmCode: _routeOfAdministrationCode.trim().isEmpty
          ? null
          : _routeOfAdministrationCode.trim(),
      mahGln: _mahGln.trim().isEmpty ? null : _mahGln.trim(),
      mahName: _mahName.trim().isEmpty ? null : _mahName.trim(),
      mahCountry: _mahCountry.trim().isEmpty ? null : _mahCountry.trim(),
      licensedAgentGlns: _splitDelimitedGlnsOrCodes(_licensedAgentGlns),
      marketingAuthorizationNumber: _maNumber.trim().isEmpty ? null : _maNumber.trim(),
      marketingAuthorizationValidFrom: _maValidFrom,
      marketingAuthorizationValidTo: _maValidTo,
      regulatoryStatus: _regulatoryStatus.trim().isEmpty ? null : _regulatoryStatus.trim(),
      additionalAtcCodes: _splitDelimitedGlnsOrCodes(_additionalAtcCodes),
      nhmnGermanyPzn: _nhmnGermanyPzn.trim().isEmpty ? null : _nhmnGermanyPzn.trim(),
      nhmnFranceCip: _nhmnFranceCip.trim().isEmpty ? null : _nhmnFranceCip.trim(),
      nhmnSpainCn: _nhmnSpainCn.trim().isEmpty ? null : _nhmnSpainCn.trim(),
      nhmnBrazilAnvisa: _nhmnBrazilAnvisa.trim().isEmpty ? null : _nhmnBrazilAnvisa.trim(),
      nhmnPortugalAim: _nhmnPortugalAim.trim().isEmpty ? null : _nhmnPortugalAim.trim(),
      nhmnUsaNdc: _nhmnUsaNdc.trim().isEmpty ? null : _nhmnUsaNdc.trim(),
      nhmnItalyAifa: _nhmnItalyAifa.trim().isEmpty ? null : _nhmnItalyAifa.trim(),
      localDrugCodeUaeGcc:
          _localDrugCodeUaeGcc.trim().isEmpty ? null : _localDrugCodeUaeGcc.trim(),
      dataCarrierTypeCode:
          _dataCarrierTypeCode.trim().isEmpty ? null : _dataCarrierTypeCode.trim(),
      antiTamperingIndicator: _antiTamperingIndicator,
      pseudoGtinNtinFlag: _pseudoGtinNtinFlag,
      coldChainRequired: _coldChainRequired,
      prescriptionStatusCategory: _prescriptionStatus,
      specControlledSubstanceIndicator: _controlledSubstance,
      specControlledSubstanceSchedule: _controlledSubstanceSchedule.trim().isEmpty
          ? null
          : _controlledSubstanceSchedule.trim(),
      additionalMonitoringIndicator: _additionalMonitoring,
      shelfLifeMonths: int.tryParse(_shelfLifeMonths.trim()),
      shelfLifeAfterOpeningDays: int.tryParse(_shelfLifeAfterOpenDays.trim()),
      countryOfManufactureNumeric:
          _countryOfManufacture.trim().isEmpty ? null : _countryOfManufacture.trim(),
      packSizeDescription:
          _packSizeDescription.trim().isEmpty ? null : _packSizeDescription.trim(),
      activePotencyAi7004: double.tryParse(_activePotencyAi7004.trim()),
      createdAt: _extension?.createdAt,
      updatedAt: _extension?.updatedAt,
    );
  }

  /// Build the extension object from form data
  /// Returns null if no data has been entered
  GTINPharmaceuticalExtension? buildExtension({int? gtinId, String? gtinCode}) {
    if (!hasData) return null;
    return _composeExtension(
      gtinId: gtinId ?? widget.gtinId ?? 0,
      gtinCode: gtinCode ?? widget.gtinCode,
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
        //    ? Text('$_drugClass - $_dosageForm')
        //    : const Text('No pharmaceutical extension'),
        initiallyExpanded: _isLoading || _hasExtension,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildGroupedPharmaExtensionBody(context),
          ),
        ],
      ),
    );
  }

  /// Card + [SectionLabel], matching GTIN core trade-item groups (see [SectionLabel]).
  Widget _buildPharmaCoreGroup(BuildContext context, String title, List<Widget> children) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline.withOpacity(0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              title,
              padding: const EdgeInsets.only(bottom: 12),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Groups pharma fields into separate files (one file per group section).
  Widget _buildGroupedPharmaExtensionBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrugIdentificationGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialNdcNumber: _ndcNumber,
          initialDinNumber: _dinNumber,
          initialEanPharmaCode: _eanPharmaCode,
          onChanged: ({required ndcNumber, required dinNumber, required eanPharmaCode}) {
            _ndcNumber = ndcNumber;
            _dinNumber = dinNumber;
            _eanPharmaCode = eanPharmaCode;
          },
        ),
        DrugClassificationGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialDrugClass: _drugClass,
          initialTherapeuticClass: _therapeuticClass,
          initialPharmacologicalClass: _pharmacologicalClass,
          initialAtcCode: _atcCode,
          initialAdditionalAtcCodes: _additionalAtcCodes,
          onChanged: ({
            required drugClass,
            required therapeuticClass,
            required pharmacologicalClass,
            required atcCode,
            required additionalAtcCodes,
          }) {
            _drugClass = drugClass;
            _therapeuticClass = therapeuticClass;
            _pharmacologicalClass = pharmacologicalClass;
            _atcCode = atcCode;
            _additionalAtcCodes = additionalAtcCodes;
          },
        ),
        ControlledSubstanceGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialIsControlledSubstance: _isControlledSubstance,
          initialDeaSchedule: _deaSchedule,
          initialControlClass: _controlClass,
          onChanged: ({
            required isControlledSubstance,
            required deaSchedule,
            required controlClass,
          }) {
            _isControlledSubstance = isControlledSubstance;
            _deaSchedule = deaSchedule;
            _controlClass = controlClass;
          },
        ),
        DosageRouteCompositionGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialDosageForm: _dosageForm,
          initialStrength: _strength,
          initialStrengthUnit: _strengthUnit,
          initialRouteOfAdministration: _routeOfAdministration,
          initialActiveIngredients: _activeIngredients,
          initialInactiveIngredients: _inactiveIngredients,
          onChanged: ({
            required dosageForm,
            required strength,
            required strengthUnit,
            required routeOfAdministration,
            required activeIngredients,
            required inactiveIngredients,
          }) {
            _dosageForm = dosageForm;
            _strength = strength;
            _strengthUnit = strengthUnit;
            _routeOfAdministration = routeOfAdministration;
            _activeIngredients = activeIngredients;
            _inactiveIngredients = inactiveIngredients;
          },
        ),
        StorageHandlingGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialStorageConditions: _storageConditions,
          initialMinStorageTemp: _minStorageTemp,
          initialMaxStorageTemp: _maxStorageTemp,
          initialRequiresRefrigeration: _requiresRefrigeration,
          initialRequiresFreezing: _requiresFreezing,
          initialLightSensitive: _lightSensitive,
          initialHumiditySensitive: _humiditySensitive,
          initialColdChainRequired: _coldChainRequired,
          onChanged: ({
            required storageConditions,
            required minStorageTemp,
            required maxStorageTemp,
            required requiresRefrigeration,
            required requiresFreezing,
            required lightSensitive,
            required humiditySensitive,
            required coldChainRequired,
          }) {
            _storageConditions = storageConditions;
            _minStorageTemp = minStorageTemp;
            _maxStorageTemp = maxStorageTemp;
            _requiresRefrigeration = requiresRefrigeration;
            _requiresFreezing = requiresFreezing;
            _lightSensitive = lightSensitive;
            _humiditySensitive = humiditySensitive;
            _coldChainRequired = coldChainRequired;
          },
        ),
        PrescriptionRequirementsGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialRequiresPrescription: _requiresPrescription,
          initialPrescriptionType: _prescriptionType,
          onChanged: ({
            required requiresPrescription,
            required prescriptionType,
          }) {
            _requiresPrescription = requiresPrescription;
            _prescriptionType = prescriptionType;
          },
        ),
        RegulatoryApprovalsGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialFdaApplicationNumber: _fdaApplicationNumber,
          initialFdaApprovalDate: _fdaApprovalDate,
          initialEmaProcedureNumber: _emaProcedureNumber,
          initialEmaApprovalDate: _emaApprovalDate,
          onChanged: ({
            required fdaApplicationNumber,
            required fdaApprovalDate,
            required emaProcedureNumber,
            required emaApprovalDate,
          }) {
            _fdaApplicationNumber = fdaApplicationNumber;
            _fdaApprovalDate = fdaApprovalDate;
            _emaProcedureNumber = emaProcedureNumber;
            _emaApprovalDate = emaApprovalDate;
          },
        ),
        WarningsPrecautionsGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialBlackBoxWarning: _blackBoxWarning,
          initialBlackBoxWarningText: _blackBoxWarningText,
          initialPregnancyCategory: _pregnancyCategory,
          initialContraindications: _contraindications,
          initialDrugInteractions: _drugInteractions,
          onChanged: ({
            required blackBoxWarning,
            required blackBoxWarningText,
            required pregnancyCategory,
            required contraindications,
            required drugInteractions,
          }) {
            _blackBoxWarning = blackBoxWarning;
            _blackBoxWarningText = blackBoxWarningText;
            _pregnancyCategory = pregnancyCategory;
            _contraindications = contraindications;
            _drugInteractions = drugInteractions;
          },
        ),
        TechProductCodedGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialRegulatedProductName: _regulatedProductName,
          initialDosageFormTypeCode: _dosageFormTypeCode,
          initialRouteOfAdministrationCode: _routeOfAdministrationCode,
          onChanged: ({
            required regulatedProductName,
            required dosageFormTypeCode,
            required routeOfAdministrationCode,
          }) {
            _regulatedProductName = regulatedProductName;
            _dosageFormTypeCode = dosageFormTypeCode;
            _routeOfAdministrationCode = routeOfAdministrationCode;
          },
        ),
        TechMahAuthorizationGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialMahGln: _mahGln,
          initialMahName: _mahName,
          initialMahCountry: _mahCountry,
          initialLicensedAgentGlns: _licensedAgentGlns,
          initialMaNumber: _maNumber,
          initialMaValidFrom: _maValidFrom,
          initialMaValidTo: _maValidTo,
          initialRegulatoryStatus: _regulatoryStatus,
          onChanged: ({
            required mahGln,
            required mahName,
            required mahCountry,
            required licensedAgentGlns,
            required maNumber,
            required maValidFrom,
            required maValidTo,
            required regulatoryStatus,
          }) {
            _mahGln = mahGln;
            _mahName = mahName;
            _mahCountry = mahCountry;
            _licensedAgentGlns = licensedAgentGlns;
            _maNumber = maNumber;
            _maValidFrom = maValidFrom;
            _maValidTo = maValidTo;
            _regulatoryStatus = regulatoryStatus;
          },
        ),
        TechDispensingLifecycleGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialPrescriptionStatus: _prescriptionStatus,
          initialControlledSubstance: _controlledSubstance,
          initialControlledSubstanceSchedule: _controlledSubstanceSchedule,
          initialAdditionalMonitoring: _additionalMonitoring,
          initialShelfLifeMonths: _shelfLifeMonths,
          initialShelfLifeAfterOpenDays: _shelfLifeAfterOpenDays,
          initialCountryOfManufacture: _countryOfManufacture,
          initialPackSizeDescription: _packSizeDescription,
          initialActivePotencyAi7004: _activePotencyAi7004,
          onChanged: ({
            required prescriptionStatus,
            required controlledSubstance,
            required controlledSubstanceSchedule,
            required additionalMonitoring,
            required shelfLifeMonths,
            required shelfLifeAfterOpenDays,
            required countryOfManufacture,
            required packSizeDescription,
            required activePotencyAi7004,
          }) {
            _prescriptionStatus = prescriptionStatus;
            _controlledSubstance = controlledSubstance;
            _controlledSubstanceSchedule = controlledSubstanceSchedule;
            _additionalMonitoring = additionalMonitoring;
            _shelfLifeMonths = shelfLifeMonths;
            _shelfLifeAfterOpenDays = shelfLifeAfterOpenDays;
            _countryOfManufacture = countryOfManufacture;
            _packSizeDescription = packSizeDescription;
            _activePotencyAi7004 = activePotencyAi7004;
          },
        ),
        NationalIdentifiersGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialNhmnGermanyPzn: _nhmnGermanyPzn,
          initialNhmnFranceCip: _nhmnFranceCip,
          initialNhmnSpainCn: _nhmnSpainCn,
          initialNhmnBrazilAnvisa: _nhmnBrazilAnvisa,
          initialNhmnPortugalAim: _nhmnPortugalAim,
          initialNhmnUsaNdc: _nhmnUsaNdc,
          initialNhmnItalyAifa: _nhmnItalyAifa,
          initialLocalDrugCodeUaeGcc: _localDrugCodeUaeGcc,
          onChanged: ({
            required nhmnGermanyPzn,
            required nhmnFranceCip,
            required nhmnSpainCn,
            required nhmnBrazilAnvisa,
            required nhmnPortugalAim,
            required nhmnUsaNdc,
            required nhmnItalyAifa,
            required localDrugCodeUaeGcc,
          }) {
            _nhmnGermanyPzn = nhmnGermanyPzn;
            _nhmnFranceCip = nhmnFranceCip;
            _nhmnSpainCn = nhmnSpainCn;
            _nhmnBrazilAnvisa = nhmnBrazilAnvisa;
            _nhmnPortugalAim = nhmnPortugalAim;
            _nhmnUsaNdc = nhmnUsaNdc;
            _nhmnItalyAifa = nhmnItalyAifa;
            _localDrugCodeUaeGcc = localDrugCodeUaeGcc;
          },
        ),
        DataCarrierIntegrityGroupWidget(
          isEditing: widget.isEditing && !_isLoading,
          showFieldSkeleton: _isLoading,
          initialDataCarrierTypeCode: _dataCarrierTypeCode,
          initialAntiTamperingIndicator: _antiTamperingIndicator,
          initialPseudoGtinNtinFlag: _pseudoGtinNtinFlag,
          onChanged: ({
            required dataCarrierTypeCode,
            required antiTamperingIndicator,
          }) {
            _dataCarrierTypeCode = dataCarrierTypeCode;
            _antiTamperingIndicator = antiTamperingIndicator;
          },
        ),
      ],
    );
  }

  void applyUaeRegulatoryValues({
    required String localDrugCode,
    required String marketingAuthorizationNumber,
    required String licensedAgentGlns,
    required String regulatedProductName,
  }) {
    _localDrugCodeUaeGcc = localDrugCode;
    _maNumber = marketingAuthorizationNumber;
    _licensedAgentGlns = licensedAgentGlns;
    _regulatedProductName = regulatedProductName;
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
