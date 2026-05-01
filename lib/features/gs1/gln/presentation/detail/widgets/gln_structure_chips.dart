import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';

/// Client-side structure hints under the GLN field (parallel to [GtinStructureChips]).
class GlnStructureChips extends StatelessWidget {
  const GlnStructureChips({
    super.key,
    required this.glnCodeController,
  });

  final TextEditingController glnCodeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: glnCodeController,
      builder: (context, _) {
        final raw = glnCodeController.text;
        final s = GlnFormat.stripGlnInput(raw);
        if (!GlnFieldValidators.isGlnCodeValid(raw)) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        final check = s.length == 13 ? s[12] : '';
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(
                  '13-digit GLN',
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text(
                  'Check digit $check',
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        );
      },
    );
  }
}
