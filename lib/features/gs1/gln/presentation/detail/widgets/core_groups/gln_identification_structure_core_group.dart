import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_structure_chips.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// GS1 identification: GLN field, structure chips, backend-derived GCP chips (same pattern as GTIN).
class GlnIdentificationStructureCoreGroup extends StatefulWidget {
  const GlnIdentificationStructureCoreGroup({
    super.key,
    required this.setFieldError,
    required this.readOnly,
    required this.glnCodeController,
    required this.gs1CompanyPrefixController,
    required this.locationReferenceDigitsController,
    required this.checkDigitController,
    required this.parentGlnCodeController,
    required this.glnExtensionComponentController,
    this.initialGs1CompanyPrefixLength,
    this.showFieldSkeleton = false,
  });

  final GlnFormSetFieldError setFieldError;
  final bool readOnly;

  final TextEditingController glnCodeController;
  final TextEditingController gs1CompanyPrefixController;
  final TextEditingController locationReferenceDigitsController;
  final TextEditingController checkDigitController;
  final TextEditingController parentGlnCodeController;
  final TextEditingController glnExtensionComponentController;

  /// From persisted GLN / GET — drives GCP length chip before first derive.
  final int? initialGs1CompanyPrefixLength;

  final bool showFieldSkeleton;

  @override
  State<GlnIdentificationStructureCoreGroup> createState() =>
      _GlnIdentificationStructureCoreGroupState();
}

