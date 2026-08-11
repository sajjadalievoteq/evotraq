import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';

class AiElementComposeFields extends StatelessWidget {
  const AiElementComposeFields({
    required this.aiController,
    required this.valueController,
    required this.pairs,
    required this.loading,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final TextEditingController aiController;
  final TextEditingController valueController;
  final Map<String, String> pairs;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ValidatedTextFieldWrapper(
                controller: aiController,
                fieldName: 'ai',
                decoration: const InputDecoration(labelText: 'AI'),
                keyboardType: TextInputType.number,
                readOnly: loading,
              ),
            ),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              flex: 5,
              child: ValidatedTextFieldWrapper(
                controller: valueController,
                fieldName: 'ai_value',
                decoration: const InputDecoration(labelText: 'Value'),
                readOnly: loading,
              ),
            ),
            const SizedBox(width: TraqSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomOutlinedButtonWidget(
                title: 'Add',
                onTap: () {
                  if (!loading) onAdd();
                },
              ),
            ),
          ],
        ),
        if (pairs.isNotEmpty) ...[
          const SizedBox(height: TraqSpacing.md),
          Wrap(
            spacing: TraqSpacing.sm,
            runSpacing: TraqSpacing.sm,
            children: [
              for (final entry in pairs.entries)
                Chip(
                  label: Text('(${entry.key}) ${entry.value}'),
                  onDeleted: loading ? null : () => onRemove(entry.key),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
