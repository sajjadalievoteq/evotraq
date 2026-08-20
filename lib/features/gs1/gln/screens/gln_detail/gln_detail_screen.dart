import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_awaiting_selection_pane.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_body.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_screen_fields.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';

import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_actions.dart';

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
  State<GLNDetailScreen> createState() => GLNDetailScreenState();
}

class GLNDetailScreenState extends State<GLNDetailScreen>
    with GlnDetailScreenFields {
  final formKey = GlobalKey<FormState>();
  final pharmaExtensionKey =
      GlobalKey<GLNPharmaceuticalExtensionWidgetState>();
  late final ValidationCubit validationCubit;

  String operatingStatus = 'ACTIVE';
  String industryClassification = 'HEALTHCARE';
  String glnSource = 'SELF_ALLOCATED';
  String mobility = 'FIXED';
  String digitalAddressType = 'URL';
  String locationTypeLabel = 'Other';
  List<String> glnTypes = ['FIXED_PHYSICAL'];
  String? glnTypesErrorText;

  String? hydratedTag;

  DateTime? licenseValidFrom;
  DateTime? licenseExpiry;
  DateTime? effectiveFrom;
  DateTime? effectiveTo;
  DateTime? nonReuseUntil;

  bool hasSubmittedForm = false;
  GeospatialCoordinates? coordinates;
  bool forceMountAllSections = false;

  GLNCubit? glnCubit;
  bool _glnInitialLoadStarted = false;

  bool formFieldsHydrated = true;

  void _setFieldError(String fieldName, String? error) {
    if (validationCubit.getFieldError(fieldName) == error) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      validationCubit.setFieldError(fieldName, error);
    });
  }

  @override
  void initState() {
    super.initState();
    validationCubit = ValidationCubit();
    formFieldsHydrated = widget.glnId == null && !widget.awaitingListSelection;

    if (!widget.embedded) {
      glnCubit = GLNCubit(glnService: getIt<GLNService>());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.embedded) {
      glnCubit = context.read<GLNCubit>();
    }
    if (!_glnInitialLoadStarted) {
      _glnInitialLoadStarted = true;
      if (widget.awaitingListSelection) {
        return;
      }
      final cubit = glnCubit;
      if (cubit == null) {
        return;
      }
      cubit.clearSelection();
      if (widget.glnId != null) {
        cubit.fetchGLNById(widget.glnId!);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          maybeHydrateFromGln(null);
        });
      }
    }
  }

  @override
  void dispose() {
    disposeGlnDetailFields();
    if (widget.embedded) {
      glnCubit?.clearSelection();
    } else {
      glnCubit?.close();
    }
    validationCubit.close();
    super.dispose();
  }

  String? nonEmptyOrNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  bool _fieldSkeletonsActive(GLNState state) {
    if (state.status == GLNStatus.error) return false;
    return !formFieldsHydrated;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      if (widget.embedded) {
        return BlocBuilder<GLNCubit, GLNState>(
          builder: (context, state) => GlnAwaitingSelectionPane(state: state),
        );
      }
      final cubit = glnCubit;
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
            setState(() => formFieldsHydrated = true);
            context.showError(state.error ?? GlnUiConstants.errorGeneric);
            return;
          }
          if (state.status == GLNStatus.success && hasSubmittedForm) {
            setState(() => hasSubmittedForm = false);

            context.showSuccess(GlnUiConstants.successGlnSaved);

            if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else if (context.mounted) {
              final code = state.selectedGLN?.glnCode ?? widget.glnId;
              if (code != null && code.isNotEmpty) {
                context.push(GlnRouteConstants.pathForGlnCode(code));
              } else {
                context.go(Constants.gs1GlnsRoute);
              }
            }
            return;
          }
          if (state.status == GLNStatus.success &&
              state.selectedGLN != null &&
              widget.glnId != null) {
            maybeHydrateFromGln(state.selectedGLN);
          }
        });
      },
      builder: (context, state) {
        final gln = widget.glnId != null ? state.selectedGLN : null;
        final sk = _fieldSkeletonsActive(state);

        final idStructureReadOnly =
            !canEditMasterData || widget.glnId != null || sk;

        return GlnDetailFormBody(
          formKey: formKey,
          onRefresh: refresh,
          showSkeleton: sk,
          forceMountAllSections: forceMountAllSections,
          gln: gln,
          idStructureReadOnly: idStructureReadOnly,
          canEditMasterData: canEditMasterData,
          formReadOnly: formReadOnly,
          allowMasterDataActions: allowMasterDataActions,
          embedded: widget.embedded,
          onSubmit: () {
            submitForm();
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
          operatingStatus: operatingStatus,
          industryClassification: industryClassification,
          glnSource: glnSource,
          mobility: mobility,
          digitalAddressType: digitalAddressType,
          locationTypeLabel: locationTypeLabel,
          glnTypes: glnTypes,
          glnTypesErrorText: glnTypesErrorText,
          licenseValidFrom: licenseValidFrom,
          licenseExpiry: licenseExpiry,
          effectiveFrom: effectiveFrom,
          effectiveTo: effectiveTo,
          nonReuseUntil: nonReuseUntil,
          displayCoordinates: coordinates,
          pharmaExtensionKey: pharmaExtensionKey,
          onOperatingStatusChanged: (v) {
            if (v != null) setState(() => operatingStatus = v);
          },
          onPickEffectiveFrom: () => pickDate(
            (d) => setState(() => effectiveFrom = d),
            effectiveFrom,
          ),
          onPickEffectiveTo: () =>
              pickDate((d) => setState(() => effectiveTo = d), effectiveTo),
          onGlnTypesChanged: (next) {
            setState(() {
              glnTypes = next;
              glnTypesErrorText = null;
            });
          },
          onIndustryClassificationChanged: (v) {
            if (v != null) setState(() => industryClassification = v);
          },
          onGlnSourceChanged: (v) {
            if (v != null) setState(() => glnSource = v);
          },
          onMobilityChanged: (v) {
            if (v != null) setState(() => mobility = v);
          },
          onDigitalAddressTypeChanged: (v) {
            if (v != null) setState(() => digitalAddressType = v);
          },
          onLocationTypeChanged: (v) {
            if (v != null) setState(() => locationTypeLabel = v);
          },
          onPickLicenseValidFrom: () => pickDate(
            (d) => setState(() => licenseValidFrom = d),
            licenseValidFrom,
          ),
          onPickLicenseExpiry: () => pickDate(
            (d) => setState(() => licenseExpiry = d),
            licenseExpiry,
          ),
          onCoordinatesChanged: (c) {
            setState(() => coordinates = c);
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
        submitForm();
      },
      body: body,
    );

    Widget result = scaffold;
    if (!widget.embedded) {
      final cubit = glnCubit;
      if (cubit != null) {
        result = BlocProvider<GLNCubit>.value(value: cubit, child: scaffold);
      }
    }
    return BlocProvider<ValidationCubit>.value(
      value: validationCubit,
      child: result,
    );
  }
}
