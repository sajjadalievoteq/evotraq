import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/features/tobacco/widgets/gln_tobacco_extension_widget.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_tobacco_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_body.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_skeleton.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_screen_fields.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/utils/gln_location_type_mapper.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';

class GLNDetailScreen extends StatefulWidget {
  final String? glnId;

  final bool isEditing;

  final bool embedded;

  final VoidCallback? onEmbeddedActionSuccess;

  final bool awaitingListSelection;

  const GLNDetailScreen({
    super.key,
    this.glnId,
    required this.isEditing,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
    this.awaitingListSelection = false,
  });

  @override
  State<GLNDetailScreen> createState() => _GLNDetailScreenState();
}

class _GLNDetailScreenState extends State<GLNDetailScreen>
    with GS1FormValidationMixin<GLNDetailScreen>, GlnDetailScreenFields {
  final _formKey = GlobalKey<FormState>();
  final _pharmaExtensionKey =
      GlobalKey<GLNPharmaceuticalExtensionWidgetState>();
  final _tobaccoExtensionKey = GlobalKey<GLNTobaccoExtensionWidgetState>();

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
  bool _forceMountAllSections = false;

  GLNCubit? _glnCubit;
  bool _glnInitialLoadStarted = false;

  bool _formFieldsHydrated = true;

  @override
  void initState() {
    super.initState();
    _formFieldsHydrated = widget.glnId == null && !widget.awaitingListSelection;

    if (!widget.embedded) {
      _glnCubit = GLNCubit(glnService: getIt<GLNService>());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.embedded) {
      _glnCubit = context.read<GLNCubit>();
    }
    if (!_glnInitialLoadStarted) {
      _glnInitialLoadStarted = true;
      if (widget.awaitingListSelection) {
        return;
      }
      final cubit = _glnCubit;
      if (cubit == null) {
        return;
      }
      cubit.clearSelection();
      if (widget.glnId != null) {
        cubit.fetchGLNById(widget.glnId!);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _maybeHydrateFromGln(null);
        });
      }
    }
  }

  @override
  void dispose() {
    disposeGlnDetailFields();
    if (widget.embedded) {
      _glnCubit?.clearSelection();
    } else {
      _glnCubit?.close();
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    if (widget.glnId != null) {
      _glnCubit?.fetchGLNById(widget.glnId!);
    }
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
      clearGlnFieldTexts();

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

    seedGlnFieldTexts(
      glnCode: g.glnCode,
      gs1CompanyPrefix: g.gs1CompanyPrefix ?? '',
      locationReferenceDigits: g.locationReferenceDigits ?? '',
      checkDigit: g.checkDigit ?? '',
      parentGlnCode: g.parentGln?.glnCode ?? '',
      glnExtensionComponent: g.glnExtensionComponent ?? '',
      locationName: g.locationName,
      addressLine1: g.addressLine1,
      addressLine2: g.addressLine2 ?? '',
      city: g.city,
      stateProvince: g.stateProvince,
      postalCode: g.postalCode,
      country: g.country,
      mobileLocationIdentifier: g.mobileLocationIdentifier ?? '',
      registeredLegalName: g.registeredLegalName ?? '',
      tradingName: g.tradingName ?? '',
      leiCode: g.leiCode ?? '',
      taxRegistrationNumber: g.taxRegistrationNumber ?? '',
      countryOfIncorporationNumeric: g.countryOfIncorporationNumeric ?? '',
      website: g.website ?? '',
      contactName: g.contactName ?? '',
      contactEmail: g.contactEmail ?? '',
      contactPhone: g.contactPhone ?? '',
      digitalAddressValue: g.digitalAddressValue ?? '',
      supplyChainRoles: g.supplyChainRoles.join(', '),
      locationRoles: g.locationRoles.join(', '),
      licenseNumber: g.licenseNumber ?? '',
      licenseType: g.licenseType ?? '',
    );

    _operatingStatus = (g.operatingStatus ?? 'ACTIVE').toUpperCase();
    _industryClassification = g.industryClassification ?? 'HEALTHCARE';
    _glnSource = g.glnSource ?? 'SELF_ALLOCATED';
    _mobility = g.mobility ?? 'FIXED';
    _digitalAddressType = g.digitalAddressType ?? 'URL';
    _locationTypeLabel = GlnLocationTypeMapper.toDropdownLabel(g.locationType);
    _glnTypes = g.glnTypes.isEmpty
        ? ['FIXED_PHYSICAL']
        : List<String>.from(g.glnTypes);

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
    _formFieldsHydrated = true;
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

  Future<void> _pickDate(
    ValueChanged<DateTime?> onPick,
    DateTime? current,
  ) async {
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

  Future<void> _submitForm() async {
    if (widget.awaitingListSelection) return;
    if (_glnTypes.isEmpty) {
      setState(() {
        _glnTypesErrorText = GlnUiConstants.errorSelectGlnType;
      });
      context.showError(GlnUiConstants.errorFixForm);
      return;
    }
    setState(() => _glnTypesErrorText = null);

    if (!_forceMountAllSections) {
      setState(() => _forceMountAllSections = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      context.showError(GlnUiConstants.errorFixForm);
      return;
    }

    final glnCode = GlnFormat.stripGlnInput(glnFieldText('glnCode'));
    final locationName = glnFieldText('locationName');
    final addressLine1 = glnFieldText('addressLine1');
    final city = glnFieldText('city');
    final stateProvince = glnFieldText('stateProvince');
    final postalCode = glnFieldText('postalCode');
    final country = glnFieldText('country');

    final isValid = validateAllFields({
      'glnCode': {
        'value': glnCode,
        'validator': GlnFieldValidators.validateGlnCode,
      },
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

    final parentRaw = GlnFormat.stripGlnInput(glnFieldText('parentGlnCode'));
    final parentGln = parentRaw.length == 13 ? GLN.fromCode(parentRaw) : null;

    GLNPharmaceuticalExtension? pharmaceuticalExtension;
    final pharmaSt = _pharmaExtensionKey.currentState;
    if (pharmaSt != null && pharmaSt.hasData) {
      pharmaceuticalExtension = pharmaSt.buildExtension(
        glnId: null,
        glnCode: glnCode,
      );
    }

    GLNTobaccoExtension? tobaccoExtension;
    final tobaccoSt = _tobaccoExtensionKey.currentState;
    if (kTobaccoExtensionEnabled && tobaccoSt != null && tobaccoSt.hasData) {
      tobaccoExtension = tobaccoSt.buildExtension(
        glnId: null,
        glnCode: glnCode,
      );
    }

    final gln = GLN(
      glnCode: glnCode,
      locationName: locationName,
      addressLine1: addressLine1,
      addressLine2: _nonEmptyOrNull(glnFieldText('addressLine2')),
      city: city,
      stateProvince: stateProvince,
      postalCode: postalCode,
      country: country,
      contactName: _nonEmptyOrNull(glnFieldText('contactName')),
      contactEmail: _nonEmptyOrNull(glnFieldText('contactEmail')),
      contactPhone: _nonEmptyOrNull(glnFieldText('contactPhone')),
      locationType: GlnLocationTypeMapper.parseDropdown(_locationTypeLabel),
      parentGln: parentGln,
      licenseNumber: _nonEmptyOrNull(glnFieldText('licenseNumber')),
      licenseType: _nonEmptyOrNull(glnFieldText('licenseType')),
      licenseValidFrom: _licenseValidFrom,
      licenseExpiry: _licenseExpiry,
      active: active,
      coordinates: _coordinates,
      operatingStatus: operatingStatus,
      effectiveFrom: _effectiveFrom,
      effectiveTo: _effectiveTo,
      nonReuseUntil: _nonReuseUntil,
      gs1CompanyPrefix: _nonEmptyOrNull(glnFieldText('gs1CompanyPrefix')),
      locationReferenceDigits:
          _nonEmptyOrNull(glnFieldText('locationReferenceDigits')),
      checkDigit: _nonEmptyOrNull(glnFieldText('checkDigit')),
      registeredLegalName: _nonEmptyOrNull(glnFieldText('registeredLegalName')),
      tradingName: _nonEmptyOrNull(glnFieldText('tradingName')),
      leiCode: _nonEmptyOrNull(glnFieldText('leiCode')),
      taxRegistrationNumber:
          _nonEmptyOrNull(glnFieldText('taxRegistrationNumber')),
      countryOfIncorporationNumeric: _nonEmptyOrNull(
        glnFieldText('countryOfIncorporationNumeric').trim(),
      ),
      website: _nonEmptyOrNull(glnFieldText('website')),
      digitalAddressType: _digitalAddressType,
      digitalAddressValue: _nonEmptyOrNull(glnFieldText('digitalAddressValue')),
      glnExtensionComponent:
          _nonEmptyOrNull(glnFieldText('glnExtensionComponent')),
      industryClassification: _industryClassification,
      glnSource: _glnSource,
      mobility: _mobility,
      mobileLocationIdentifier:
          _nonEmptyOrNull(glnFieldText('mobileLocationIdentifier')),
      glnTypes: List<String>.from(_glnTypes),
      supplyChainRoles: _splitRoles(glnFieldText('supplyChainRoles')),
      locationRoles: _splitRoles(glnFieldText('locationRoles')),
      pharmaceuticalExtension: pharmaceuticalExtension,
      tobaccoExtension: tobaccoExtension,
    );

    setState(() => _hasSubmittedForm = true);

    final cubit = _glnCubit;
    if (cubit == null) {
      return;
    }
    if (widget.glnId != null) {
      cubit.updateGLN(widget.glnId!, gln);
    } else {
      cubit.createGLN(gln);
    }
  }

  String? _nonEmptyOrNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  bool _fieldSkeletonsActive(GLNState state) {
    if (state.status == GLNStatus.error) return false;
    return !_formFieldsHydrated;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      Widget pane(GLNState state) {
        final listLoading =
            state.isGlnListLoading || state.status == GLNStatus.initial;
        if (listLoading) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.padding.top,
              context.padding.top,
              context.padding.top,
              0,
            ),
            child: Gs1FormShimmerLayer(
              show: true,
              formColumn: const SizedBox.shrink(),
              skeleton: const GlnDetailFormSkeleton(),
            ),
          );
        }
        return AppEmptyDetail(
          title: GlnUiConstants.awaitingSelectionTitle,
          subtitle: GlnUiConstants.awaitingSelectionSubtitle,
          iconAsset: NavIcons.gln,
        );
      }

      if (widget.embedded) {
        return BlocBuilder<GLNCubit, GLNState>(
          builder: (context, state) => pane(state),
        );
      }
      final cubit = _glnCubit;
      if (cubit == null) {
        return Scaffold(body: pane(const GLNState()));
      }
      return BlocProvider<GLNCubit>.value(
        value: cubit,
        child: BlocBuilder<GLNCubit, GLNState>(
          builder: (context, state) => Scaffold(body: pane(state)),
        ),
      );
    }

    final role = context.watch<AuthCubit>().state.user?.role;
    final canEditMasterData = role == 'ADMIN' || role == 'MANUFACTURER';
    final allowMasterDataActions =
        canEditMasterData && !widget.awaitingListSelection;
    final formReadOnly = !canEditMasterData;

    final body = BlocConsumer<GLNCubit, GLNState>(
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (state.status == GLNStatus.error) {
            setState(() => _formFieldsHydrated = true);
            context.showError(state.error ?? GlnUiConstants.errorGeneric);
            return;
          }
          if (state.status == GLNStatus.success && _hasSubmittedForm) {
            setState(() => _hasSubmittedForm = false);

            context.showSuccess(GlnUiConstants.successGlnSaved);

            if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else if (context.mounted) {
              final code = state.selectedGLN?.glnCode ?? widget.glnId;
              if (code != null && code.isNotEmpty) {
                context.go(GlnRouteConstants.pathForGlnCode(code));
              } else {
                context.go(Constants.gs1GlnsRoute);
              }
            }
            return;
          }
          if (state.status == GLNStatus.success &&
              state.selectedGLN != null &&
              widget.glnId != null) {
            _maybeHydrateFromGln(state.selectedGLN);
          }
        });
      },
      builder: (context, state) {
        final gln = widget.glnId != null ? state.selectedGLN : null;
        final sk = _fieldSkeletonsActive(state);

        final idStructureReadOnly =
            !canEditMasterData || widget.glnId != null || sk;

        return GlnDetailFormBody(
          formKey: _formKey,
          onRefresh: _refresh,
          showSkeleton: sk,
          forceMountAllSections: _forceMountAllSections,
          gln: gln,
          idStructureReadOnly: idStructureReadOnly,
          canEditMasterData: canEditMasterData,
          formReadOnly: formReadOnly,
          allowMasterDataActions: allowMasterDataActions,
          embedded: widget.embedded,
          onSubmit: () {
            _submitForm();
          },
          setFieldError: setFieldError,
          glnCodeController: glnCodeController,
          gs1CompanyPrefixController: gs1CompanyPrefixController,
          locationReferenceDigitsController: locationReferenceDigitsController,
          checkDigitController: checkDigitController,
          parentGlnCodeController: parentGlnCodeController,
          glnExtensionComponentController: glnExtensionComponentController,
          registeredLegalNameController: registeredLegalNameController,
          tradingNameController: tradingNameController,
          leiCodeController: leiCodeController,
          taxRegistrationNumberController: taxRegistrationNumberController,
          countryOfIncorporationNumericController:
              countryOfIncorporationNumericController,
          websiteController: websiteController,
          locationNameController: locationNameController,
          mobileLocationIdentifierController: mobileLocationIdentifierController,
          addressLine1Controller: addressLine1Controller,
          addressLine2Controller: addressLine2Controller,
          cityController: cityController,
          stateProvinceController: stateProvinceController,
          postalCodeController: postalCodeController,
          countryController: countryController,
          digitalAddressValueController: digitalAddressValueController,
          contactNameController: contactNameController,
          contactEmailController: contactEmailController,
          contactPhoneController: contactPhoneController,
          supplyChainRolesController: supplyChainRolesController,
          locationRolesController: locationRolesController,
          licenseNumberController: licenseNumberController,
          licenseTypeController: licenseTypeController,
          operatingStatus: _operatingStatus,
          industryClassification: _industryClassification,
          glnSource: _glnSource,
          mobility: _mobility,
          digitalAddressType: _digitalAddressType,
          locationTypeLabel: _locationTypeLabel,
          glnTypes: _glnTypes,
          glnTypesErrorText: _glnTypesErrorText,
          licenseValidFrom: _licenseValidFrom,
          licenseExpiry: _licenseExpiry,
          effectiveFrom: _effectiveFrom,
          effectiveTo: _effectiveTo,
          nonReuseUntil: _nonReuseUntil,
          displayCoordinates: _coordinates,
          pharmaExtensionKey: _pharmaExtensionKey,
          tobaccoExtensionKey: _tobaccoExtensionKey,
          onOperatingStatusChanged: (v) {
            if (v != null) setState(() => _operatingStatus = v);
          },
          onPickEffectiveFrom: () => _pickDate(
            (d) => setState(() => _effectiveFrom = d),
            _effectiveFrom,
          ),
          onPickEffectiveTo: () => _pickDate(
            (d) => setState(() => _effectiveTo = d),
            _effectiveTo,
          ),
          onGlnTypesChanged: (next) {
            setState(() {
              _glnTypes = next;
              _glnTypesErrorText = null;
            });
          },
          onIndustryClassificationChanged: (v) {
            if (v != null) setState(() => _industryClassification = v);
          },
          onGlnSourceChanged: (v) {
            if (v != null) setState(() => _glnSource = v);
          },
          onMobilityChanged: (v) {
            if (v != null) setState(() => _mobility = v);
          },
          onDigitalAddressTypeChanged: (v) {
            if (v != null) setState(() => _digitalAddressType = v);
          },
          onLocationTypeChanged: (v) {
            if (v != null) setState(() => _locationTypeLabel = v);
          },
          onPickLicenseValidFrom: () => _pickDate(
            (d) => setState(() => _licenseValidFrom = d),
            _licenseValidFrom,
          ),
          onPickLicenseExpiry: () => _pickDate(
            (d) => setState(() => _licenseExpiry = d),
            _licenseExpiry,
          ),
          onCoordinatesChanged: (c) {
            setState(() => _coordinates = c);
          },
        );
      },
    );

    final scaffold = Gs1MasterDataDetailScaffold(
      embedded: widget.embedded,
      title: widget.isEditing
          ? (widget.glnId != null
                ? GlnUiConstants.detailTitleEdit
                : GlnUiConstants.detailTitleCreate)
          : GlnUiConstants.detailTitleView,
      showSaveAction: allowMasterDataActions,
      onSave: () {
        _submitForm();
      },
      body: body,
    );

    if (widget.embedded) {
      return scaffold;
    }
    final cubit = _glnCubit;
    if (cubit == null) {
      return scaffold;
    }
    return BlocProvider<GLNCubit>.value(value: cubit, child: scaffold);
  }
}
