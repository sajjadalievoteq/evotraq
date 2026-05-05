import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/data/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_form.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_industry_extensions_section.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/regulatory_authority/regulatory_authority_extension.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/audit_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/classification_market_origin_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/gtin_identification_structure_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/information_provider_manufacturer_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/lifecycle_availability_status_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/marketing_authorization_bound_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/net_content_measurements_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/packaging_hierarchy_trade_item_roles_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/production_batch_serial_date_associations_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/trade_item_masterdata_bound_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/core_groups/trade_item_descriptive_attributes_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

class GTINDetailScreen extends StatefulWidget {
  final String? gtinCode;
  final bool isEditing;
  final GTIN? gtin;
  final bool embedded;

  /// When [embedded] is true, invoked after a successful create/update instead of [Navigator.pop].
  final VoidCallback? onEmbeddedActionSuccess;

  /// Split view: list not ready yet — show the real form with field skeletons; no fetch until [gtinCode] is set.
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

class _GTINDetailScreenState extends State<GTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tobaccoExtensionKey = GlobalKey<TobaccoExtensionWidgetState>();
  final _pharmaExtensionKey = GlobalKey<PharmaceuticalExtensionWidgetState>();
  final _regulatoryAuthorityKey = GlobalKey<RegulatoryAuthorityExtensionState>();
  final _boundMasterdataKey = GlobalKey<TradeItemMasterdataBoundGroupState>();
  final _boundMarketingAuthKey =
      GlobalKey<MarketingAuthorizationBoundGroupState>();
  final _descriptiveAttrsKey =
      GlobalKey<TradeItemDescriptiveAttributesCoreGroupState>();
  final _packagingHierarchyKey =
      GlobalKey<PackagingHierarchyTradeItemRolesCoreGroupState>();
  final _netContentKey = GlobalKey<NetContentMeasurementsCoreGroupState>();
  final _classificationKey =
      GlobalKey<ClassificationMarketOriginCoreGroupState>();
  final _infoProviderKey =
      GlobalKey<InformationProviderManufacturerCoreGroupState>();
  final _lifecycleKey = GlobalKey<LifecycleAvailabilityStatusCoreGroupState>();
  final _batchSerialKey =
      GlobalKey<ProductionBatchSerialDateAssociationsCoreGroupState>();
  final _auditKey = GlobalKey<AuditCoreGroupState>();
  bool _isSubmitting = false;

  /// Cached in [didChangeDependencies] for parity with GLN detail lifecycle.
  GTINCubit? _gtinCubit;
  bool _gtinInitialLoadStarted = false;

  /// After fetch / hydration, child groups show real values; until then field skeletons (same rule as GLN detail).
  bool _formFieldsHydrated = true;

  /// Avoid re-applying [GTIN] from cubit on every unrelated success emission.
  bool _detailHydratedForRouteGtin = false;

  final _gtinCodeController = TextEditingController();
  String? _status = 'ACTIVE';

