import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/gtin_detail_screen_fields.dart';
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
import 'package:traqtrace_app/features/gs1/widgets/gs1_lazy_viewport_section.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';

/// Form body that binds presenters to screen-owned [GtinDetailScreenFields].
class GtinDetailFormBody extends StatelessWidget {
  const GtinDetailFormBody({
    super.key,
    required this.formKey,
    required this.fields,
    required this.onFieldsChanged,
    required this.routeGtinCode,
    required this.routeGtin,
    required this.state,
    required this.gtin,
    required this.allowMasterDataActions,
    required this.formFieldsReadOnly,
    required this.idStructureReadOnly,
    required this.gtinFieldLocked,
    required this.fullFormShimmer,
    required this.forceMountAllSections,
    required this.isSubmitting,
    required this.onSubmit,
    required this.tobaccoExtensionKey,
    required this.pharmaExtensionKey,
    required this.regulatoryAuthorityKey,
    required this.onPickRegistrationDate,
    required this.onPickExpirationDate,
    required this.onPickLaunchDate,
    required this.onPickEffectiveDate,
    required this.onPickStartAvailDate,
    required this.onPickEndAvailDate,
    required this.onPickPublicationDate,
  });

  final GlobalKey<FormState> formKey;
  final GtinDetailScreenFields fields;
  final VoidCallback onFieldsChanged;
  final String? routeGtinCode;
  final GTIN? routeGtin;
  final GTINState state;
  final GTIN gtin;
  final bool allowMasterDataActions;
  final bool formFieldsReadOnly;
  final bool idStructureReadOnly;
  final bool gtinFieldLocked;
  final bool fullFormShimmer;
  final bool forceMountAllSections;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  final GlobalKey<TobaccoExtensionWidgetState> tobaccoExtensionKey;
  final GlobalKey<PharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<RegulatoryAuthorityExtensionState> regulatoryAuthorityKey;

  final Future<void> Function() onPickRegistrationDate;
  final Future<void> Function() onPickExpirationDate;
  final Future<void> Function() onPickLaunchDate;
  final Future<void> Function() onPickEffectiveDate;
  final Future<void> Function() onPickStartAvailDate;
  final Future<void> Function() onPickEndAvailDate;
  final Future<void> Function() onPickPublicationDate;

