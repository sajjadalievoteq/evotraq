import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class ValidateBatchFields extends StatelessWidget {
  const ValidateBatchFields({
    required this.controller,
    required this.loading,
    super.key,
  });

  final TextEditingController controller;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paste identifiers (one per line). Optional type prefix: '
          'GTIN,value Â· GLN,value Â· SSCC,value Â· SGTIN,gtin,serial. '
          'Bare digits auto-detect by length.',
          style: context.text.bodySm.copyWith(color: context.colors.textMuted),
        ),
        const SizedBox(height: TraqSpacing.md),
        TextField(
          controller: controller,
          minLines: 8,
          maxLines: 16,
          enabled: !loading,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Paste identifiers',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
