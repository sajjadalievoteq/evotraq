import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

/// Empty state when no GTINs match filters or search.
class GtinListEmptyView extends StatelessWidget {
  const GtinListEmptyView({
    super.key,
    required this.onClearFilters,
  });

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 64,
              color: muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No GTINs found',
              style: theme.textTheme.headlineSmall?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButtonWidget(
              title: 'Clear filters & search',
              icon: Icons.refresh,
              onTap: onClearFilters,
              minimumWidth: 200,
            ),
          ],
        ),
      ),
    );
  }
}

