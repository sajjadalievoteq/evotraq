import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_validated_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class DrugIdentificationGroupWidget extends StatefulWidget {
  const DrugIdentificationGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialNdcNumber,
    required this.initialDinNumber,
    required this.initialEanPharmaCode,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialNdcNumber;
  final String initialDinNumber;
  final String initialEanPharmaCode;
  final bool showFieldSkeleton;
  final void Function({
    required String ndcNumber,
    required String dinNumber,
    required String eanPharmaCode,
  })
  onChanged;

  @override
  State<DrugIdentificationGroupWidget> createState() =>
      _DrugIdentificationGroupWidgetState();
}

class _DrugIdentificationGroupWidgetState
    extends State<DrugIdentificationGroupWidget> {
  late final TextEditingController _ndcNumberController;
  late final TextEditingController _dinNumberController;
  late final TextEditingController _eanPharmaCodeController;

  @override
  void initState() {
    super.initState();
    _ndcNumberController = TextEditingController(text: widget.initialNdcNumber);
    _dinNumberController = TextEditingController(text: widget.initialDinNumber);
    _eanPharmaCodeController = TextEditingController(
      text: widget.initialEanPharmaCode,
    );

    _ndcNumberController.addListener(_emitChange);
    _dinNumberController.addListener(_emitChange);
    _eanPharmaCodeController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant DrugIdentificationGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNdcNumber == oldWidget.initialNdcNumber &&
        widget.initialDinNumber == oldWidget.initialDinNumber &&
        widget.initialEanPharmaCode == oldWidget.initialEanPharmaCode) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialNdcNumber != oldWidget.initialNdcNumber &&
          widget.initialNdcNumber != _ndcNumberController.text) {
        _ndcNumberController.text = widget.initialNdcNumber;
      }
      if (widget.initialDinNumber != oldWidget.initialDinNumber &&
          widget.initialDinNumber != _dinNumberController.text) {
        _dinNumberController.text = widget.initialDinNumber;
      }
      if (widget.initialEanPharmaCode != oldWidget.initialEanPharmaCode &&
          widget.initialEanPharmaCode != _eanPharmaCodeController.text) {
        _eanPharmaCodeController.text = widget.initialEanPharmaCode;
      }
    });
  }

  @override
  void dispose() {
    _ndcNumberController.dispose();
    _dinNumberController.dispose();
    _eanPharmaCodeController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      ndcNumber: _ndcNumberController.text,
      dinNumber: _dinNumberController.text,
      eanPharmaCode: _eanPharmaCodeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PharmaGroupValidatedField(
            controller: _ndcNumberController,
            fieldName: 'ndcNumber',
            label: 'NDC Number',
            isEditing: widget.isEditing,
            helperText: 'National Drug Code (US)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNdcNumber,
          ),
          PharmaGroupValidatedField(
            controller: _dinNumberController,
            fieldName: 'dinNumber',
            label: 'DIN Number',
            isEditing: widget.isEditing,
            helperText: 'Drug Identification Number (Canada)',
            maxLength: 8,
            validator: PharmaFieldValidators.validateDinNumber,
          ),
          PharmaGroupValidatedField(
            controller: _eanPharmaCodeController,
            fieldName: 'eanPharmaCode',
            label: 'EAN Pharma Code',
            isEditing: widget.isEditing,
            helperText: 'European Pharmaceutical Code (GTIN-13)',
            maxLength: 13,
            validator: PharmaFieldValidators.validateEanPharmaCode,
          ),
        ],
      ),
    );
    return Gs1GroupCard(
      title: 'Drug identification',
      outlineColor: outline,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonFieldCount: 3,
      child: content,
    );
  }
}
