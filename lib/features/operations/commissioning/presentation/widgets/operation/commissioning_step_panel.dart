import 'package:flutter/material.dart';

class CommissioningStepPanel extends StatelessWidget {
  const CommissioningStepPanel({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.isComplete,
    required this.isLocked,
    required this.lockedMessage,
    required this.child,
    this.footer,
  });

  final int stepNumber;
  final String title;
  final bool isComplete;
  final bool isLocked;
  final String lockedMessage;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final headerColor = isLocked
        ? cs.surfaceContainerHighest
        : isComplete
            ? Colors.green.shade50
            : cs.primaryContainer.withOpacity(0.3);

    final badgeColor = isLocked
        ? cs.onSurface.withOpacity(0.3)
        : isComplete
            ? Colors.green
            : cs.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: headerColor,
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                ),
                child: isComplete
                    ? const Center(
                        child: Icon(Icons.check, size: 16, color: Colors.white),
                      )
                    : Center(
                        child: Text(
                          '$stepNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? cs.onSurface.withOpacity(0.4)
                        : cs.onSurface,
                  ),
                ),
              ),
              if (isLocked)
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: cs.onSurface.withOpacity(0.35),
                ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (isLocked)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: cs.surface.withOpacity(0.75),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}
