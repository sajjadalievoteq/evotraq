import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/auth/utils/auth_email_validator.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';

/// Multi-email chip field for Tatmeen alert recipients.
///
/// Uses [AuthInputField] (email type) for per-address validation. The Add
/// button lives only here so login/signup and other [AuthInputField]
/// screens are unchanged.
class TatmeenEmailRecipientsField extends StatefulWidget {
  const TatmeenEmailRecipientsField({
    super.key,
    required this.emails,
    required this.enabled,
    required this.onChanged,
    this.maxRecipients = 20,
  });

  final List<String> emails;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;
  final int maxRecipients;

  @override
  State<TatmeenEmailRecipientsField> createState() =>
      _TatmeenEmailRecipientsFieldState();
}

class _TatmeenEmailRecipientsFieldState
    extends State<TatmeenEmailRecipientsField> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  String? _listError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _normalized => widget.emails
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();

  void _add() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = _controller.text.trim().toLowerCase();
    final next = List<String>.from(_normalized);
    if (next.contains(email)) {
      setState(() => _listError = 'This email is already in the list');
      return;
    }
    if (next.length >= widget.maxRecipients) {
      setState(
        () => _listError =
            'At most ${widget.maxRecipients} email addresses are allowed',
      );
      return;
    }

    next.add(email);
    _controller.clear();
    form.reset();
    setState(() => _listError = null);
    widget.onChanged(next);
  }

  void _removeAt(int index) {
    final next = List<String>.from(_normalized)..removeAt(index);
    setState(() => _listError = null);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Alert emails', style: context.text.body),
        const SizedBox(height: TraqSpacing.xs),
        Text(
          'Enabled notification are emailed only to addresses in this list.',
          style: context.text.bodySm.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: TraqSpacing.sm),
        if (_normalized.isNotEmpty) ...[
          Wrap(
            spacing: TraqSpacing.xs,
            runSpacing: TraqSpacing.xs,
            children: [
              for (var i = 0; i < _normalized.length; i++)
                InputChip(
                  label: Text(_normalized[i]),
                  onDeleted: widget.enabled ? () => _removeAt(i) : null,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: TraqSpacing.sm),
        ] else if (!widget.enabled)
          Padding(
            padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
            child: Text(
              'No alert emails configured',
              style: context.text.bodySm.copyWith(color: colors.textMuted),
            ),
          ),
        if (widget.enabled)
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AuthInputField(
                      controller: _controller,
                      labelText: 'Email address',
                      hintText: 'name@company.com',
                      type: AuthInputFieldType.email,
                      enabled: widget.enabled,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _add(),
                      validator: AuthEmailValidator.validate,
                    ),
                  ),
                ),
                const SizedBox(width: TraqSpacing.sm),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: FilledButton.icon(
                    onPressed: widget.enabled ? _add : null,
                    icon: const TraqIcon(AppAssets.iconPlus, size: 16),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        if (_listError != null) ...[
          const SizedBox(height: TraqSpacing.xs),
          Text(
            _listError!,
            style: context.text.bodySm.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
