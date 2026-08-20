import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_master_item.dart';

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
            TatmeenMasterItem(
              label: 'Dashboard',
              iconAsset: NavIcons.dashboard,
              selected: selectedSection == TatmeenIntegrationSections.dashboard,
              subtitle: 'Overview and sync metrics',
              onTap: () =>
                  onSelectSection(TatmeenIntegrationSections.dashboard),
            ),
            const SizedBox(height: TraqSpacing.sm),
            TatmeenMasterItem(
              label: 'Integration',
              iconAsset: NavIcons.tatmeenIntegration,
              selected:
                  selectedSection == TatmeenIntegrationSections.configurations,
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
                  onSelectSection(TatmeenIntegrationSections.configurations),
            ),
            const SizedBox(height: TraqSpacing.sm),

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
