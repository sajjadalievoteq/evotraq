import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';

class TatmeenMasterPane extends StatelessWidget {
  const TatmeenMasterPane({
    super.key,
    required this.selectedSection,
    required this.onSelectSection,
    required this.state,
    required this.canUpdate,
    required this.onToggle,
  });

  final String selectedSection;
  final ValueChanged<String> onSelectSection;
  final TatmeenIntegrationState state;
  final bool canUpdate;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final enabled = state.isEnabled;
    final busy =
        state.status == TatmeenIntegrationStatus.loading ||
        state.status == TatmeenIntegrationStatus.updating ||
        state.status == TatmeenIntegrationStatus.testingConnection;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: context.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tatmeen Settings', style: context.text.h3),
            const SizedBox(height: TraqSpacing.md),
            _MasterItem(
              label: 'Integration',
              selected:
                  selectedSection == TatmeenIntegrationSections.integration,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    enabled ? 'On' : 'Off',
                    style: context.text.bodySm.copyWith(
                      color: context.colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: TraqSpacing.xs),
                  Switch.adaptive(
                    value: enabled,
                    onChanged: canUpdate && !busy ? onToggle : null,
                  ),
                ],
              ),
              onTap: () =>
                  onSelectSection(TatmeenIntegrationSections.integration),
            ),
            const SizedBox(height: TraqSpacing.sm),
            _MasterItem(
              label: 'Credentials',
              selected:
                  selectedSection == TatmeenIntegrationSections.credentials,
              subtitle: 'Configure username, password, and API key',
              onTap: () =>
                  onSelectSection(TatmeenIntegrationSections.credentials),
            ),
            if (!canUpdate) ...[
              const SizedBox(height: TraqSpacing.md),
              Text(
                'Credential updates require admin access.',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MasterItem extends StatelessWidget {
  const _MasterItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(TraqSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? colors.primary : colors.border),
          color: selected ? colors.primary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: TraqSpacing.xs),
                    Text(
                      subtitle!,
                      style: context.text.bodySm.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: TraqSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
