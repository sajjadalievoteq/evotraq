import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

/// Empty state matching [GtinListEmptyView] styling.
class GlnListEmptyView extends StatelessWidget {
  const GlnListEmptyView({
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
              Icons.location_off_outlined,
              size: 64,
              color: muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No GLNs found',
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