class _GlnIdentificationStructureCoreGroupState
    extends State<GlnIdentificationStructureCoreGroup> {
  late final FocusNode _glnFocusNode;
  late final bool _ownsFocusNode;

  late final TextEditingController _companyPrefixLength;

  Timer? _deriveDebounce;
  bool _isDeriving = false;

  @override
  void initState() {
    super.initState();
    _glnFocusNode = FocusNode();
    _ownsFocusNode = true;

    _companyPrefixLength = TextEditingController();
    final initLen = widget.initialGs1CompanyPrefixLength;
    if (initLen != null) {
      _companyPrefixLength.text = initLen.toString();
    }

    _glnFocusNode.addListener(() {
      if (!_glnFocusNode.hasFocus) {
        _deriveIdentificationDebounced();
      }
    });
  }

  @override
  void didUpdateWidget(GlnIdentificationStructureCoreGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialGs1CompanyPrefixLength !=
            oldWidget.initialGs1CompanyPrefixLength &&
        widget.initialGs1CompanyPrefixLength != null &&
        _companyPrefixLength.text.trim().isEmpty) {
      _companyPrefixLength.text =
          widget.initialGs1CompanyPrefixLength!.toString();
    }
  }

  @override
  void dispose() {
    _deriveDebounce?.cancel();
    if (_ownsFocusNode) {
      _glnFocusNode.dispose();
    }
    _companyPrefixLength.dispose();
    super.dispose();
  }

  Future<void> _deriveIdentificationFromBackend() async {
    if (widget.readOnly) {
      if (mounted) setState(() => _isDeriving = false);
      return;
    }
    final raw = widget.glnCodeController.text;
    if (!GlnFieldValidators.isGlnCodeValid(raw)) {
      if (mounted) setState(() => _isDeriving = false);
      return;
    }

    try {
      final svc = getIt<GLNService>();
      final canon = GlnFormat.stripGlnInput(raw);
      final res = await svc.deriveIdentification(canon);
      if (!mounted) return;

      final pfxLen = res['gs1CompanyPrefixLength']?.toString() ?? '';
      final pfx = res['gs1CompanyPrefix']?.toString() ?? '';
      final locRef =
          res['locationReference']?.toString() ?? res['locationReferenceDigits']?.toString() ?? '';
      final check = res['checkDigit']?.toString() ?? '';

      _companyPrefixLength.text = pfxLen;
      widget.gs1CompanyPrefixController.text = pfx;
      widget.locationReferenceDigitsController.text = locRef;
      widget.checkDigitController.text = check;
    } catch (e) {
      debugPrint('[GlnIdentification] derive-identification failed: $e');
    } finally {
      if (mounted) setState(() => _isDeriving = false);
    }
  }

  void _deriveIdentificationDebounced() {
    _deriveDebounce?.cancel();
    if (!mounted) return;
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

  Widget _shimmerChip({required ThemeData theme}) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Chip(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(GlnUiConstants.sectionIdentificationStructure),
        GtinValidatedField(
          focusNode: _glnFocusNode,
          onEditingComplete: () {
            _deriveIdentificationDebounced();
          },
          controller: widget.glnCodeController,
          fieldName: 'glnCode',
          label: GlnUiConstants.labelGlnThirteenDigits,
          hintText: GlnUiConstants.hintGlnThirteen,
          readOnly: widget.readOnly,
          setFieldError: widget.setFieldError,
          keyboardType: TextInputType.number,
          maxLength: 13,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: GlnFieldValidators.validateGlnCode,
        ),
        GlnStructureChips(glnCodeController: widget.glnCodeController),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: Listenable.merge([
            widget.glnCodeController,
            _companyPrefixLength,
            widget.gs1CompanyPrefixController,
            widget.locationReferenceDigitsController,
            widget.checkDigitController,
          ]),
          builder: (context, _) {
            final t = Theme.of(context);
            final m = t.colorScheme.onSurfaceVariant;

            if (_isDeriving && !widget.readOnly) {
              return Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _shimmerChip(theme: t),
                  _shimmerChip(theme: t),
                  _shimmerChip(theme: t),
                ],
              );
            }

            final chips = <Widget>[];
            if (_companyPrefixLength.text.trim().isNotEmpty) {
              chips.add(
                _chip(
                  theme: t,
                  label: GlnUiConstants.labelGcpLength,
                  value: _companyPrefixLength.text,
                  backgroundColor: t.colorScheme.surfaceContainerHighest,
                  foregroundColor: t.colorScheme.onSurface,
                ),
              );
            }
            if (widget.gs1CompanyPrefixController.text.trim().isNotEmpty) {
              chips.add(
                _chip(
                  theme: t,
                  label: GlnUiConstants.labelGcp,
                  value: widget.gs1CompanyPrefixController.text,
                  backgroundColor: t.colorScheme.surfaceContainerHighest,
                  foregroundColor: m,
                ),
              );
            }
            if (widget.locationReferenceDigitsController.text.trim().isNotEmpty) {
              chips.add(
                _chip(
                  theme: t,
                  label: GlnUiConstants.labelLocationReference,
                  value: widget.locationReferenceDigitsController.text,
                  backgroundColor: t.colorScheme.surfaceContainerHighest,
                  foregroundColor: m,
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
        const SizedBox(height: 16),
        GtinValidatedField(
          controller: widget.parentGlnCodeController,
          fieldName: 'parentGlnCode',
          label: GlnUiConstants.labelParentGln,
          hintText: GlnUiConstants.hintParentGln,
          readOnly: widget.readOnly,
          setFieldError: widget.setFieldError,
          keyboardType: TextInputType.number,
          maxLength: 13,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: GlnFieldValidators.validateParentGlnOptional,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: widget.glnExtensionComponentController,
          fieldName: 'glnExtensionComponent',
          label: GlnUiConstants.labelGlnExtensionAi254,
          helperText: GlnUiConstants.helperGlnExtensionAi254,
          readOnly: widget.readOnly,
          setFieldError: widget.setFieldError,
          validator: GlnFieldValidators.validateGlnExtensionComponentOptional,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: fields,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(GlnUiConstants.sectionIdentificationStructure),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
              const SizedBox(width: 8),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
              const SizedBox(width: 8),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
            ],
          ),
          const SizedBox(height: 16),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
    );
  }
}
