import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_structure_chips.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

class GtinIdentificationStructureCoreGroup extends StatefulWidget {
  const GtinIdentificationStructureCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.gtinCodeController,
    this.initialGs1CompanyPrefixLength,
    this.initialGs1CompanyPrefix,
    this.initialItemReference,
    this.gtinFocusNode,
    this.onGtinEditingComplete,
    this.gtinFieldLocked,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController gtinCodeController;
  final int? initialGs1CompanyPrefixLength;
  final String? initialGs1CompanyPrefix;
  final String? initialItemReference;
  final FocusNode? gtinFocusNode;
  final VoidCallback? onGtinEditingComplete;
  final bool? gtinFieldLocked;
  final bool showFieldSkeleton;

  @override
  State<GtinIdentificationStructureCoreGroup> createState() =>
      _GtinIdentificationStructureCoreGroupState();
}

class _GtinIdentificationStructureCoreGroupState
    extends State<GtinIdentificationStructureCoreGroup> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  late final TextEditingController _gtinStructure;
  late final TextEditingController _indicatorDigit;
  late final TextEditingController _checkDigit;
  late final TextEditingController _companyPrefixLength;
  late final TextEditingController _gs1CompanyPrefix;
  late final TextEditingController _itemReference;

  Timer? _deriveDebounce;
  bool _isDeriving = false;

  @override
  void initState() {
    super.initState();
    if (widget.gtinFocusNode != null) {
      _focusNode = widget.gtinFocusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _gtinStructure = TextEditingController();
    _indicatorDigit = TextEditingController();
    _checkDigit = TextEditingController();
    _companyPrefixLength = TextEditingController();
    _gs1CompanyPrefix = TextEditingController();
    _itemReference = TextEditingController();

    // When opening an existing GTIN detail screen, show persisted chip values immediately.
    final initLen = widget.initialGs1CompanyPrefixLength;
    if (initLen != null) _companyPrefixLength.text = initLen.toString();
    _gs1CompanyPrefix.text = (widget.initialGs1CompanyPrefix ?? '').trim();
    _itemReference.text = (widget.initialItemReference ?? '').trim();

    // Populate chips when user leaves the GTIN field (more reliable than only on "done").
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _normalizeGtinIfPossible();
        _deriveIdentificationDebounced();
      }
    });
  }

  @override
  void dispose() {
    _deriveDebounce?.cancel();
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _gtinStructure.dispose();
    _indicatorDigit.dispose();
    _checkDigit.dispose();
    _companyPrefixLength.dispose();
    _gs1CompanyPrefix.dispose();
    _itemReference.dispose();
    super.dispose();
  }

  void _normalizeGtinIfPossible() {
    final locked = widget.gtinFieldLocked ?? widget.isReadOnly;
    if (locked) return;
    final raw = widget.gtinCodeController.text;
    if (!GtinFieldValidators.isGtinCodeValid(raw)) return;

    final n = GtinFieldValidators.canonicalGtin14FromInput(raw);
    if (raw == n) return;
    widget.gtinCodeController.value = TextEditingValue(
      text: n,
      selection: TextSelection.collapsed(offset: n.length),
    );
  }

  Future<void> _deriveIdentificationFromBackend() async {
    if (widget.isReadOnly) return;
    final raw = widget.gtinCodeController.text;
    if (!GtinFieldValidators.isGtinCodeValid(raw)) {
      if (mounted) setState(() => _isDeriving = false);
      return;
    }

    try {
      final svc = getIt<GTINService>();
      final res = await svc.deriveIdentification(raw);
      if (!mounted) return;

      final pfxLen = res['gs1CompanyPrefixLength']?.toString() ?? '';
      final pfx = res['gs1CompanyPrefix']?.toString() ?? '';
      final itemRef = res['itemReference']?.toString() ?? '';

      debugPrint(
        '[GtinIdentification] derived chips | gtin=$raw | len=$pfxLen | pfx=$pfx | itemRef=$itemRef',
      );

      _companyPrefixLength.text = pfxLen;
      _gs1CompanyPrefix.text = pfx;
      _itemReference.text = itemRef;
    } catch (e) {
      // Keep UI non-blocking: chips remain blank if derivation fails.
      // But log so we can see auth/400/network failures during debugging.
      debugPrint('[GtinIdentification] derive-identification failed: $e');
    } finally {
      if (mounted) setState(() => _isDeriving = false);
    }
  }

  void _deriveIdentificationDebounced() {
    _deriveDebounce?.cancel();
    if (!mounted) return;
    // Immediately show shimmer while we wait for the backend response.
    setState(() => _isDeriving = true);
    _deriveDebounce = Timer(const Duration(milliseconds: 250), () {
      _deriveIdentificationFromBackend();
    });
  }

  Widget _chip({
    required ThemeData theme,
    required String label,
    required String value,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final v = value.trim();
    final text = v.isEmpty ? '—' : v;
    return Chip(
      backgroundColor: backgroundColor,
      label: Text(
        '$label $text',
        style: theme.textTheme.labelSmall?.copyWith(color: foregroundColor),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _shimmerChip({
    required ThemeData theme,
    required String label,
  }) {
    // Match the same shimmer colors used by our loading screens.
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 900),
      child: Chip(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        label: Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(
          'Identification & Structure',
          padding: EdgeInsets.only(top: 0, bottom: 8),
        ),
        GtinValidatedField(
          focusNode: _focusNode,
          onEditingComplete: () {
            _normalizeGtinIfPossible();
            _deriveIdentificationDebounced();
            widget.onGtinEditingComplete?.call();
          },
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          controller: widget.gtinCodeController,
          fieldName: 'gtinCode',
          label: 'GTIN *',
          helperText:
              '8, 12, 13, or 14 digits',
          readOnly: widget.gtinFieldLocked ?? widget.isReadOnly,
          validator: GtinFieldValidators.validateGtinCode,
        ),
        GtinStructureChips(gtinCodeController: widget.gtinCodeController),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: Listenable.merge([
            widget.gtinCodeController,
            _companyPrefixLength,
            _gs1CompanyPrefix,
            _itemReference,
          ]),
          builder: (context, _) {
            final theme = Theme.of(context);

            final muted = theme.colorScheme.onSurfaceVariant;

            if (_isDeriving) {
              return Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _shimmerChip(theme: theme, label: 'GCP length'),
                  _shimmerChip(theme: theme, label: 'GCP'),
                  _shimmerChip(theme: theme, label: 'Item reference'),
                ],
              );
            }

            final chips = <Widget>[];
            if (_companyPrefixLength.text.trim().isNotEmpty) {
              chips.add(
                _chip(
                  theme: theme,
                  label: 'GCP length',
                  value: _companyPrefixLength.text,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
              );
            }
            if (_gs1CompanyPrefix.text.trim().isNotEmpty) {
              chips.add(
                _chip(
                  theme: theme,
                  label: 'GCP',
                  value: _gs1CompanyPrefix.text,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: muted,
                ),
              );
            }
            if (_itemReference.text.trim().isNotEmpty) {
              chips.add(
                _chip(
                  theme: theme,
                  label: 'Item reference',
                  value: _itemReference.text,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: muted,
                ),
              );
            }

            if (chips.isEmpty) return const SizedBox.shrink();

            return Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: chips,
            );
          },
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            widget.gtinCodeController,
          ]),
          builder: (context, _) {
            final raw = widget.gtinCodeController.text;
            final s = GtinFormat.stripGtinInput(raw);
            if (!GtinFieldValidators.isGtinCodeValid(raw)) {
              _gtinStructure.text = '';
              _indicatorDigit.text = '';
              _checkDigit.text = '';
              return Text(
                'Enter a valid GTIN',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              );
            }

            final structure = GtinFormat.structureLabelForStrippedInput(s) ?? '';
            final canon = GtinFieldValidators.canonicalGtin14FromInput(raw);
            final indicator = GtinFormat.indicatorFromCanonical14(canon);
            final check = s.isNotEmpty ? s[s.length - 1] : '';

            _gtinStructure.text = structure;
            _indicatorDigit.text = indicator ?? '';
            _checkDigit.text = check;

            return const SizedBox.shrink();
          },
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: fields,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(
            'Identification & Structure',
            padding: EdgeInsets.only(top: 0, bottom: 8),
          ),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
              const SizedBox(width: 8),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
              const SizedBox(width: 8),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
            ],
          ),
        ],
      ),
    );
  }
}

