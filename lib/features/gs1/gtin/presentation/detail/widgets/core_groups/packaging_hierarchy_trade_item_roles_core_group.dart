import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

class PackagingHierarchyTradeItemRolesCoreGroup extends StatefulWidget {
  const PackagingHierarchyTradeItemRolesCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.gtinCodeController,
    required this.unitDescriptorController,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController gtinCodeController;
  final TextEditingController? unitDescriptorController;
  final bool showFieldSkeleton;

  @override
  State<PackagingHierarchyTradeItemRolesCoreGroup> createState() =>
      PackagingHierarchyTradeItemRolesCoreGroupState();
}

class PackagingHierarchyTradeItemRolesCoreGroupState
    extends State<PackagingHierarchyTradeItemRolesCoreGroup> {
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  late final TextEditingController _nextLowerLevelGtin;
  late final TextEditingController _nextLowerLevelQuantity;
  late final TextEditingController _quantityOfChildren;
  late final TextEditingController _totalQtyNextLower;
  late final TextEditingController _launchDateDisplay;
  DateTime? _launchDate;

  bool _isBaseUnit = false;
  bool _isConsumerUnit = false;
  bool _isOrderableUnit = false;
  bool _isDespatchUnit = false;
  bool _isInvoiceUnit = false;
  bool _isVariableUnit = false;

  @override
  void initState() {
    super.initState();
    _nextLowerLevelGtin = TextEditingController();
    _nextLowerLevelQuantity = TextEditingController();
    _quantityOfChildren = TextEditingController();
    _totalQtyNextLower = TextEditingController();
    _launchDateDisplay = TextEditingController();
  }

  @override
  void dispose() {
    _nextLowerLevelGtin.dispose();
    _nextLowerLevelQuantity.dispose();
    _quantityOfChildren.dispose();
    _totalQtyNextLower.dispose();
    _launchDateDisplay.dispose();
    super.dispose();
  }

  int? _intOrNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : int.tryParse(c.text.trim());
  String? _stringOrNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  String? get nextLowerLevelGtin => _stringOrNull(_nextLowerLevelGtin);
  int? get nextLowerLevelQuantity => _intOrNull(_nextLowerLevelQuantity);
  int? get quantityOfChildren => _intOrNull(_quantityOfChildren);
  int? get totalQtyNextLower => _intOrNull(_totalQtyNextLower);
  DateTime? get launchDate => _launchDate;

  bool get isBaseUnit => _isBaseUnit;
  bool get isConsumerUnit => _isConsumerUnit;
  bool get isOrderableUnit => _isOrderableUnit;
  bool get isDespatchUnit => _isDespatchUnit;
  bool get isInvoiceUnit => _isInvoiceUnit;
  bool get isVariableUnit => _isVariableUnit;

  void setFromGtin({
    required String? nextLowerLevelGtin,
    required int? nextLowerLevelQuantity,
    required int? quantityOfChildren,
    required int? totalQtyNextLower,
    required DateTime? launchDate,
    required bool? isBaseUnit,
    required bool? isConsumerUnit,
    required bool? isOrderableUnit,
    required bool? isDespatchUnit,
    required bool? isInvoiceUnit,
    required bool? isVariableUnit,
  }) {
    _nextLowerLevelGtin.text = (nextLowerLevelGtin ?? '').trim();
    _nextLowerLevelQuantity.text = nextLowerLevelQuantity?.toString() ?? '';
    _quantityOfChildren.text = quantityOfChildren?.toString() ?? '';
    _totalQtyNextLower.text = totalQtyNextLower?.toString() ?? '';

    _launchDate = launchDate;
    _launchDateDisplay.text =
        launchDate == null ? '' : _dateFmt.format(launchDate);

    _isBaseUnit = isBaseUnit ?? _isBaseUnit;
    _isConsumerUnit = isConsumerUnit ?? _isConsumerUnit;
    _isOrderableUnit = isOrderableUnit ?? _isOrderableUnit;
    _isDespatchUnit = isDespatchUnit ?? _isDespatchUnit;
    _isInvoiceUnit = isInvoiceUnit ?? _isInvoiceUnit;
    _isVariableUnit = isVariableUnit ?? _isVariableUnit;

    if (mounted) setState(() {});
  }

  Future<void> _pickLaunchDate() async {
    final initial = _launchDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _launchDate = picked;
      _launchDateDisplay.text = _dateFmt.format(picked);
    });
  }

  String? _indicatorDigitFromGtin() {
    final raw = widget.gtinCodeController.text;
    if (!GtinFieldValidators.isGtinCodeValid(raw)) return null;
    final canon = GtinFieldValidators.canonicalGtin14FromInput(raw);
    return GtinFormat.indicatorFromCanonical14(canon);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final indicatorDigit = _indicatorDigitFromGtin();

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Packaging Hierarchy & Trade Item Roles'),
        GtinValidatedField(
          controller: _nextLowerLevelGtin,
          fieldName: 'next_lower_level_gtin',
          label: 'Next Lower Level GTIN',
          helperText: 'Required when Base unit = false',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) => GtinFieldValidators.validateNextLowerLevelGtinConditional(
            v,
            isBaseUnit: _isBaseUnit,
            currentGtinRaw: widget.gtinCodeController.text,
          ),
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _nextLowerLevelQuantity,
          fieldName: 'next_lower_level_quantity',
          label: 'Next Lower Level Quantity',
          helperText: 'Required when Base unit = false',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) => GtinFieldValidators.validateNextLowerLevelQuantityConditional(
            v,
            isBaseUnit: _isBaseUnit,
            nextLowerLevelGtin: _nextLowerLevelGtin.text,
          ),
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _quantityOfChildren,
          fieldName: 'quantity_of_children',
          label: 'Quantity of Children',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) => GtinFieldValidators.validateQuantityOfChildrenConditional(
            v,
            isBaseUnit: _isBaseUnit,
          ),
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _totalQtyNextLower,
          fieldName: 'total_qty_next_lower',
          label: 'Total Quantity of Next Lower Level Trade Items',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) => GtinFieldValidators.validateTotalQtyNextLowerConditional(
            v,
            isBaseUnit: _isBaseUnit,
          ),
        ),
        const SizedBox(height: 12),
        GtinDateField(
          controller: _launchDateDisplay,
          label: 'Launch Date',
          enabled: !widget.isReadOnly,
          onPick: _pickLaunchDate,
        ),
        const SizedBox(height: 12),
        const SectionLabel('Trade Item Role Flags'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isBaseUnit,
          onChanged: widget.isReadOnly ? null : (v) => setState(() => _isBaseUnit = v),
          title: const Text('Is Trade Item a Base Unit?'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isConsumerUnit,
          onChanged:
              widget.isReadOnly ? null : (v) => setState(() => _isConsumerUnit = v),
          title: const Text('Is Trade Item a Consumer Unit?'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isOrderableUnit,
          onChanged:
              widget.isReadOnly ? null : (v) => setState(() => _isOrderableUnit = v),
          title: const Text('Is Trade Item an Orderable Unit?'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isDespatchUnit,
          onChanged:
              widget.isReadOnly ? null : (v) => setState(() => _isDespatchUnit = v),
          title: const Text('Is Trade Item a Despatch (Shipping) Unit?'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isInvoiceUnit,
          onChanged:
              widget.isReadOnly ? null : (v) => setState(() => _isInvoiceUnit = v),
          title: const Text('Is Trade Item an Invoice Unit?'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isVariableUnit,
          onChanged:
              widget.isReadOnly ? null : (v) => setState(() => _isVariableUnit = v),
          title: const Text('Is Trade Item a Variable Unit?'),
        ),
        FormField<void>(
          validator: (_) => GtinFieldValidators.validateTradeItemRoleFlags(
            isBaseUnit: _isBaseUnit,
            isConsumerUnit: _isConsumerUnit,
            isOrderableUnit: _isOrderableUnit,
            isDespatchUnit: _isDespatchUnit,
            isInvoiceUnit: _isInvoiceUnit,
            isVariableUnit: _isVariableUnit,
            unitDescriptor: widget.unitDescriptorController?.text,
            indicatorDigit: indicatorDigit,
            isReadOnly: widget.isReadOnly,
          ),
          builder: (state) {
            if (state.errorText == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                state.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Packaging Hierarchy & Trade Item Roles'),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          const SectionLabel('Trade Item Role Flags'),
          const SizedBox(height: 8),
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GtinSkeletonOutlineField(color: c, height: 56),
          ],
        ],
      ),
    );
  }
}