  String? _docUnitDescriptorFromBackend({
    required String? unitDescriptor,
    required String? packagingLevel,
  }) {
    final u = (unitDescriptor ?? '').trim();
    if (u.isNotEmpty) return u;

    // Backward compatibility for older rows that only had backend enum `packagingLevel`.
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
    if (!widget.embedded) {
      _gtinCubit = getIt<GTINCubit>();
    }
    _formFieldsHydrated = widget.gtinCode == null &&
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
      _gtinCodeController.text = gtin.gtinCode;
      _status = gtin.status?.toUpperCase();

      try {
        final unitDescriptor = _docUnitDescriptorFromBackend(
          unitDescriptor: gtin.unitDescriptor,
          packagingLevel: gtin.packagingLevel,
        );

        _boundMasterdataKey.currentState?.setFromGtin(
          brandName: gtin.productName,
          manufacturer: gtin.manufacturer ?? '',
          unitDescriptor: unitDescriptor ?? '',
          status: gtin.status?.toUpperCase(),
          packSize: gtin.packSize?.toString() ?? '',
        );

        _boundMarketingAuthKey.currentState?.setFromGtin(
          number: gtin.registrationNumber ?? '',
          validFrom: gtin.registrationDate,
          validTo: gtin.expirationDate,
        );

        _descriptiveAttrsKey.currentState?.setFromGtin(
          functionalName: gtin.functionalName,
          tradeItemDescription: gtin.tradeItemDescription,
          gpcBrickCode: gtin.gpcBrickCode,
          targetMarketCountry: gtin.targetMarketCountry,
        );

        _packagingHierarchyKey.currentState?.setFromGtin(
          nextLowerLevelGtin: gtin.nextLowerLevelGtin,
          nextLowerLevelQuantity: gtin.nextLowerLevelQuantity,
          quantityOfChildren: gtin.quantityOfChildren,
          totalQtyNextLower: gtin.totalQtyNextLower,
          launchDate: gtin.launchDate,
          isBaseUnit: gtin.isBaseUnit,
          isConsumerUnit: gtin.isConsumerUnit,
          isOrderableUnit: gtin.isOrderableUnit,
          isDespatchUnit: gtin.isDespatchUnit,
          isInvoiceUnit: gtin.isInvoiceUnit,
          isVariableUnit: gtin.isVariableUnit,
        );

        _netContentKey.currentState?.setFromGtin(
          netContentValue: gtin.netContentValue,
          netContentUom: gtin.netContentUom,
          grossWeightValue: gtin.grossWeightValue,
          grossWeightUom: gtin.grossWeightUom,
          heightValue: gtin.heightValue,
          widthValue: gtin.widthValue,
          depthValue: gtin.depthValue,
          dimUom: gtin.dimUom,
        );

        _classificationKey.currentState?.setFromGtin(
          countryOfOrigin: gtin.countryOfOrigin,
        );

        _infoProviderKey.currentState?.setFromGtin(
          informationProviderGln: gtin.informationProviderGln,
          informationProviderName: gtin.informationProviderName,
          manufacturerGln: gtin.manufacturerGln,
        );

        _lifecycleKey.currentState?.setFromGtin(
          tradeItemStatus: gtin.tradeItemStatus,
          effectiveDate: gtin.effectiveDate,
          startAvailDate: gtin.startAvailDate,
          endAvailDate: gtin.endAvailDate,
          publicationDate: gtin.publicationDate,
        );

        _batchSerialKey.currentState?.setFromGtin(
          hasBatchNumberIndicator: gtin.hasBatchNumberIndicator,
          hasSerialNumberIndicator: gtin.hasSerialNumberIndicator,
        );

        _auditKey.currentState?.setFromGtin(
          createdBy: gtin.createdBy,
          updatedBy: gtin.updatedBy,
        );
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
    _gtinCodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
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
    if (regulatoryAuthorityState != null && pharmaState != null && regulatoryAuthorityState.hasData) {
      pharmaState.applyRegulatoryAuthorityValues(
        localDrugCode: regulatoryAuthorityState.localDrugCode,
        marketingAuthorizationNumber: regulatoryAuthorityState.marketingAuthorizationNumber,
        licensedAgentGlns: regulatoryAuthorityState.licensedAgentGlns,
        regulatedProductName: regulatoryAuthorityState.regulatedProductName,
      );
    }

    if (isFormValid) {
      setState(() {
        _isSubmitting = true;
      });

      final gtinCodeForApi =
          GtinFieldValidators.canonicalGtin14FromInput(_gtinCodeController.text);

      final boundMasterdata = _boundMasterdataKey.currentState;
      final boundMarketingAuth = _boundMarketingAuthKey.currentState;
      final descriptive = _descriptiveAttrsKey.currentState;
      final packagingHierarchy = _packagingHierarchyKey.currentState;
      final netContent = _netContentKey.currentState;
      final classification = _classificationKey.currentState;
      final infoProvider = _infoProviderKey.currentState;
      final lifecycle = _lifecycleKey.currentState;
      final batchSerial = _batchSerialKey.currentState;
      final audit = _auditKey.currentState;

      if (boundMasterdata == null ||
          boundMarketingAuth == null ||
          descriptive == null ||
          packagingHierarchy == null ||
          netContent == null ||
          classification == null ||
          infoProvider == null ||
          lifecycle == null ||
          batchSerial == null ||
          audit == null) {
        setState(() {
          _isSubmitting = false;
        });
        context.showError('Internal form error: required sections not mounted.');
        return;
      }

      final gtin = GTIN(
        gtinCode: gtinCodeForApi,
        productName: boundMasterdata.brandName,
        manufacturer: boundMasterdata.manufacturer.trim(),
        // Doc field (dropdown).
        unitDescriptor: boundMasterdata.unitDescriptor.isEmpty
            ? null
            : boundMasterdata.unitDescriptor.trim(),
        // Backend enum for now (subset mapping).
        packagingLevel: boundMasterdata.unitDescriptor.isEmpty
            ? null
            : GtinFieldValidators.mapUnitDescriptorToBackendPackagingLevel(
                boundMasterdata.unitDescriptor,
              ),
        packSize: boundMasterdata.packSize,
        status: boundMasterdata.status,
        registrationNumber:
            boundMarketingAuth.number.isEmpty ? null : boundMarketingAuth.number,
        registrationDate: boundMarketingAuth.validFrom,
        expirationDate: boundMarketingAuth.validTo,

        // Core spec fields (Groups 2–9) collected from modular widgets
        functionalName: descriptive.functionalName,
        tradeItemDescription: descriptive.tradeItemDescription,
        gpcBrickCode: descriptive.gpcBrickCode,
        targetMarketCountry: descriptive.targetMarketCountry,

        nextLowerLevelGtin: packagingHierarchy.nextLowerLevelGtin,
        nextLowerLevelQuantity: packagingHierarchy.nextLowerLevelQuantity,
        quantityOfChildren: packagingHierarchy.quantityOfChildren,
        totalQtyNextLower: packagingHierarchy.totalQtyNextLower,
        launchDate: packagingHierarchy.launchDate,
        isBaseUnit: packagingHierarchy.isBaseUnit,
        isConsumerUnit: packagingHierarchy.isConsumerUnit,
        isOrderableUnit: packagingHierarchy.isOrderableUnit,
        isDespatchUnit: packagingHierarchy.isDespatchUnit,
        isInvoiceUnit: packagingHierarchy.isInvoiceUnit,
        isVariableUnit: packagingHierarchy.isVariableUnit,

        netContentValue: netContent.netContentValue,
        netContentUom: netContent.netContentUom,
        grossWeightValue: netContent.grossWeightValue,
        grossWeightUom: netContent.grossWeightUom,
        heightValue: netContent.heightValue,
        widthValue: netContent.widthValue,
        depthValue: netContent.depthValue,
        dimUom: netContent.dimUom,

        countryOfOrigin: classification.countryOfOrigin,

        informationProviderGln: infoProvider.informationProviderGln,
        informationProviderName: infoProvider.informationProviderName,
        manufacturerGln: infoProvider.manufacturerGln,

        tradeItemStatus: lifecycle.tradeItemStatus,
        effectiveDate: lifecycle.effectiveDate,
        startAvailDate: lifecycle.startAvailDate,
        endAvailDate: lifecycle.endAvailDate,
        publicationDate: lifecycle.publicationDate,

        hasBatchNumberIndicator: batchSerial.hasBatchNumberIndicator,
        hasSerialNumberIndicator: batchSerial.hasSerialNumberIndicator,

        createdBy: audit.createdBy,
        updatedBy: audit.updatedBy,
      );

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
  }

  Future<void> _saveTobaccoExtensionIfNeeded(int? gtinId, String gtinCode) async {
    if (!kTobaccoExtensionEnabled) return;
    final tobaccoState = _tobaccoExtensionKey.currentState;
    if (tobaccoState == null || !tobaccoState.hasData) {
      return;
    }

    try {
      final extension =
          tobaccoState.buildExtension(gtinId: gtinId, gtinCode: gtinCode);
      if (extension != null) {
        final tobaccoService = getIt<GTINTobaccoExtensionService>();
        await tobaccoService.createByGtinCode(gtinCode, extension);
        debugPrint('Tobacco extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving tobacco extension: $e');
    }
  }

  Future<void> _savePharmaExtensionIfNeeded(int? gtinId, String gtinCode) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    if (pharmaState == null || !pharmaState.hasData) {
      return;
    }

    try {
      final regulatoryAuthorityState = _regulatoryAuthorityKey.currentState;
      if (regulatoryAuthorityState != null && regulatoryAuthorityState.hasData) {
        pharmaState.applyRegulatoryAuthorityValues(
          localDrugCode: regulatoryAuthorityState.localDrugCode,
          marketingAuthorizationNumber: regulatoryAuthorityState.marketingAuthorizationNumber,
          licensedAgentGlns: regulatoryAuthorityState.licensedAgentGlns,
          regulatedProductName: regulatoryAuthorityState.regulatedProductName,
        );
      }
      final extension =
          pharmaState.buildExtension(gtinId: gtinId, gtinCode: gtinCode);
      if (extension != null) {
        final pharmaService = getIt<PharmaceuticalService>();
        await pharmaService.createExtension(gtinCode, extension);
        debugPrint('Pharmaceutical extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving pharmaceutical extension: $e');
    }
  }

  /// One rule for split-view placeholder, fetch, and post-fetch hydrate: skeleton until [_formFieldsHydrated] is true.
  bool _fieldSkeletonsActive(GTINState state) {
    if (state.status == GTINStatus.error) return false;
    return !_formFieldsHydrated;
  }

  static bool _isRegulatoryAuthorityMarket(String? targetMarketCountry) {
    final raw = (targetMarketCountry ?? '').trim();
    if (raw.isEmpty) return false;
    final digits = RegExp(r'\d+').stringMatch(raw);
    return digits == '784';
  }

  Widget _buildGtinDetailForm(
    BuildContext context,
    GTINState state, {
    required bool allowMasterDataActions,
    required bool formFieldsReadOnly,
    required bool idStructureReadOnly,
    required bool gtinFieldLocked,
    required bool fullFormShimmer,
  }) {
    final deferIndustryFetch = widget.gtinCode != null &&
        (state.status == GTINStatus.loading ||
            state.status == GTINStatus.initial);
    final industryFetchResolved = !deferIndustryFetch ||
        state.status == GTINStatus.success ||
        state.status == GTINStatus.error;

    return GtinDetailForm(
      formKey: _formKey,
      gtinFieldLocked: gtinFieldLocked,
      fullFormShimmer: fullFormShimmer,
      unboundSpecSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GtinIdentificationStructureCoreGroup(
            isReadOnly: idStructureReadOnly,
            gtinCodeController: _gtinCodeController,
            gtinFieldLocked: gtinFieldLocked,
            initialGs1CompanyPrefixLength: state.gtin?.gs1CompanyPrefixLength,
            initialGs1CompanyPrefix: state.gtin?.gs1CompanyPrefix,
            initialItemReference: state.gtin?.itemReference,
            showFieldSkeleton: false,
          ),
          TradeItemMasterdataBoundGroup(
            key: _boundMasterdataKey,
            isReadOnly: formFieldsReadOnly,
            initialStatus: _status,
            showFieldSkeleton: false,
          ),
          MarketingAuthorizationBoundGroup(
            key: _boundMarketingAuthKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          TradeItemDescriptiveAttributesCoreGroup(
            key: _descriptiveAttrsKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          NetContentMeasurementsCoreGroup(
            key: _netContentKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          PackagingHierarchyTradeItemRolesCoreGroup(
            key: _packagingHierarchyKey,
            isReadOnly: formFieldsReadOnly,
            gtinCodeController: _gtinCodeController,
            unitDescriptorController:
                _boundMasterdataKey.currentState?.unitDescriptorController,
            showFieldSkeleton: false,
          ),
          ClassificationMarketOriginCoreGroup(
            key: _classificationKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          InformationProviderManufacturerCoreGroup(
            key: _infoProviderKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          LifecycleAvailabilityStatusCoreGroup(
            key: _lifecycleKey,
            isReadOnly: formFieldsReadOnly,
            isUpdate: widget.gtinCode != null,
            showFieldSkeleton: false,
          ),
          ProductionBatchSerialDateAssociationsCoreGroup(
            key: _batchSerialKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          AuditCoreGroup(
            key: _auditKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
        ],
      ),
      industrySection: ListenableBuilder(
        listenable: Listenable.merge([
          _gtinCodeController,
          // Ensure regulatory authority section appears when target market changes.
          _descriptiveAttrsKey.currentState?.targetMarketCountryController ??
              _gtinCodeController,
        ]),
        builder: (context, _) {
          final targetMarket =
              _descriptiveAttrsKey.currentState?.targetMarketCountry ??
              widget.gtin?.targetMarketCountry;

          final synced = state.gtin;
          final pharmaExt = synced?.pharmaceuticalExtension;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GtinIndustryExtensionsSection(
                pharmaExtensionKey: _pharmaExtensionKey,
                tobaccoExtensionKey: _tobaccoExtensionKey,
                gtinCodeText: _gtinCodeController.text,
                routeGtinCode: widget.gtinCode,
                isEditing: allowMasterDataActions,
                targetMarketCountry: targetMarket,
                pharmaceuticalExtension: pharmaExt,
                tobaccoExtension: synced?.tobaccoExtension,
                deferIndustryExtensionNetworkFetch: deferIndustryFetch,
                industryExtensionFetchResolved: industryFetchResolved,
                showFieldSkeleton: false,
              ),
              RegulatoryAuthorityExtension(
                key: _regulatoryAuthorityKey,
                isEditing: allowMasterDataActions,
                showFieldSkeleton: false,
                isRegulatoryAuthorityMarket: _isRegulatoryAuthorityMarket(targetMarket),
                isImportedProduct: (pharmaExt?.mahCountry ?? '').trim().isNotEmpty &&
                    (pharmaExt?.mahCountry ?? '').trim() != '784',
                initialLocalDrugCode: pharmaExt?.localDrugCodeUaeGcc ?? '',
                initialMarketingAuthorizationNumber:
                    pharmaExt?.marketingAuthorizationNumber ?? '',
                initialLicensedAgentGlns:
                    (pharmaExt?.licensedAgentGlns ?? const []).join(', '),
                initialRegulatedProductName: pharmaExt?.regulatedProductName ?? '',
                onChanged: ({
                  required localDrugCode,
                  required marketingAuthorizationNumber,
                  required licensedAgentGlns,
                  required regulatedProductName,
                }) {},
              ),
            ],
          );
        },
      ),
      showSubmitButton: allowMasterDataActions,
      isSubmitting: _isSubmitting,
      onSubmit: _submitForm,
      submitButtonTitle: widget.gtinCode != null
          ? GtinUiConstants.submitUpdateGtin
          : GtinUiConstants.submitCreateGtin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthCubit>().state.user?.role;
    final canEditMasterData =
        role == 'ADMIN' || role == 'MANUFACTURER';
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
            final gtinCode = createdGtin?.gtinCode ?? _gtinCodeController.text;

            _saveTobaccoExtensionIfNeeded(null, gtinCode);
            _savePharmaExtensionIfNeeded(null, gtinCode);

            context.showSuccess(
              widget.gtinCode != null
                  ? GtinUiConstants.successGtinUpdated(gtinCode)
                  : GtinUiConstants.successGtinCreated(gtinCode),
            );

            if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else {
              Navigator.of(context).pop();
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
        final idStructureReadOnly = !canEditMasterData ||
            widget.gtinCode != null ||
            sk;
        final gtinFieldLocked =
            widget.gtinCode != null || !canEditMasterData || sk;
        return _buildGtinDetailForm(
          context,
          state,
          allowMasterDataActions: allowMasterDataActions,
          formFieldsReadOnly: formFieldsReadOnly,
          idStructureReadOnly: idStructureReadOnly,
          gtinFieldLocked: gtinFieldLocked,
          fullFormShimmer: sk,
        );
      },
    );

    final scaffold = Gs1MasterDataDetailScaffold(
      embedded: widget.embedded,
      title: screenTitle,
      showSaveAction: allowMasterDataActions,
      onSave: _submitForm,
      saveEnabled: allowMasterDataActions && !_isSubmitting,
      body: body,
    );

    if (widget.embedded) {
      return scaffold;
    }
    final cubit = _gtinCubit;
    if (cubit == null) {
      return scaffold;
    }
    return BlocProvider<GTINCubit>.value(
      value: cubit,
      child: scaffold,
    );
  }
}
