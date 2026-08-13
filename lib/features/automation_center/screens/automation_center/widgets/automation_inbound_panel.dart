import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/inbound_api_catalog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/system_users_card.dart';

/// Inbound Automation Center panel.
///
/// Expects an [InboundCatalogCubit] from an ancestor (workspace-scoped) so the
/// catalog survives Outbound ↔ Inbound section switches without a skeleton flash.
class AutomationInboundPanel extends StatelessWidget {
  const AutomationInboundPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    final colors = context.colors;

    return AutomationWorkbenchPanel(
      title: 'Inbound',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tools for sending data into Traq and testing inbound API integrations.',
            style: context.text.body.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: TraqSpacing.lg),
          Container(
            padding: const EdgeInsets.all(TraqSpacing.lg),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .06),
              border: Border.all(color: colors.primary.withValues(alpha: .25)),
              borderRadius: TraqRadius.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to authenticate', style: context.text.h3),
                const SizedBox(height: TraqSpacing.sm),
                const SelectableText(
                  '1. Using a Postman/curl request (not this web app - B2B Service accounts cannot sign in here), sign in through the authentication endpoint with your B2B Service username and password.\n'
                  '2. Copy the JWT access token from the response.\n'
                  '3. Send Authorization: Bearer <token> with every catalog request.\n'
                  'The Postman collection can store the same base URL and bearer token as environment variables.',
                ),
              ],
            ),
          ),
          const SizedBox(height: TraqSpacing.lg),
          if (isAdmin) ...[
            const SizedBox(height: TraqSpacing.lg),
            const SystemUsersCard(),
          ],
          const SizedBox(height: TraqSpacing.lg),
          const InboundApiCatalog(),
        ],
      ),
    );
  }
}
