import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

class EpcInputTypeBadge extends StatelessWidget {
  const EpcInputTypeBadge({required this.result, super.key});

  final EPCParseResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text(
            '${result.typeLabel} detected',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: colorScheme.primaryContainer,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
