import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/utils/gtin_detail_market_utils.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/audit_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/classification_market_origin_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/gtin_identification_structure_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/gtin_supply_chain_card.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/information_provider_manufacturer_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/lifecycle_availability_status_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/marketing_authorization_bound_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/net_content_measurements_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/packaging_hierarchy_trade_item_roles_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/production_batch_serial_date_associations_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/trade_item_descriptive_attributes_core_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/trade_item_masterdata_bound_group.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/regulatory_authority/regulatory_authority_extension.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_detail_form.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_detail_header_card.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_industry_extensions_section.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';

class GtinDetailFormBody extends StatelessWidget {
  const GtinDetailFormBody({
    super.key,
    required this.formKey,
    required this.gtinCodeController,
    required this.status,
    required this.routeGtinCode,
    required this.routeGtin,
    required this.state,
    required this.gtin,
    required this.allowMasterDataActions,
    required this.formFieldsReadOnly,
    required this.idStructureReadOnly,
    required this.gtinFieldLocked,
    required this.fullFormShimmer,
    required this.isSubmitting,
    required this.onSubmit,
    required this.tobaccoExtensionKey,
    required this.pharmaExtensionKey,
    required this.regulatoryAuthorityKey,
    required this.boundMasterdataKey,
    required this.boundMarketingAuthKey,
    required this.descriptiveAttrsKey,
    required this.packagingHierarchyKey,
    required this.netContentKey,
    required this.classificationKey,
    required this.infoProviderKey,
    required this.lifecycleKey,
    required this.batchSerialKey,
    required this.auditKey,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController gtinCodeController;
  final String? status;
  final String? routeGtinCode;
  final GTIN? routeGtin;
  final GTINState state;
  final GTIN gtin;
  final bool allowMasterDataActions;
  final bool formFieldsReadOnly;
  final bool idStructureReadOnly;
  final bool gtinFieldLocked;
  final bool fullFormShimmer;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  final GlobalKey<TobaccoExtensionWidgetState> tobaccoExtensionKey;
  final GlobalKey<PharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<RegulatoryAuthorityExtensionState> regulatoryAuthorityKey;
  final GlobalKey<TradeItemMasterdataBoundGroupState> boundMasterdataKey;
  final GlobalKey<MarketingAuthorizationBoundGroupState> boundMarketingAuthKey;
  final GlobalKey<TradeItemDescriptiveAttributesCoreGroupState>
      descriptiveAttrsKey;
  final GlobalKey<PackagingHierarchyTradeItemRolesCoreGroupState>
      packagingHierarchyKey;
  final GlobalKey<NetContentMeasurementsCoreGroupState> netContentKey;
  final GlobalKey<ClassificationMarketOriginCoreGroupState> classificationKey;
  final GlobalKey<InformationProviderManufacturerCoreGroupState>
      infoProviderKey;
  final GlobalKey<LifecycleAvailabilityStatusCoreGroupState> lifecycleKey;
  final GlobalKey<ProductionBatchSerialDateAssociationsCoreGroupState>
      batchSerialKey;
  final GlobalKey<AuditCoreGroupState> auditKey;

  @override
  Widget build(BuildContext context) {
    final deferIndustryFetch =
        routeGtinCode != null &&
        (state.status == GTINStatus.loading ||
            state.status == GTINStatus.initial);
    final industryFetchResolved =
        !deferIndustryFetch ||
        state.status == GTINStatus.success ||
        state.status == GTINStatus.error;

    return GtinDetailForm(
      formKey: formKey,
      gtinFieldLocked: gtinFieldLocked,
      fullFormShimmer: fullFormShimmer,
      unboundSpecSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GtinDetailHeaderCard(
            gtin: gtin,
            gtinCodeText: gtinCodeController.text,
          ),
          GtinSupplyChainCard(gtin: gtin),
          GtinIdentificationStructureCoreGroup(
            isReadOnly: idStructureReadOnly,
            gtinCodeController: gtinCodeController,
            gtinFieldLocked: gtinFieldLocked,
            initialGs1CompanyPrefixLength: state.gtin?.gs1CompanyPrefixLength,
            initialGs1CompanyPrefix: state.gtin?.gs1CompanyPrefix,
            initialItemReference: state.gtin?.itemReference,
            showFieldSkeleton: false,
          ),
          TradeItemMasterdataBoundGroup(
            key: boundMasterdataKey,
            isReadOnly: formFieldsReadOnly,
            initialStatus: status,
            showFieldSkeleton: false,
          ),
          MarketingAuthorizationBoundGroup(
            key: boundMarketingAuthKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          TradeItemDescriptiveAttributesCoreGroup(
            key: descriptiveAttrsKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          NetContentMeasurementsCoreGroup(
            key: netContentKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          PackagingHierarchyTradeItemRolesCoreGroup(
            key: packagingHierarchyKey,
            isReadOnly: formFieldsReadOnly,
            gtinCodeController: gtinCodeController,
            unitDescriptorController:
                boundMasterdataKey.currentState?.unitDescriptorController,
            showFieldSkeleton: false,
          ),
          ClassificationMarketOriginCoreGroup(
            key: classificationKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          InformationProviderManufacturerCoreGroup(
            key: infoProviderKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          LifecycleAvailabilityStatusCoreGroup(
            key: lifecycleKey,
            isReadOnly: formFieldsReadOnly,
            isUpdate: routeGtinCode != null,
            showFieldSkeleton: false,
          ),
          ProductionBatchSerialDateAssociationsCoreGroup(
            key: batchSerialKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
          AuditCoreGroup(
            key: auditKey,
            isReadOnly: formFieldsReadOnly,
            showFieldSkeleton: false,
          ),
        ],
      ),
      industrySection: ListenableBuilder(
        listenable: Listenable.merge([
          gtinCodeController,
          descriptiveAttrsKey.currentState?.targetMarketCountryController ??
              gtinCodeController,
        ]),
        builder: (context, _) {
          final targetMarket =
              descriptiveAttrsKey.currentState?.targetMarketCountry ??
              routeGtin?.targetMarketCountry;

          final synced = state.gtin;
          final pharmaExt = synced?.pharmaceuticalExtension;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GtinIndustryExtensionsSection(
                pharmaExtensionKey: pharmaExtensionKey,
                tobaccoExtensionKey: tobaccoExtensionKey,
                gtinCodeText: gtinCodeController.text,
                routeGtinCode: routeGtinCode,
                isEditing: allowMasterDataActions,
                targetMarketCountry: targetMarket,
                pharmaceuticalExtension: pharmaExt,
                tobaccoExtension: synced?.tobaccoExtension,
                deferIndustryExtensionNetworkFetch: deferIndustryFetch,
                industryExtensionFetchResolved: industryFetchResolved,
                showFieldSkeleton: false,
              ),
              RegulatoryAuthorityExtension(
                key: regulatoryAuthorityKey,
                isEditing: allowMasterDataActions,
                showFieldSkeleton: false,
                isRegulatoryAuthorityMarket: isRegulatoryAuthorityMarket(
                  targetMarket,
                ),
                isImportedProduct:
                    (pharmaExt?.mahCountry ?? '').trim().isNotEmpty &&
                    (pharmaExt?.mahCountry ?? '').trim() != '784',
                initialLocalDrugCode: pharmaExt?.localDrugCodeUaeGcc ?? '',
                initialMarketingAuthorizationNumber:
                    pharmaExt?.marketingAuthorizationNumber ?? '',
                initialLicensedAgentGlns:
                    (pharmaExt?.licensedAgentGlns ?? const []).join(', '),
                initialRegulatedProductName:
                    pharmaExt?.regulatedProductName ?? '',
                onChanged:
                    ({
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
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
      submitButtonTitle: routeGtinCode != null
          ? GtinUiConstants.submitUpdateGtin
          : GtinUiConstants.submitCreateGtin,
    );
  }
}
