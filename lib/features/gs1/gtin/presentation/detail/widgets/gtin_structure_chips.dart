import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

/// Green chips under the GTIN field: structure, indicator, 14-digit canonical.
/// Rebuilds when [gtinCodeController] text changes.
class GtinStructureChips extends StatelessWidget {
  const GtinStructureChips({
    super.key,
    required this.gtinCodeController,
  });

  final TextEditingController gtinCodeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gtinCodeController,
      builder: (context, _) {
        final data =
            GtinFieldValidators.validGtinChipsData(gtinCodeController.text);
        if (data == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(
                  data.structureLabel,
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text(
                  'Check digit ${data.checkDigit}',
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text(
                  'Indicator ${data.indicatorDigit}',
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text(
                  '14-digit: ${data.canonical14}',
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
