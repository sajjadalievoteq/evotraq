import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/features/tobacco/widgets/gln_tobacco_extension_widget.dart';
import 'package:traqtrace_app/data/services/gln_tobacco_extension_service.dart';
import 'package:traqtrace_app/data/services/gln_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_contact_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_digital_location_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_geospatial_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_identification_structure_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_legal_entity_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_license_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_lifecycle_status_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_location_address_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_operational_location_type_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/core_groups/gln_types_classification_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_industry_extensions_section.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_location_type_mapper.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

/// Screen for viewing and editing GLN details (same form pattern as GTIN: [Form] + controllers).
class GLNDetailScreen extends StatefulWidget {
  /// GLN ID for existing GLN, null for new GLN
  final String? glnId;

  /// Whether we are editing an existing GLN or creating a new one
  final bool isEditing;

  /// When true, renders form body only (no scaffold); used in desktop split view.
  final bool embedded;

  /// When [embedded] is true, invoked after a successful save instead of [Navigator.pop].
  final VoidCallback? onEmbeddedActionSuccess;

  const GLNDetailScreen({
    super.key,
    this.glnId,
    required this.isEditing,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  @override
  State<GLNDetailScreen> createState() => _GLNDetailScreenState();
}

class _GLNDetailScreenState extends State<GLNDetailScreen>
    with GS1FormValidationMixin<GLNDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pharmaExtensionKey = GlobalKey<GLNPharmaceuticalExtensionWidgetState>();
  final _tobaccoExtensionKey = GlobalKey<GLNTobaccoExtensionWidgetState>();

  late final TextEditingController _glnCodeController;
  late final TextEditingController _gs1CompanyPrefixController;
  late final TextEditingController _locationReferenceDigitsController;
  late final TextEditingController _checkDigitController;
  late final TextEditingController _parentGlnCodeController;
  late final TextEditingController _glnExtensionComponentController;
  late final TextEditingController _locationNameController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateProvinceController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _mobileLocationIdentifierController;
  late final TextEditingController _registeredLegalNameController;
  late final TextEditingController _tradingNameController;
  late final TextEditingController _leiCodeController;
  late final TextEditingController _taxRegistrationNumberController;
  late final TextEditingController _countryOfIncorporationNumericController;
  late final TextEditingController _websiteController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _digitalAddressValueController;
  late final TextEditingController _supplyChainRolesController;
  late final TextEditingController _locationRolesController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseTypeController;

  String _operatingStatus = 'ACTIVE';
  String _industryClassification = 'HEALTHCARE';
  String _glnSource = 'SELF_ALLOCATED';
  String _mobility = 'FIXED';
  String _digitalAddressType = 'URL';
  String _locationTypeLabel = 'Other';
  List<String> _glnTypes = ['FIXED_PHYSICAL'];
  String? _glnTypesErrorText;

  String? _hydratedTag;

  DateTime? _licenseValidFrom;
  DateTime? _licenseExpiry;
  DateTime? _effectiveFrom;
  DateTime? _effectiveTo;
  DateTime? _nonReuseUntil;

  bool _hasSubmittedForm = false;
  GeospatialCoordinates? _coordinates;

  bool get _readOnly => !widget.isEditing;

  @override
  void initState() {
    super.initState();
    _glnCodeController = TextEditingController();
    _gs1CompanyPrefixController = TextEditingController();
    _locationReferenceDigitsController = TextEditingController();
    _checkDigitController = TextEditingController();
    _parentGlnCodeController = TextEditingController();
    _glnExtensionComponentController = TextEditingController();
    _locationNameController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateProvinceController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _mobileLocationIdentifierController = TextEditingController();
    _registeredLegalNameController = TextEditingController();
    _tradingNameController = TextEditingController();
    _leiCodeController = TextEditingController();
    _taxRegistrationNumberController = TextEditingController();
    _countryOfIncorporationNumericController = TextEditingController();
    _websiteController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactEmailController = TextEditingController();
    _contactPhoneController = TextEditingController();
    _digitalAddressValueController = TextEditingController();
    _supplyChainRolesController = TextEditingController();
    _locationRolesController = TextEditingController();
    _licenseNumberController = TextEditingController();
    _licenseTypeController = TextEditingController();

    context.read<GLNCubit>().clearSelection();
    if (widget.glnId != null) {
      context.read<GLNCubit>().fetchGLNById(widget.glnId!);
    }
  }

  @override
  void dispose() {
    _glnCodeController.dispose();
    _gs1CompanyPrefixController.dispose();
    _locationReferenceDigitsController.dispose();
    _checkDigitController.dispose();
    _parentGlnCodeController.dispose();
    _glnExtensionComponentController.dispose();
    _locationNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateProvinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _mobileLocationIdentifierController.dispose();
    _registeredLegalNameController.dispose();
    _tradingNameController.dispose();
    _leiCodeController.dispose();
    _taxRegistrationNumberController.dispose();
    _countryOfIncorporationNumericController.dispose();
    _websiteController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _digitalAddressValueController.dispose();
    _supplyChainRolesController.dispose();
    _locationRolesController.dispose();
    _licenseNumberController.dispose();
    _licenseTypeController.dispose();
    context.read<GLNCubit>().clearSelection();
    super.dispose();
  }

  void _applyGlnToLocalState(GLN g) {
    _licenseValidFrom = g.licenseValidFrom;
    _licenseExpiry = g.licenseExpiry;
    _effectiveFrom = g.effectiveFrom;
    _effectiveTo = g.effectiveTo;
    _nonReuseUntil = g.nonReuseUntil;
    _coordinates = g.coordinates;
  }

  void _populateFromGln(GLN? g) {
    if (g == null) {
      _glnCodeController.clear();
      _gs1CompanyPrefixController.clear();
      _locationReferenceDigitsController.clear();
      _checkDigitController.clear();
      _parentGlnCodeController.clear();
      _glnExtensionComponentController.clear();
      _locationNameController.clear();
      _addressLine1Controller.clear();
      _addressLine2Controller.clear();
      _cityController.clear();
      _stateProvinceController.clear();
      _postalCodeController.clear();
      _countryController.clear();
      _mobileLocationIdentifierController.clear();
      _registeredLegalNameController.clear();
      _tradingNameController.clear();
      _leiCodeController.clear();
      _taxRegistrationNumberController.clear();
      _countryOfIncorporationNumericController.clear();
      _websiteController.clear();
      _contactNameController.clear();
      _contactEmailController.clear();
      _contactPhoneController.clear();
      _digitalAddressValueController.clear();
      _supplyChainRolesController.clear();
      _locationRolesController.clear();
      _licenseNumberController.clear();
      _licenseTypeController.clear();

      _operatingStatus = 'ACTIVE';
      _industryClassification = 'HEALTHCARE';
      _glnSource = 'SELF_ALLOCATED';
      _mobility = 'FIXED';
      _digitalAddressType = 'URL';
      _locationTypeLabel = 'Other';
      _glnTypes = ['FIXED_PHYSICAL'];
      _licenseValidFrom = null;
      _licenseExpiry = null;
      _effectiveFrom = null;
      _effectiveTo = null;
      _nonReuseUntil = null;
      _coordinates = null;
      return;
    }

    _glnCodeController.text = g.glnCode;
    _gs1CompanyPrefixController.text = g.gs1CompanyPrefix ?? '';
    _locationReferenceDigitsController.text = g.locationReferenceDigits ?? '';
    _checkDigitController.text = g.checkDigit ?? '';
    _parentGlnCodeController.text = g.parentGln?.glnCode ?? '';
    _glnExtensionComponentController.text = g.glnExtensionComponent ?? '';
    _locationNameController.text = g.locationName;
    _addressLine1Controller.text = g.addressLine1;
    _addressLine2Controller.text = g.addressLine2 ?? '';
    _cityController.text = g.city;
    _stateProvinceController.text = g.stateProvince;
    _postalCodeController.text = g.postalCode;
    _countryController.text = g.country;
    _mobileLocationIdentifierController.text = g.mobileLocationIdentifier ?? '';
    _registeredLegalNameController.text = g.registeredLegalName ?? '';
    _tradingNameController.text = g.tradingName ?? '';
    _leiCodeController.text = g.leiCode ?? '';
    _taxRegistrationNumberController.text = g.taxRegistrationNumber ?? '';
    _countryOfIncorporationNumericController.text =
        g.countryOfIncorporationNumeric ?? '';
    _websiteController.text = g.website ?? '';
    _contactNameController.text = g.contactName ?? '';
    _contactEmailController.text = g.contactEmail ?? '';
    _contactPhoneController.text = g.contactPhone ?? '';
    _digitalAddressValueController.text = g.digitalAddressValue ?? '';
    _supplyChainRolesController.text = g.supplyChainRoles.join(', ');
    _locationRolesController.text = g.locationRoles.join(', ');
    _licenseNumberController.text = g.licenseNumber ?? '';
    _licenseTypeController.text = g.licenseType ?? '';

    _operatingStatus = (g.operatingStatus ?? 'ACTIVE').toUpperCase();
    _industryClassification = g.industryClassification ?? 'HEALTHCARE';
    _glnSource = g.glnSource ?? 'SELF_ALLOCATED';
    _mobility = g.mobility ?? 'FIXED';
    _digitalAddressType = g.digitalAddressType ?? 'URL';
    _locationTypeLabel = GlnLocationTypeMapper.toDropdownLabel(g.locationType);
    _glnTypes = g.glnTypes.isEmpty ? ['FIXED_PHYSICAL'] : List<String>.from(g.glnTypes);

    _applyGlnToLocalState(g);
  }

  void _maybeHydrateFromGln(GLN? g) {
    if (widget.glnId != null && g == null) {
      return;
    }
    final tag = widget.glnId == null ? 'create' : g!.glnCode;
    if (_hydratedTag == tag) {
      return;
    }
    _hydratedTag = tag;
    _populateFromGln(g);
    setState(() {});
  }

  List<String> _splitRoles(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _pickDate(ValueChanged<DateTime?> onPick, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      onPick(picked);
    }
  }

  void _submitForm() {
    if (_glnTypes.isEmpty) {
      setState(() {
        _glnTypesErrorText = 'Select at least one GLN type';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _glnTypesErrorText = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final glnCode = GlnFormat.stripGlnInput(_glnCodeController.text);
    final locationName = _locationNameController.text;
    final addressLine1 = _addressLine1Controller.text;
    final city = _cityController.text;
    final stateProvince = _stateProvinceController.text;
    final postalCode = _postalCodeController.text;
    final country = _countryController.text;

    final isValid = validateAllFields({
      'glnCode': {'value': glnCode, 'validator': GlnFieldValidators.validateGlnCode},
      'locationName': {
        'value': locationName,
        'validator': GlnFieldValidators.validateLocationNameRequired,
      },
      'addressLine1': {
        'value': addressLine1,
        'validator': GlnFieldValidators.validateAddressLine1Required,
      },
      'city': {
        'value': city,
        'validator': GlnFieldValidators.validateCityRequired,
      },
      'stateProvince': {
        'value': stateProvince,
        'validator': GlnFieldValidators.validateStateProvinceRequired,
      },
      'postalCode': {
        'value': postalCode,
        'validator': GlnFieldValidators.validatePostalCodeRequired,
      },
      'country': {
        'value': country,
        'validator': GlnFieldValidators.validateCountryRequired,
      },
    });

    if (!isValid) return;

    final operatingStatus = _operatingStatus.toUpperCase();
    final active = operatingStatus == 'ACTIVE';

    final parentRaw = GlnFormat.stripGlnInput(_parentGlnCodeController.text);
    final parentGln = parentRaw.length == 13 ? GLN.fromCode(parentRaw) : null;

    final gln = GLN(
      glnCode: glnCode,
      locationName: locationName,
      addressLine1: addressLine1,
      addressLine2: _nonEmptyOrNull(_addressLine2Controller.text),
      city: city,
      stateProvince: stateProvince,
      postalCode: postalCode,
      country: country,
      contactName: _nonEmptyOrNull(_contactNameController.text),
      contactEmail: _nonEmptyOrNull(_contactEmailController.text),
      contactPhone: _nonEmptyOrNull(_contactPhoneController.text),
      locationType: GlnLocationTypeMapper.parseDropdown(_locationTypeLabel),
      parentGln: parentGln,
      licenseNumber: _nonEmptyOrNull(_licenseNumberController.text),
      licenseType: _nonEmptyOrNull(_licenseTypeController.text),
      licenseValidFrom: _licenseValidFrom,
      licenseExpiry: _licenseExpiry,
      active: active,
      coordinates: _coordinates,
      operatingStatus: operatingStatus,
      effectiveFrom: _effectiveFrom,
      effectiveTo: _effectiveTo,
      nonReuseUntil: _nonReuseUntil,
      gs1CompanyPrefix: _nonEmptyOrNull(_gs1CompanyPrefixController.text),
      locationReferenceDigits:
          _nonEmptyOrNull(_locationReferenceDigitsController.text),
      checkDigit: _nonEmptyOrNull(_checkDigitController.text),
      registeredLegalName: _nonEmptyOrNull(_registeredLegalNameController.text),
      tradingName: _nonEmptyOrNull(_tradingNameController.text),
      leiCode: _nonEmptyOrNull(_leiCodeController.text),
      taxRegistrationNumber:
          _nonEmptyOrNull(_taxRegistrationNumberController.text),
      countryOfIncorporationNumeric:
          _nonEmptyOrNull(_countryOfIncorporationNumericController.text.trim()),
      website: _nonEmptyOrNull(_websiteController.text),
      digitalAddressType: _digitalAddressType,
      digitalAddressValue: _nonEmptyOrNull(_digitalAddressValueController.text),
      glnExtensionComponent:
          _nonEmptyOrNull(_glnExtensionComponentController.text),
      industryClassification: _industryClassification,
      glnSource: _glnSource,
      mobility: _mobility,
      mobileLocationIdentifier:
          _nonEmptyOrNull(_mobileLocationIdentifierController.text),
      glnTypes: List<String>.from(_glnTypes),
      supplyChainRoles: _splitRoles(_supplyChainRolesController.text),
      locationRoles: _splitRoles(_locationRolesController.text),
    );

    setState(() => _hasSubmittedForm = true);

    if (widget.isEditing && widget.glnId != null) {
      context.read<GLNCubit>().updateGLN(widget.glnId!, gln);
    } else {
      context.read<GLNCubit>().createGLN(gln);
    }
  }

  String? _nonEmptyOrNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _saveTobaccoExtensionIfNeeded(String glnCode) async {
    if (!kTobaccoExtensionEnabled) return;
    final tobaccoState = _tobaccoExtensionKey.currentState;
    if (tobaccoState == null || !tobaccoState.hasData) return;

    try {
      final extension = tobaccoState.buildExtension(glnId: null, glnCode: glnCode);
      if (extension != null) {
        await getIt<GLNTobaccoExtensionService>().createByGlnCode(glnCode, extension);
      }
    } catch (e) {
      debugPrint('Error saving GLN tobacco extension: $e');
    }
  }

  Future<void> _savePharmaExtensionIfNeeded(String glnCode) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    if (pharmaState == null || !pharmaState.hasData) return;

    try {
      final extension = pharmaState.buildExtension(glnId: null, glnCode: glnCode);
      if (extension != null) {
        await getIt<GLNPharmaceuticalExtensionService>()
            .createByGlnCode(glnCode, extension);
      }
    } catch (e) {
      debugPrint('Error saving GLN pharmaceutical extension: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocConsumer<GLNCubit, GLNState>(
      listener: (context, state) {
        if (state.status == GLNStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (state.status == GLNStatus.success && _hasSubmittedForm) {
          setState(() => _hasSubmittedForm = false);
          final glnCode = GlnFormat.stripGlnInput(_glnCodeController.text);
          _saveTobaccoExtensionIfNeeded(glnCode);
          _savePharmaExtensionIfNeeded(glnCode);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GLN saved successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
            widget.onEmbeddedActionSuccess!();
          } else {
            Navigator.of(context).pop();
          }
          return;
        }
        if (state.status == GLNStatus.success &&
            state.selectedGLN != null &&
            widget.glnId != null) {
          _maybeHydrateFromGln(state.selectedGLN);
        }
      },
      builder: (context, state) {
        if (widget.glnId != null &&
            state.selectedGLN == null &&
            state.status == GLNStatus.loading) {
          return const Center(child: LoadingIndicator());
        }

        final gln = widget.glnId != null ? state.selectedGLN : null;

        if (widget.glnId != null && gln == null) {
          return const Center(child: Text('Loading GLN details...'));
        }

        _maybeHydrateFromGln(gln);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlnIdentificationStructureCoreGroup(
                  setFieldError: setFieldError,
                  readOnly: _readOnly,
                  glnCodeController: _glnCodeController,
                  gs1CompanyPrefixController: _gs1CompanyPrefixController,
                  locationReferenceDigitsController:
                      _locationReferenceDigitsController,
                  checkDigitController: _checkDigitController,
                  parentGlnCodeController: _parentGlnCodeController,
                  glnExtensionComponentController:
                      _glnExtensionComponentController,
                ),
                GlnLifecycleStatusCoreGroup(
                  isEditing: widget.isEditing,
                  operatingStatus: _operatingStatus,
                  onOperatingStatusChanged: (v) {
                    if (v != null) setState(() => _operatingStatus = v);
                  },
                  effectiveFrom: _effectiveFrom,
                  effectiveTo: _effectiveTo,
                  nonReuseUntil: _nonReuseUntil,
                  onPickEffectiveFrom: () => _pickDate(
                    (d) => setState(() => _effectiveFrom = d),
                    _effectiveFrom,
                  ),
                  onPickEffectiveTo: () => _pickDate(
                    (d) => setState(() => _effectiveTo = d),
                    _effectiveTo,
                  ),
                ),
                GlnTypesClassificationCoreGroup(
                  isEditing: widget.isEditing,
                  setFieldError: setFieldError,
                  glnTypes: _glnTypes,
                  onGlnTypesChanged: (next) {
                    setState(() {
                      _glnTypes = next;
                      _glnTypesErrorText = null;
                    });
                  },
                  glnTypesErrorText: _glnTypesErrorText,
                  industryClassification: _industryClassification,
                  onIndustryClassificationChanged: (v) {
                    if (v != null) setState(() => _industryClassification = v);
                  },
                  glnSource: _glnSource,
                  onGlnSourceChanged: (v) {
                    if (v != null) setState(() => _glnSource = v);
                  },
                  supplyChainRolesController: _supplyChainRolesController,
                  locationRolesController: _locationRolesController,
                ),
                GlnLegalEntityCoreGroup(
                  setFieldError: setFieldError,
                  readOnly: _readOnly,
                  registeredLegalNameController: _registeredLegalNameController,
                  tradingNameController: _tradingNameController,
                  leiCodeController: _leiCodeController,
                  taxRegistrationNumberController:
                      _taxRegistrationNumberController,
                  countryOfIncorporationNumericController:
                      _countryOfIncorporationNumericController,
                  websiteController: _websiteController,
                ),
                GlnLocationAddressCoreGroup(
                  setFieldError: setFieldError,
                  readOnly: _readOnly,
                  locationNameController: _locationNameController,
                  mobility: _mobility,
                  onMobilityChanged: (v) {
                    if (v != null) setState(() => _mobility = v);
                  },
                  mobileLocationIdentifierController:
                      _mobileLocationIdentifierController,
                  addressLine1Controller: _addressLine1Controller,
                  addressLine2Controller: _addressLine2Controller,
                  cityController: _cityController,
                  stateProvinceController: _stateProvinceController,
                  postalCodeController: _postalCodeController,
                  countryController: _countryController,
                ),
                GlnDigitalLocationCoreGroup(
                  setFieldError: setFieldError,
                  readOnly: _readOnly,
                  digitalAddressType: _digitalAddressType,
                  onDigitalAddressTypeChanged: (v) {
                    if (v != null) setState(() => _digitalAddressType = v);
                  },
                  digitalAddressValueController: _digitalAddressValueController,
                ),
                GlnContactCoreGroup(
                  setFieldError: setFieldError,
                  readOnly: _readOnly,
                  contactNameController: _contactNameController,
                  contactEmailController: _contactEmailController,
                  contactPhoneController: _contactPhoneController,
                ),
                GlnOperationalLocationTypeCoreGroup(
                  isEditing: widget.isEditing,
                  locationTypeLabel: _locationTypeLabel,
                  onLocationTypeChanged: (v) {
                    if (v != null) setState(() => _locationTypeLabel = v);
                  },
                ),
                GlnLicenseCoreGroup(
                  setFieldError: setFieldError,
                  readOnly: _readOnly,
                  isEditing: widget.isEditing,
                  licenseValidFrom: _licenseValidFrom,
                  licenseExpiry: _licenseExpiry,
                  onPickLicenseValidFrom: () => _pickDate(
                    (d) => setState(() => _licenseValidFrom = d),
                    _licenseValidFrom,
                  ),
                  onPickLicenseExpiry: () => _pickDate(
                    (d) => setState(() => _licenseExpiry = d),
                    _licenseExpiry,
                  ),
                  licenseNumberController: _licenseNumberController,
                  licenseTypeController: _licenseTypeController,
                ),
                GlnGeospatialCoreGroup(
                  displayCoordinates: _coordinates ?? gln?.coordinates,
                  onCoordinatesChanged: (c) {
                    setState(() => _coordinates = c);
                  },
                  isEditing: widget.isEditing,
                ),
                const SizedBox(height: 16),
                GlnIndustryExtensionsSection(
                  glnCodeController: _glnCodeController,
                  gln: gln,
                  isEditing: widget.isEditing,
                  pharmaExtensionKey: _pharmaExtensionKey,
                  tobaccoExtensionKey: _tobaccoExtensionKey,
                ),
                const SizedBox(height: 24),
                if ((MediaQuery.of(context).size.width < 600 || widget.embedded) &&
                    widget.isEditing)
                  CustomButtonWidget(
                    onTap: _submitForm,
                    title: 'SAVE GLN',
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? (widget.glnId != null ? 'Edit GLN' : 'Create GLN')
            : 'GLN Details'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: _submitForm,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
