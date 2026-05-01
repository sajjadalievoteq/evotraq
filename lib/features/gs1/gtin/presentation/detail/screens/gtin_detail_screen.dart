import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/data/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/tobacco/models/gtin_tobacco_extension_model.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_form.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_industry_extensions_section.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/uae_regulatory_extension.dart';
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

class GTINDetailScreen extends StatefulWidget {
  final String? gtinCode;
  final bool isEditing;
  final GTIN? gtin;
  final bool embedded;

  /// When [embedded] is true, invoked after a successful create/update instead of [Navigator.pop].
  final VoidCallback? onEmbeddedActionSuccess;

  const GTINDetailScreen({
    super.key,
    this.gtinCode,
    required this.isEditing,
    this.gtin,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  @override
  State<GTINDetailScreen> createState() => _GTINDetailScreenState();
}

class _GTINDetailScreenState extends State<GTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tobaccoExtensionKey = GlobalKey<TobaccoExtensionWidgetState>();
  final _pharmaExtensionKey = GlobalKey<PharmaceuticalExtensionWidgetState>();
  final _uaeRegulatoryKey = GlobalKey<UaeRegulatoryExtensionState>();
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

  /// After a network fetch, child groups hydrate in a post-frame callback (they need mounted keys).
  /// Until then, keep showing the detail shimmer so users never see empty fields flash.
  bool _formFieldsHydrated = true;

  /// Route opened with [gtinCode] only — fetch remote GTIN and hydrate form after load.
  bool get _remoteFetchPath => widget.gtinCode != null && widget.gtin == null;
  GTINPharmaceuticalExtension? _pharmaceuticalExtension;
  GTINTobaccoExtension? _tobaccoExtension;

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
    if (_remoteFetchPath) {
      _formFieldsHydrated = false;
    }
    if (widget.gtin != null) {
      _initializeFormWithGTIN(widget.gtin!);
    } else if (widget.gtinCode != null && !widget.isEditing) {
      context.read<GTINCubit>().fetchGTINDetails(widget.gtinCode!);
    }
  }

  @override
  void didUpdateWidget(covariant GTINDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCode = oldWidget.gtinCode;
    final newCode = widget.gtinCode;
    if (oldCode != newCode && newCode != null && !widget.isEditing) {
      setState(() {
        if (widget.gtin == null) _formFieldsHydrated = false;
      });
      context.read<GTINCubit>().fetchGTINDetails(newCode);
    }
  }

