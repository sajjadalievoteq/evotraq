import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/data/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/gtin_detail_screen_fields.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/regulatory_authority/regulatory_authority_extension.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_detail_form_body.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_detail_form_skeleton.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';

class GTINDetailScreen extends StatefulWidget {
  final String? gtinCode;
  final bool isEditing;
  final GTIN? gtin;
  final bool embedded;

  final VoidCallback? onEmbeddedActionSuccess;

  final bool awaitingListSelection;

  const GTINDetailScreen({
    super.key,
    this.gtinCode,
    required this.isEditing,
    this.gtin,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
    this.awaitingListSelection = false,
  });

  @override
  State<GTINDetailScreen> createState() => _GTINDetailScreenState();
}

class _GTINDetailScreenState extends State<GTINDetailScreen>
    with GtinDetailScreenFields {
  final _formKey = GlobalKey<FormState>();
  final _tobaccoExtensionKey = GlobalKey<TobaccoExtensionWidgetState>();
  final _pharmaExtensionKey = GlobalKey<PharmaceuticalExtensionWidgetState>();
  final _regulatoryAuthorityKey =
      GlobalKey<RegulatoryAuthorityExtensionState>();
  bool _isSubmitting = false;

  GTINCubit? _gtinCubit;
  bool _gtinInitialLoadStarted = false;

  bool _formFieldsHydrated = true;

  bool _detailHydratedForRouteGtin = false;
  bool _forceMountAllSections = false;

  String? _docUnitDescriptorFromBackend({
    required String? unitDescriptor,
    required String? packagingLevel,
  }) {
    final u = (unitDescriptor ?? '').trim();
    if (u.isNotEmpty) return u;

    final p = (packagingLevel ?? '').trim().toUpperCase();
    return switch (p) {
      'ITEM' => 'BASE_UNIT_OR_EACH',
      'PACK' => 'PACK_OR_INNER_PACK',
      'CASE' => 'CASE',
      'PALLET' => 'PALLET',
      _ => null,
    };
  }

  @override
  void initState() {
    super.initState();
    initGtinDetailFields(isUpdate: widget.gtinCode != null);
    if (!widget.embedded) {
      _gtinCubit = getIt<GTINCubit>();
    }
    _formFieldsHydrated =
        widget.gtinCode == null &&
        widget.gtin == null &&
        !widget.awaitingListSelection;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.embedded) {
      _gtinCubit = context.read<GTINCubit>();
    }
    if (!_gtinInitialLoadStarted) {
      _gtinInitialLoadStarted = true;
      if (widget.awaitingListSelection) {
        return;
      }
      final cubit = _gtinCubit;
      if (cubit == null) {
        return;
      }
      if (widget.gtinCode != null) {
        cubit.fetchGTINDetails(widget.gtinCode!);
      } else if (widget.gtin != null) {
        _detailHydratedForRouteGtin = true;
        _initializeFormWithGTIN(widget.gtin!);
      }
    }
  }

  @override
  void didUpdateWidget(covariant GTINDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCode = oldWidget.gtinCode;
    final newCode = widget.gtinCode;
    if (oldCode != newCode && newCode != null) {
      setState(() {
        _detailHydratedForRouteGtin = false;
        _formFieldsHydrated = false;
      });
      _gtinCubit?.fetchGTINDetails(newCode);
    }
  }

  void _initializeFormWithGTIN(GTIN gtin) {
    if (kDebugMode) {
      debugPrint('Initializing form with GTIN: ${gtin.gtinCode}');
      debugPrint(
        'GTIN dates: registrationDate=${gtin.registrationDate}, expirationDate=${gtin.expirationDate}',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final unitDescriptor = _docUnitDescriptorFromBackend(
          unitDescriptor: gtin.unitDescriptor,
          packagingLevel: gtin.packagingLevel,
        );
        hydrateGtinDetailFields(gtin, docUnitDescriptor: unitDescriptor);
        if (kDebugMode) {
          debugPrint(
            '[GTIN perf] allocated controllers after hydrate: '
            '$allocatedGtinControllerCount',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _formFieldsHydrated = true);
        }
      }
    });
  }

  @override
  void dispose() {
    if (!widget.embedded) {
      _gtinCubit?.close();
    }
    disposeGtinDetailFields();
    super.dispose();
  }

  Future<void> _refreshGtin() async {
    if (widget.gtinCode != null) {
      (_gtinCubit ?? context.read<GTINCubit>()).fetchGTINDetails(widget.gtinCode!);
    }
  }

  Future<void> _pickDateOnly({
    required DateTime? current,
    required void Function(DateTime picked) onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 30),
    );
    if (picked == null || !mounted) return;
    onPicked(DateTime(picked.year, picked.month, picked.day));
    setState(() {});
  }

  Future<void> _pickDateTime({
    required DateTime? current,
    required void Function(DateTime picked) onPicked,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 30),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? now),
    );
    if (time == null || !mounted) return;
    onPicked(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
    setState(() {});
  }

  Future<void> _submitForm() async {
    // Ensure every section is mounted so Form validators + extension keys run.
    if (!_forceMountAllSections) {
      setState(() => _forceMountAllSections = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (kTobaccoExtensionEnabled) {
      final tobaccoValidation = _tobaccoExtensionKey.currentState?.validate();
      if (tobaccoValidation != null) {
        context.showError(tobaccoValidation);
        return;
      }
    }

    final pharmaValidation = _pharmaExtensionKey.currentState?.validate();
    if (pharmaValidation != null) {
      context.showError(pharmaValidation);
      return;
    }

    final regulatoryAuthorityState = _regulatoryAuthorityKey.currentState;
    final pharmaState = _pharmaExtensionKey.currentState;
    if (regulatoryAuthorityState != null &&
        pharmaState != null &&
        regulatoryAuthorityState.hasData) {
      pharmaState.applyRegulatoryAuthorityValues(
        localDrugCode: regulatoryAuthorityState.localDrugCode,
        marketingAuthorizationNumber:
            regulatoryAuthorityState.marketingAuthorizationNumber,
        licensedAgentGlns: regulatoryAuthorityState.licensedAgentGlns,
        regulatedProductName: regulatoryAuthorityState.regulatedProductName,
      );
    }

    if (!isFormValid) return;

    final role = context.read<AuthCubit>().state.user?.role;
    final fieldError = validateGtinFieldsForSave(
      isReadOnly: !(role == 'ADMIN' || role == 'MANUFACTURER'),
    );
    if (fieldError != null) {
      context.showError(fieldError);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final gtinCodeForApi = GtinFieldValidators.canonicalGtin14FromInput(
      gtinCodeController.text,
    );

    final gtin = buildGtinFromFields(gtinCode: gtinCodeForApi);

    final cubit = _gtinCubit;
    if (cubit == null) {
      setState(() => _isSubmitting = false);
      return;
    }
    if (widget.gtinCode != null) {
      cubit.updateGTIN(gtin);
    } else {
      cubit.createGTIN(gtin);
    }
  }

  Future<void> _saveTobaccoExtensionIfNeeded(
    int? gtinId,
    String gtinCode,
  ) async {
    if (!kTobaccoExtensionEnabled) return;
    final tobaccoState = _tobaccoExtensionKey.currentState;
    if (tobaccoState == null || !tobaccoState.hasData) {
      return;
    }

    try {
      final extension = tobaccoState.buildExtension(
        gtinId: gtinId,
        gtinCode: gtinCode,
      );
      if (extension != null) {
        final tobaccoService = getIt<GTINTobaccoExtensionService>();
        await tobaccoService.createByGtinCode(gtinCode, extension);
        debugPrint('Tobacco extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving tobacco extension: $e');
    }
  }

  Future<void> _savePharmaExtensionIfNeeded(
    int? gtinId,
    String gtinCode,
  ) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    if (pharmaState == null || !pharmaState.hasData) {
      return;
    }

    try {
      final regulatoryAuthorityState = _regulatoryAuthorityKey.currentState;
      if (regulatoryAuthorityState != null &&
          regulatoryAuthorityState.hasData) {
        pharmaState.applyRegulatoryAuthorityValues(
          localDrugCode: regulatoryAuthorityState.localDrugCode,
          marketingAuthorizationNumber:
              regulatoryAuthorityState.marketingAuthorizationNumber,
          licensedAgentGlns: regulatoryAuthorityState.licensedAgentGlns,
          regulatedProductName: regulatoryAuthorityState.regulatedProductName,
        );
      }
      final extension = pharmaState.buildExtension(
        gtinId: gtinId,
        gtinCode: gtinCode,
      );
      if (extension != null) {
        final pharmaService = getIt<PharmaceuticalService>();
        await pharmaService.createExtension(gtinCode, extension);
        debugPrint('Pharmaceutical extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving pharmaceutical extension: $e');
    }
  }

  bool _fieldSkeletonsActive(GTINState state) {
    if (state.status == GTINStatus.error) return false;
    return !_formFieldsHydrated;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      Widget pane(GTINState state) {
        final listLoading =
            state.isGtinListLoading || state.status == GTINStatus.initial;
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
              skeleton: const GtinDetailFormSkeleton(),
            ),
          );
        }
        return AppEmptyDetail(
          title: GtinUiConstants.awaitingSelectionTitle,
          subtitle: GtinUiConstants.awaitingSelectionSubtitle,
          iconAsset: NavIcons.gtin,
        );
      }

      if (widget.embedded) {
        return BlocBuilder<GTINCubit, GTINState>(
          builder: (context, state) => pane(state),
        );
      }
      final cubit = _gtinCubit;
      if (cubit == null) {
        return Scaffold(body: pane(const GTINState()));
      }
      return BlocProvider<GTINCubit>.value(
        value: cubit,
        child: BlocBuilder<GTINCubit, GTINState>(
          builder: (context, state) => Scaffold(body: pane(state)),
        ),
      );
    }

    final role = context.watch<AuthCubit>().state.user?.role;
    final canEditMasterData = role == 'ADMIN' || role == 'MANUFACTURER';
    final allowMasterDataActions =
        canEditMasterData && !widget.awaitingListSelection;
    final formFieldsReadOnly = !canEditMasterData;
    final screenTitle = !widget.isEditing && widget.gtinCode != null
        ? GtinUiConstants.detailTitleView
        : widget.gtinCode != null
        ? GtinUiConstants.detailTitleEdit
        : GtinUiConstants.detailTitleCreate;

    final body = BlocConsumer<GTINCubit, GTINState>(
      listener: (context, state) {
        if (state.status == GTINStatus.error) {
          setState(() {
            _isSubmitting = false;
            _formFieldsHydrated = true;
          });
          debugPrint(
            '[GTIN UI] detail error (snackbar): ${state.error} '
            'routeGtinParam=${widget.gtinCode ?? "(new)"}',
          );
          context.showError(state.error ?? '');
        }

        if (state.status == GTINStatus.success) {
          if (_isSubmitting) {
            setState(() {
              _isSubmitting = false;
            });

            final createdGtin = state.gtin;
            final gtinCode = createdGtin?.gtinCode ?? gtinCodeController.text;

            _saveTobaccoExtensionIfNeeded(null, gtinCode);
            _savePharmaExtensionIfNeeded(null, gtinCode);

            context.showSuccess(
              widget.gtinCode != null
                  ? GtinUiConstants.successGtinUpdated(gtinCode)
                  : GtinUiConstants.successGtinCreated(gtinCode),
            );

            if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else if (context.mounted) {
              context.go('${Constants.gs1GtinsRoute}/$gtinCode');
            }
          } else if (widget.gtinCode != null &&
              state.gtin != null &&
              state.gtin!.gtinCode == widget.gtinCode &&
              !_detailHydratedForRouteGtin) {
            _initializeFormWithGTIN(state.gtin!);
            _detailHydratedForRouteGtin = true;
          }
        }
      },
      builder: (context, state) {
        final sk = _fieldSkeletonsActive(state);
        final idStructureReadOnly =
            !canEditMasterData || widget.gtinCode != null || sk;
        final gtinFieldLocked =
            widget.gtinCode != null || !canEditMasterData || sk;
        return GtinDetailFormBody(
          formKey: _formKey,
          fields: this,
          onFieldsChanged: () => setState(() {}),
          routeGtinCode: widget.gtinCode,
          routeGtin: widget.gtin,
          state: state,
          gtin:
              widget.gtin ??
              GTIN(
                gtinCode: widget.gtinCode ?? '',
                productName: state.gtin?.productName ?? '',
                manufacturer: state.gtin?.manufacturer ?? '',
              ),
          allowMasterDataActions: allowMasterDataActions,
          formFieldsReadOnly: formFieldsReadOnly,
          idStructureReadOnly: idStructureReadOnly,
          gtinFieldLocked: gtinFieldLocked,
          fullFormShimmer: sk,
          forceMountAllSections: _forceMountAllSections,
          isSubmitting: _isSubmitting,
          onSubmit: () {
            _submitForm();
          },
          tobaccoExtensionKey: _tobaccoExtensionKey,
          pharmaExtensionKey: _pharmaExtensionKey,
          regulatoryAuthorityKey: _regulatoryAuthorityKey,
          onPickRegistrationDate: () => _pickDateOnly(
            current: registrationDate,
            onPicked: (d) {
              registrationDate = d;
              registrationDateDisplayController.text = formatDate(d);
            },
          ),
          onPickExpirationDate: () => _pickDateOnly(
            current: expirationDate,
            onPicked: (d) {
              expirationDate = d;
              expirationDateDisplayController.text = formatDate(d);
            },
          ),
          onPickLaunchDate: () => _pickDateOnly(
            current: launchDate,
            onPicked: (d) {
              launchDate = d;
              launchDateDisplayController.text = formatDate(d);
            },
          ),
          onPickEffectiveDate: () => _pickDateTime(
            current: effectiveDate,
            onPicked: (d) {
              effectiveDate = d;
              effectiveDateDisplayController.text =
                  formatDateTimeWithOffset(d);
            },
          ),
          onPickStartAvailDate: () => _pickDateTime(
            current: startAvailDate,
            onPicked: (d) {
              startAvailDate = d;
              startAvailDateDisplayController.text =
                  formatDateTimeWithOffset(d);
            },
          ),
          onPickEndAvailDate: () => _pickDateTime(
            current: endAvailDate,
            onPicked: (d) {
              endAvailDate = d;
              endAvailDateDisplayController.text =
                  formatDateTimeWithOffset(d);
            },
          ),
          onPickPublicationDate: () => _pickDateOnly(
            current: publicationDate,
            onPicked: (d) {
              publicationDate = d;
              publicationDateDisplayController.text = formatDate(d);
            },
          ),
        );
      },
    );

    final bodyWithRefresh = RefreshIndicator(onRefresh: _refreshGtin, child: body);

    final scaffold = Gs1MasterDataDetailScaffold(
      embedded: widget.embedded,
      title: screenTitle,
      showSaveAction: allowMasterDataActions,
      onSave: () {
        _submitForm();
      },
      saveEnabled: allowMasterDataActions && !_isSubmitting,
      body: bodyWithRefresh,
    );

    if (widget.embedded) {
      return scaffold;
    }
    final cubit = _gtinCubit;
    if (cubit == null) {
      return scaffold;
    }
    return BlocProvider<GTINCubit>.value(value: cubit, child: scaffold);
  }
}
