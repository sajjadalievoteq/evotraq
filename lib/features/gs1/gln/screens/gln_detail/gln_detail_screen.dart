import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_awaiting_selection_pane.dart';
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
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_body.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_skeleton.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_screen_fields.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/utils/gln_location_type_mapper.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';

part 'gln_detail_actions.dart';

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
    with GlnDetailScreenFields {
  final _formKey = GlobalKey<FormState>();
  final _pharmaExtensionKey =
      GlobalKey<GLNPharmaceuticalExtensionWidgetState>();
  late final ValidationCubit _validationCubit;

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

  void _setFieldError(String fieldName, String? error) {
    if (_validationCubit.getFieldError(fieldName) == error) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _validationCubit.setFieldError(fieldName, error);
    });
  }

  @override
  void initState() {
    super.initState();
    _validationCubit = ValidationCubit();
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
    _validationCubit.close();
    super.dispose();
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
      if (widget.embedded) {
        return BlocBuilder<GLNCubit, GLNState>(
          builder: (context, state) => GlnAwaitingSelectionPane(state: state),
        );
      }
      final cubit = _glnCubit;
      if (cubit == null) {
        return Scaffold(
          body: GlnAwaitingSelectionPane(state: const GLNState()),
        );
      }
      return BlocProvider<GLNCubit>.value(
        value: cubit,
        child: BlocBuilder<GLNCubit, GLNState>(
          builder: (context, state) =>
              Scaffold(body: GlnAwaitingSelectionPane(state: state)),
        ),
      );
    }

    final auth = context.watch<AuthCubit>().state;
    final canEditMasterData = auth.isAdmin || auth.isManufacturer;
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
          setFieldError: _setFieldError,
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
          mobileLocationIdentifierController:
              mobileLocationIdentifierController,
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
          onOperatingStatusChanged: (v) {
            if (v != null) setState(() => _operatingStatus = v);
          },
          onPickEffectiveFrom: () => _pickDate(
            (d) => setState(() => _effectiveFrom = d),
            _effectiveFrom,
          ),
          onPickEffectiveTo: () =>
              _pickDate((d) => setState(() => _effectiveTo = d), _effectiveTo),
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

    Widget result = scaffold;
    if (!widget.embedded) {
      final cubit = _glnCubit;
      if (cubit != null) {
        result = BlocProvider<GLNCubit>.value(value: cubit, child: scaffold);
      }
    }
    return BlocProvider<ValidationCubit>.value(
      value: _validationCubit,
      child: result,
    );
  }
}