  void _initializeFormWithGTIN(GTIN gtin) {
    if (kDebugMode) {
      debugPrint('Initializing form with GTIN: ${gtin.gtinCode}');
      debugPrint(
        'GTIN dates: registrationDate=${gtin.registrationDate}, expirationDate=${gtin.expirationDate}',
      );
    }

    _gtinCodeController.text = gtin.gtinCode;
    _status = gtin.status?.toUpperCase();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

    final uaeState = _uaeRegulatoryKey.currentState;
    final pharmaState = _pharmaExtensionKey.currentState;
    if (uaeState != null && pharmaState != null && uaeState.hasData) {
      pharmaState.applyUaeRegulatoryValues(
        localDrugCode: uaeState.localDrugCode,
        marketingAuthorizationNumber: uaeState.marketingAuthorizationNumber,
        licensedAgentGlns: uaeState.licensedAgentGlns,
        regulatedProductName: uaeState.regulatedProductName,
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

      if (widget.isEditing && widget.gtinCode != null) {
        context.read<GTINCubit>().updateGTIN(gtin);
      } else {
        context.read<GTINCubit>().createGTIN(gtin);
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
      final uaeState = _uaeRegulatoryKey.currentState;
      if (uaeState != null && uaeState.hasData) {
        pharmaState.applyUaeRegulatoryValues(
          localDrugCode: uaeState.localDrugCode,
          marketingAuthorizationNumber: uaeState.marketingAuthorizationNumber,
          licensedAgentGlns: uaeState.licensedAgentGlns,
          regulatedProductName: uaeState.regulatedProductName,
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

  /// Loading fetch or post-fetch hydration: shimmer on each section’s fields (real widgets stay mounted).
  bool _fieldSkeletonsActive(GTINState state) {
    if (_isSubmitting) return false;
    if (state.status == GTINStatus.loading) return true;
    return _remoteFetchPath &&
        state.status == GTINStatus.success &&
        state.gtin != null &&
        !_formFieldsHydrated;
  }

  static bool _isUaeMarket(String? targetMarketCountry) {
    final raw = (targetMarketCountry ?? '').trim();
    if (raw.isEmpty) return false;
    final digits = RegExp(r'\d+').stringMatch(raw);
    return digits == '784';
  }

  Widget _buildGtinDetailForm(
    BuildContext context,
    GTINState state, {
    required bool isReadOnly,
    required bool showFieldSkeletons,
  }) {
    final gtinFieldLocked = isReadOnly || widget.gtinCode != null;
    return GtinDetailForm(
      formKey: _formKey,
      gtinFieldLocked: gtinFieldLocked,
      showFieldSkeletons: showFieldSkeletons,
      unboundSpecSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GtinIdentificationStructureCoreGroup(
            isReadOnly: isReadOnly,
            gtinCodeController: _gtinCodeController,
            gtinFieldLocked: gtinFieldLocked,
            initialGs1CompanyPrefixLength: state.gtin?.gs1CompanyPrefixLength,
            initialGs1CompanyPrefix: state.gtin?.gs1CompanyPrefix,
            initialItemReference: state.gtin?.itemReference,
            showFieldSkeleton: showFieldSkeletons,
          ),
          TradeItemMasterdataBoundGroup(
            key: _boundMasterdataKey,
            isReadOnly: isReadOnly,
            initialStatus: _status,
            showFieldSkeleton: showFieldSkeletons,
          ),
          MarketingAuthorizationBoundGroup(
            key: _boundMarketingAuthKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
          TradeItemDescriptiveAttributesCoreGroup(
            key: _descriptiveAttrsKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
          NetContentMeasurementsCoreGroup(
            key: _netContentKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
          PackagingHierarchyTradeItemRolesCoreGroup(
            key: _packagingHierarchyKey,
            isReadOnly: isReadOnly,
            gtinCodeController: _gtinCodeController,
            unitDescriptorController:
                _boundMasterdataKey.currentState?.unitDescriptorController,
            showFieldSkeleton: showFieldSkeletons,
          ),
          ClassificationMarketOriginCoreGroup(
            key: _classificationKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
          InformationProviderManufacturerCoreGroup(
            key: _infoProviderKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
          LifecycleAvailabilityStatusCoreGroup(
            key: _lifecycleKey,
            isReadOnly: isReadOnly,
            isUpdate: widget.gtinCode != null,
            showFieldSkeleton: showFieldSkeletons,
          ),
          ProductionBatchSerialDateAssociationsCoreGroup(
            key: _batchSerialKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
          AuditCoreGroup(
            key: _auditKey,
            isReadOnly: isReadOnly,
            showFieldSkeleton: showFieldSkeletons,
          ),
        ],
      ),
      industrySection: ListenableBuilder(
        listenable: Listenable.merge([
          _gtinCodeController,
          // Ensure UAE extension appears immediately when Target Market changes.
          _descriptiveAttrsKey.currentState?.targetMarketCountryController ??
              _gtinCodeController,
        ]),
        builder: (context, _) {
          final targetMarket =
              _descriptiveAttrsKey.currentState?.targetMarketCountry ??
              widget.gtin?.targetMarketCountry;

          final pharmaExt = _pharmaceuticalExtension;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GtinIndustryExtensionsSection(
                pharmaExtensionKey: _pharmaExtensionKey,
                tobaccoExtensionKey: _tobaccoExtensionKey,
                gtinCodeText: _gtinCodeController.text,
                routeGtinCode: widget.gtinCode,
                isEditing: widget.isEditing,
                targetMarketCountry: targetMarket,
                pharmaceuticalExtension: pharmaExt,
                tobaccoExtension: _tobaccoExtension,
                showFieldSkeleton: showFieldSkeletons,
              ),
              UaeRegulatoryExtension(
                key: _uaeRegulatoryKey,
                isEditing: widget.isEditing,
                showFieldSkeleton: showFieldSkeletons,
                isUaeMarket: _isUaeMarket(targetMarket),
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
      showSubmitButton: !isReadOnly,
      isSubmitting: _isSubmitting,
      onSubmit: _submitForm,
      submitButtonTitle:
          widget.gtinCode != null ? 'Update GTIN' : 'Create GTIN',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = !widget.isEditing && widget.gtinCode != null;
    final screenTitle = isReadOnly
        ? 'GTIN Details'
        : widget.isEditing && widget.gtinCode != null
            ? 'Edit GTIN'
            : 'Create GTIN';

    final body = BlocConsumer<GTINCubit, GTINState>(
      listener: (context, state) {
        if (state.status == GTINStatus.error) {
          setState(() {
            _isSubmitting = false;
            if (_remoteFetchPath) {
              _formFieldsHydrated = true;
            }
          });
          debugPrint(
            '[GTIN UI] detail error (snackbar): ${state.error} '
            'routeGtinParam=${widget.gtinCode ?? "(new)"}',
          );
          context.showError(state.error ?? '');
        }

        if (state.status == GTINStatus.success) {
          if (state.gtin != null &&
              !widget.isEditing &&
              widget.gtinCode != null) {
            if (_remoteFetchPath) {
              _initializeFormWithGTIN(state.gtin!);
            }
            _pharmaceuticalExtension = state.pharmaceuticalExtension;
            _tobaccoExtension = state.tobaccoExtension;
          } else if (_isSubmitting) {
            setState(() {
              _isSubmitting = false;
            });

            final createdGtin = state.gtin;
            final gtinCode = createdGtin?.gtinCode ?? _gtinCodeController.text;

            _saveTobaccoExtensionIfNeeded(null, gtinCode);
            _savePharmaExtensionIfNeeded(null, gtinCode);

            context.showSuccess(
              widget.isEditing && widget.gtinCode != null
                  ? 'GTIN $gtinCode updated successfully'
                  : 'GTIN $gtinCode created successfully',
            );

            if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else {
              Navigator.of(context).pop();
            }
          }
        }
      },
      builder: (context, state) {
        final sk = _fieldSkeletonsActive(state);
        return _buildGtinDetailForm(
          context,
          state,
          isReadOnly: isReadOnly,
          showFieldSkeletons: sk,
        );
      },
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSubmitting ? null : _submitForm,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
