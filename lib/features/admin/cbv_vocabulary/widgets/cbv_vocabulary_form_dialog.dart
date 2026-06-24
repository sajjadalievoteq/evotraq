import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public types
// ─────────────────────────────────────────────────────────────────────────────

enum CbvVocabType { bizStep, disposition }

const List<String> kCbvVersionOptions = ['2.0', '1.0'];

class CbvVocabularyFormResult {
  const CbvVocabularyFormResult({
    required this.code,
    required this.label,
    required this.urn,
    required this.enabled,
    required this.cbvVersion,
  });

  final String code;
  final String label;
  final String urn;
  final bool enabled;
  final String cbvVersion;
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — show the dialog and return the result
// ─────────────────────────────────────────────────────────────────────────────

Future<CbvVocabularyFormResult?> showCbvVocabularyFormDialog({
  required BuildContext context,
  required CbvVocabType type,
  required List<String> existingCodes,
}) {
  return showDialog<CbvVocabularyFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CbvVocabularyFormDialog(
      type: type,
      existingCodes: existingCodes,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog widget
// ─────────────────────────────────────────────────────────────────────────────

class _CbvVocabularyFormDialog extends StatefulWidget {
  const _CbvVocabularyFormDialog({
    required this.type,
    required this.existingCodes,
  });

  final CbvVocabType type;
  final List<String> existingCodes;

  @override
  State<_CbvVocabularyFormDialog> createState() =>
      _CbvVocabularyFormDialogState();
}

class _CbvVocabularyFormDialogState extends State<_CbvVocabularyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _codeController = TextEditingController();

  String _cbvVersion = kCbvVersionOptions.first;
  bool _enabled = true;
  bool _autoGenerateCode = true;
  bool _isSaving = false;

  // ── Helpers ──────────────────────────────────────────────────────────────

  String get _typeName =>
      widget.type == CbvVocabType.bizStep ? 'Biz Step' : 'Disposition';

  String _computeUrn(String code) {
    if (code.isEmpty) return '';
    final ns = widget.type == CbvVocabType.bizStep
        ? 'urn:epcglobal:cbv:bizstep'
        : 'urn:epcglobal:cbv:disp';
    return '$ns:$code';
  }

  String _labelToCode(String label) {
    return label
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _labelController.addListener(_onLabelChanged);
  }

  @override
  void dispose() {
    _labelController
      ..removeListener(_onLabelChanged)
      ..dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onLabelChanged() {
    if (!_autoGenerateCode) return;
    final generated = _labelToCode(_labelController.text);
    if (_codeController.text != generated) {
      _codeController.text = generated;
      _codeController.selection = TextSelection.fromPosition(
        TextPosition(offset: _codeController.text.length),
      );
    }
    setState(() {});
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = CbvVocabularyFormResult(
      code: _codeController.text.trim(),
      label: _labelController.text.trim(),
      urn: _computeUrn(_codeController.text.trim()),
      enabled: _enabled,
      cbvVersion: _cbvVersion,
    );
    Navigator.of(context).pop(result);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final urnPreview = _computeUrn(_codeController.text.trim());

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle_outline, color: colors.primary, size: 20),
          const SizedBox(width: TraqSpacing.sm),
          Text('Add $_typeName'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(
          TraqSpacing.xl, TraqSpacing.md, TraqSpacing.xl, 0),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Label ────────────────────────────────────────────────
                TextFormField(
                  controller: _labelController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Label *',
                    hintText: 'e.g. Quality Hold',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Label is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TraqSpacing.lg),

                // ── Code ─────────────────────────────────────────────────
                TextFormField(
                  controller: _codeController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-z0-9_]')),
                  ],
                  onChanged: (_) {
                    setState(() => _autoGenerateCode = false);
                  },
                  decoration: InputDecoration(
                    labelText: 'Code *',
                    hintText: 'e.g. quality_hold',
                    helperText: 'Lowercase, numbers and underscores only',
                    suffixIcon: !_autoGenerateCode
                        ? IconButton(
                            tooltip: 'Re-generate from label',
                            icon: const Icon(Icons.auto_fix_high, size: 18),
                            onPressed: () {
                              setState(() {
                                _autoGenerateCode = true;
                                _codeController.text =
                                    _labelToCode(_labelController.text);
                              });
                            },
                          )
                        : null,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Code is required';
                    }
                    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v.trim())) {
                      return 'Only lowercase letters, digits and underscores';
                    }
                    if (widget.existingCodes.contains(v.trim())) {
                      return 'Code already exists for this type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TraqSpacing.lg),

                // ── URN preview ───────────────────────────────────────────
                if (urnPreview.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(TraqSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: TraqRadius.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'URN (auto-generated)',
                          style: context.text.cap
                              .copyWith(color: colors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          urnPreview,
                          style: context.text.mono
                              .copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: TraqSpacing.lg),

                // ── CBV Version ───────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _cbvVersion,
                  decoration: const InputDecoration(
                    labelText: 'CBV Version *',
                    prefixIcon: Icon(Icons.layers_outlined, size: 18),
                  ),
                  items: kCbvVersionOptions
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text('CBV $v'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _cbvVersion = v);
                  },
                ),
                const SizedBox(height: TraqSpacing.lg),

                // ── Enabled switch ────────────────────────────────────────
                Row(
                  children: [
                    Text('Enabled by default', style: context.text.body),
                    const Spacer(),
                    Switch.adaptive(
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ],
                ),
                const SizedBox(height: TraqSpacing.sm),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check, size: 18),
          label: Text('Add $_typeName'),
        ),
      ],
    );
  }
}
