import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
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
  }) onChanged;

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
    _eanPharmaCodeController =
        TextEditingController(text: widget.initialEanPharmaCode);

    _ndcNumberController.addListener(_emitChange);
    _dinNumberController.addListener(_emitChange);
    _eanPharmaCodeController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant DrugIdentificationGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  Widget _buildValidatedField(
    TextEditingController controller,
    String fieldName,
    String label, {
    String? helperText,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GtinValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLength: maxLength,
        inputFormatters: maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null,
        readOnly: !widget.isEditing,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'Drug identification',
            padding: EdgeInsets.only(bottom: 12),
          ),
          _buildValidatedField(
              _ndcNumberController, 'ndcNumber', 'NDC Number',
              helperText: 'National Drug Code (US)',
              maxLength: 20,
              validator: PharmaFieldValidators.validateNdcNumber),
          _buildValidatedField(
              _dinNumberController, 'dinNumber', 'DIN Number',
              helperText: 'Drug Identification Number (Canada)',
              maxLength: 8,
              validator: PharmaFieldValidators.validateDinNumber),
          _buildValidatedField(
              _eanPharmaCodeController, 'eanPharmaCode', 'EAN Pharma Code',
              helperText: 'European Pharmaceutical Code (GTIN-13)',
              maxLength: 13,
              validator: PharmaFieldValidators.validateEanPharmaCode),
        ],
      ),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline.withOpacity(0.45)),
      ),
      child: GtinFieldSkeletonMask(
        show: widget.showFieldSkeleton,
        child: content,
        skeletonBuilder: (c) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel(
                'Drug identification',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
