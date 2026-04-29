import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class DataCarrierIntegrityGroupWidget extends StatefulWidget {
  const DataCarrierIntegrityGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialDataCarrierTypeCode,
    required this.initialAntiTamperingIndicator,
    required this.initialPseudoGtinNtinFlag,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialDataCarrierTypeCode;
  final bool initialAntiTamperingIndicator;
  final bool initialPseudoGtinNtinFlag;
  final bool showFieldSkeleton;
  final void Function({
    required String dataCarrierTypeCode,
    required bool antiTamperingIndicator,
  }) onChanged;

  @override
  State<DataCarrierIntegrityGroupWidget> createState() =>
      _DataCarrierIntegrityGroupWidgetState();
}

class _DataCarrierIntegrityGroupWidgetState
    extends State<DataCarrierIntegrityGroupWidget> {
  String? _dataCarrierTypeCode;
  late bool _antiTamperingIndicator;
  late bool _pseudoGtinNtinFlag;

  @override
  void initState() {
    super.initState();
    _dataCarrierTypeCode = widget.initialDataCarrierTypeCode.trim().isEmpty
        ? null
        : widget.initialDataCarrierTypeCode;
    _antiTamperingIndicator = widget.initialAntiTamperingIndicator;
    _pseudoGtinNtinFlag = widget.initialPseudoGtinNtinFlag;
  }

  @override
  void didUpdateWidget(covariant DataCarrierIntegrityGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dataCarrierTypeCode = widget.initialDataCarrierTypeCode.trim().isEmpty
        ? null
        : widget.initialDataCarrierTypeCode;
    _antiTamperingIndicator = widget.initialAntiTamperingIndicator;
    _pseudoGtinNtinFlag = widget.initialPseudoGtinNtinFlag;
  }

  void _emitChange() {
    widget.onChanged(
      dataCarrierTypeCode: _dataCarrierTypeCode ?? '',
      antiTamperingIndicator: _antiTamperingIndicator,
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
            'Data carrier & integrity',
            padding: EdgeInsets.only(bottom: 12),
          ),
          DropdownButtonFormField<String>(
            initialValue: _dataCarrierTypeCode,
            decoration: const InputDecoration(
              labelText: 'Data Carrier Type Code *',
              border: OutlineInputBorder(),
            ),
            items: PharmaFieldValidators.dataCarrierTypeCodes
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isEditing
                ? (v) {
                    setState(() => _dataCarrierTypeCode = v);
                    _emitChange();
                  }
                : null,
            validator: PharmaFieldValidators.validateDataCarrierTypeCode,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Anti-tampering indicator'),
            value: _antiTamperingIndicator,
            onChanged: widget.isEditing
                ? (v) {
                    setState(() => _antiTamperingIndicator = v);
                    _emitChange();
                  }
                : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pseudo-GTIN / NTIN flag'),
            subtitle: const Text('Derived by backend from GTIN prefix'),
            value: _pseudoGtinNtinFlag,
            onChanged: null,
          ),
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
                'Data carrier & integrity',
                padding: EdgeInsets.only(bottom: 12),
              ),
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
