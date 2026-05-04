import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

class GtinAdvancedFiltersToggle extends StatelessWidget {
  const GtinAdvancedFiltersToggle({
    super.key,
    required this.showAdvancedFilters,
    required this.onToggle,
    required this.onClearAll,
  });

  final bool showAdvancedFilters;
  final VoidCallback onToggle;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(
              showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
            ),
            label: Text(
              showAdvancedFilters
                  ? GtinUiConstants.hideAdvancedFilters
                  : GtinUiConstants.showAdvancedFilters,
            ),
          ),
          const Spacer(),
          if (showAdvancedFilters)
            TextButton(
              onPressed: onClearAll,
              child: const Text(GtinUiConstants.clearAllFiltersButton),
            ),
        ],
      ),
    );
  }
}