  Widget _lazy({
    required bool eager,
    required double placeholderHeight,
    required WidgetBuilder builder,
  }) {
    return Gs1LazyViewportSection(
      eager: eager,
      forceMount: forceMountAllSections,
      placeholderHeight: placeholderHeight,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (fullFormShimmer) {
      return GtinDetailForm(
        formKey: formKey,
        gtinFieldLocked: gtinFieldLocked,
        fullFormShimmer: true,
        unboundSpecSection: null,
        industrySection: const SizedBox.shrink(),
        showSubmitButton: false,
        isSubmitting: isSubmitting,
        onSubmit: onSubmit,
        submitButtonTitle: '',
      );
    }

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
      fullFormShimmer: false,
      unboundSpecSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GtinDetailHeaderCard(
            gtin: gtin,
            gtinCodeText: fields.gtinCodeController.text,
          ),
          // Primary above-the-fold sections: eager mount.
          GtinIdentificationStructureCoreGroup(
            isReadOnly: idStructureReadOnly,
            gtinCodeController: fields.gtinCodeController,
            gtinFieldLocked: gtinFieldLocked,
            initialGs1CompanyPrefixLength: state.gtin?.gs1CompanyPrefixLength,
            initialGs1CompanyPrefix: state.gtin?.gs1CompanyPrefix,
            initialItemReference: state.gtin?.itemReference,
            showFieldSkeleton: false,
          ),
          TradeItemMasterdataBoundGroup(
            isReadOnly: formFieldsReadOnly,
            brandNameController: fields.brandNameController,
            manufacturerController: fields.manufacturerController,
            unitDescriptorController: fields.unitDescriptorController,
            packSizeController: fields.packSizeController,
            status: fields.productStatus,
            onUnitDescriptorChanged: (v) {
              fields.unitDescriptorController.text = v ?? '';
              onFieldsChanged();
            },
            onStatusChanged: (v) {
              fields.productStatus = v;
              onFieldsChanged();
            },
            showFieldSkeleton: false,
          ),
          _lazy(
            eager: false,
            placeholderHeight: 280,
            builder: (_) => MarketingAuthorizationBoundGroup(
              isReadOnly: formFieldsReadOnly,
              numberController: fields.registrationNumberController,
              validFromDisplayController:
                  fields.registrationDateDisplayController,
              validToDisplayController: fields.expirationDateDisplayController,
              validFrom: fields.registrationDate,
              validTo: fields.expirationDate,
              onPickValidFrom: onPickRegistrationDate,
              onPickValidTo: onPickExpirationDate,
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 280,
            builder: (_) => TradeItemDescriptiveAttributesCoreGroup(
              isReadOnly: formFieldsReadOnly,
              functionalNameController: fields.functionalNameController,
              tradeItemDescriptionController:
                  fields.tradeItemDescriptionController,
              gpcBrickCodeController: fields.gpcBrickCodeController,
              targetMarketCountryController:
                  fields.targetMarketCountryController,
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 360,
            builder: (_) => NetContentMeasurementsCoreGroup(
              isReadOnly: formFieldsReadOnly,
              netContentController: fields.netContentController,
              netContentUomController: fields.netContentUomController,
              grossWeightController: fields.grossWeightController,
              grossWeightUomController: fields.grossWeightUomController,
              heightController: fields.heightController,
              widthController: fields.widthController,
              depthController: fields.depthController,
              dimUomController: fields.dimUomController,
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 480,
            builder: (_) => PackagingHierarchyTradeItemRolesCoreGroup(
              isReadOnly: formFieldsReadOnly,
              gtinCodeController: fields.gtinCodeController,
              unitDescriptorController: fields.unitDescriptorController,
              nextLowerLevelGtinController: fields.nextLowerLevelGtinController,
              nextLowerLevelQuantityController:
                  fields.nextLowerLevelQuantityController,
              quantityOfChildrenController: fields.quantityOfChildrenController,
              totalQtyNextLowerController: fields.totalQtyNextLowerController,
              launchDateDisplayController: fields.launchDateDisplayController,
              launchDate: fields.launchDate,
              isBaseUnit: fields.isBaseUnit,
              isConsumerUnit: fields.isConsumerUnit,
              isOrderableUnit: fields.isOrderableUnit,
              isDespatchUnit: fields.isDespatchUnit,
              isInvoiceUnit: fields.isInvoiceUnit,
              isVariableUnit: fields.isVariableUnit,
              onPickLaunchDate: onPickLaunchDate,
              onIsBaseUnitChanged: (v) {
                fields.isBaseUnit = v;
                onFieldsChanged();
              },
              onIsConsumerUnitChanged: (v) {
                fields.isConsumerUnit = v;
                onFieldsChanged();
              },
              onIsOrderableUnitChanged: (v) {
                fields.isOrderableUnit = v;
                onFieldsChanged();
              },
              onIsDespatchUnitChanged: (v) {
                fields.isDespatchUnit = v;
                onFieldsChanged();
              },
              onIsInvoiceUnitChanged: (v) {
                fields.isInvoiceUnit = v;
                onFieldsChanged();
              },
              onIsVariableUnitChanged: (v) {
                fields.isVariableUnit = v;
                onFieldsChanged();
              },
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 140,
            builder: (_) => ClassificationMarketOriginCoreGroup(
              isReadOnly: formFieldsReadOnly,
              countryOfOriginController: fields.countryOfOriginController,
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 220,
            builder: (_) => InformationProviderManufacturerCoreGroup(
              isReadOnly: formFieldsReadOnly,
              informationProviderNameController:
                  fields.informationProviderNameController,
              informationProviderGln: fields.informationProviderGln,
              manufacturerGln: fields.manufacturerGln,
              onInformationProviderGlnChanged: (GLN? gln) {
                fields.informationProviderGln = gln;
                if (gln != null &&
                    fields.informationProviderNameController.text
                        .trim()
                        .isEmpty) {
                  fields.informationProviderNameController.text =
                      gln.locationName;
                }
                onFieldsChanged();
              },
              onManufacturerGlnChanged: (GLN? gln) {
                fields.manufacturerGln = gln;
                onFieldsChanged();
              },
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 120,
            builder: (_) => GtinSupplyChainCard(gtin: gtin),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 320,
            builder: (_) => LifecycleAvailabilityStatusCoreGroup(
              isReadOnly: formFieldsReadOnly,
              tradeItemStatus: fields.tradeItemStatus,
              effectiveDateDisplayController:
                  fields.effectiveDateDisplayController,
              startAvailDateDisplayController:
                  fields.startAvailDateDisplayController,
              endAvailDateDisplayController:
                  fields.endAvailDateDisplayController,
              publicationDateDisplayController:
                  fields.publicationDateDisplayController,
              startAvailDate: fields.startAvailDate,
              endAvailDate: fields.endAvailDate,
              onTradeItemStatusChanged: (v) {
                fields.tradeItemStatus = v;
                onFieldsChanged();
              },
              onPickEffectiveDate: onPickEffectiveDate,
              onPickStartAvail: onPickStartAvailDate,
              onPickEndAvail: onPickEndAvailDate,
              onPickPublication: onPickPublicationDate,
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 180,
            builder: (_) => ProductionBatchSerialDateAssociationsCoreGroup(
              isReadOnly: formFieldsReadOnly,
              hasBatchNumberIndicator: fields.hasBatchNumberIndicator,
              hasSerialNumberIndicator: fields.hasSerialNumberIndicator,
              onBatchChanged: (v) {
                fields.hasBatchNumberIndicator = v;
                onFieldsChanged();
              },
              onSerialChanged: (v) {
                fields.hasSerialNumberIndicator = v;
                onFieldsChanged();
              },
              showFieldSkeleton: false,
            ),
          ),
          _lazy(
            eager: false,
            placeholderHeight: 160,
            builder: (_) => AuditCoreGroup(
              isReadOnly: formFieldsReadOnly,
              createdByController: fields.createdByController,
              updatedByController: fields.updatedByController,
              showFieldSkeleton: false,
            ),
          ),
        ],
      ),
      industrySection: _lazy(
        eager: false,
        placeholderHeight: 360,
        builder: (_) => ListenableBuilder(
          listenable: Listenable.merge([
            fields.gtinCodeController,
            fields.targetMarketCountryController,
          ]),
          builder: (context, _) {
            final targetMarket =
                fields.targetMarketCountryController.text.trim().isEmpty
                    ? routeGtin?.targetMarketCountry
                    : fields.targetMarketCountryController.text.trim();

            final synced = state.gtin;
            final pharmaExt = synced?.pharmaceuticalExtension;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GtinIndustryExtensionsSection(
                  pharmaExtensionKey: pharmaExtensionKey,
                  tobaccoExtensionKey: tobaccoExtensionKey,
                  gtinCodeText: fields.gtinCodeController.text,
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
