import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/widgets/uae_authorization_section.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/widgets/uae_distribution_section.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/widgets/uae_labeling_section.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/widgets/uae_regulatory_identifiers_section.dart';

class UaeRegulatoryExtension extends StatefulWidget {
  const UaeRegulatoryExtension({
    super.key,
    required this.isEditing,
    required this.showFieldSkeleton,
    required this.isUaeMarket,
    required this.initialLocalDrugCode,
    required this.initialMarketingAuthorizationNumber,
    required this.initialLicensedAgentGlns,
    required this.initialRegulatedProductName,
    required this.isImportedProduct,
    required this.onChanged,
  });

  final bool isEditing;
  final bool showFieldSkeleton;
  final bool isUaeMarket;
  final String initialLocalDrugCode;
  final String initialMarketingAuthorizationNumber;
  final String initialLicensedAgentGlns;
  final String initialRegulatedProductName;
  final bool isImportedProduct;
  final void Function({
    required String localDrugCode,
    required String marketingAuthorizationNumber,
    required String licensedAgentGlns,
    required String regulatedProductName,
  }) onChanged;

  @override
  State<UaeRegulatoryExtension> createState() => UaeRegulatoryExtensionState();
}

class UaeRegulatoryExtensionState extends State<UaeRegulatoryExtension> {
  late final TextEditingController _localDrugCodeController;
  late final TextEditingController _marketingAuthorizationNumberController;
  late final TextEditingController _licensedAgentGlnsController;
  late final TextEditingController _regulatedProductNameController;

  @override
  void initState() {
    super.initState();
    _localDrugCodeController = TextEditingController(text: widget.initialLocalDrugCode);
    _marketingAuthorizationNumberController =
        TextEditingController(text: widget.initialMarketingAuthorizationNumber);
    _licensedAgentGlnsController =
        TextEditingController(text: widget.initialLicensedAgentGlns);
    _regulatedProductNameController =
        TextEditingController(text: widget.initialRegulatedProductName);
    _localDrugCodeController.addListener(_emitChange);
    _marketingAuthorizationNumberController.addListener(_emitChange);
    _licensedAgentGlnsController.addListener(_emitChange);
    _regulatedProductNameController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant UaeRegulatoryExtension oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocalDrugCode != oldWidget.initialLocalDrugCode &&
        widget.initialLocalDrugCode != _localDrugCodeController.text) {
      _localDrugCodeController.text = widget.initialLocalDrugCode;
    }
    if (widget.initialMarketingAuthorizationNumber !=
            oldWidget.initialMarketingAuthorizationNumber &&
        widget.initialMarketingAuthorizationNumber !=
            _marketingAuthorizationNumberController.text) {
      _marketingAuthorizationNumberController.text =
          widget.initialMarketingAuthorizationNumber;
    }
    if (widget.initialLicensedAgentGlns != oldWidget.initialLicensedAgentGlns &&
        widget.initialLicensedAgentGlns != _licensedAgentGlnsController.text) {
      _licensedAgentGlnsController.text = widget.initialLicensedAgentGlns;
    }
    if (widget.initialRegulatedProductName != oldWidget.initialRegulatedProductName &&
        widget.initialRegulatedProductName != _regulatedProductNameController.text) {
      _regulatedProductNameController.text = widget.initialRegulatedProductName;
    }
  }

  @override
  void dispose() {
    _localDrugCodeController.dispose();
    _marketingAuthorizationNumberController.dispose();
    _licensedAgentGlnsController.dispose();
    _regulatedProductNameController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      localDrugCode: _localDrugCodeController.text,
      marketingAuthorizationNumber: _marketingAuthorizationNumberController.text,
      licensedAgentGlns: _licensedAgentGlnsController.text,
      regulatedProductName: _regulatedProductNameController.text,
    );
  }

  bool get hasData =>
      _localDrugCodeController.text.trim().isNotEmpty ||
      _marketingAuthorizationNumberController.text.trim().isNotEmpty ||
      _licensedAgentGlnsController.text.trim().isNotEmpty ||
      _regulatedProductNameController.text.trim().isNotEmpty;

  String get localDrugCode => _localDrugCodeController.text;
  String get marketingAuthorizationNumber => _marketingAuthorizationNumberController.text;
  String get licensedAgentGlns => _licensedAgentGlnsController.text;
  String get regulatedProductName => _regulatedProductNameController.text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        collapsedBackgroundColor: const Color(0xFF121F17),
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        shape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        leading: const Icon(Icons.flag, color: Colors.white),
        title: const Text(
          'UAE Regulatory Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        initiallyExpanded: widget.showFieldSkeleton || hasData,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UaeRegulatoryIdentifiersSection(
                  isReadOnly: !widget.isEditing,
                  showFieldSkeleton: widget.showFieldSkeleton,
                  isUaeMarket: widget.isUaeMarket,
                  localDrugCodeController: _localDrugCodeController,
                  marketingAuthorizationNumberController:
                      _marketingAuthorizationNumberController,
                ),
                UaeAuthorizationSection(
                  isReadOnly: !widget.isEditing,
                  showFieldSkeleton: widget.showFieldSkeleton,
                  isUaeMarket: widget.isUaeMarket,
                  isImportedProduct: widget.isImportedProduct,
                  licensedAgentGlnsController: _licensedAgentGlnsController,
                ),
                UaeDistributionSection(
                  showFieldSkeleton: widget.showFieldSkeleton,
                  isUaeMarket: widget.isUaeMarket,
                  isImportedProduct: widget.isImportedProduct,
                ),
                UaeLabelingSection(
                  isReadOnly: !widget.isEditing,
                  showFieldSkeleton: widget.showFieldSkeleton,
                  isUaeMarket: widget.isUaeMarket,
                  regulatedProductNameController: _regulatedProductNameController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
