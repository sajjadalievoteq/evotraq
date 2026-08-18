import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_body.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_delivery_utils.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_action_menu.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';

class EmbeddedFullDetailsPane extends StatelessWidget {
  const EmbeddedFullDetailsPane({
    required this.subscription,
    required this.stats,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    this.shrinkWrap = false,
  });

  final NotificationSubscription subscription;
  final NotificationStats? stats;
  final VoidCallback onBack;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TraqSpacing.sm,
              TraqSpacing.sm,
              TraqSpacing.md,
              TraqSpacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to summary',
                  onPressed: onBack,
                  icon: const TraqIcon(AppAssets.iconChevronL, size: 18),
                ),
                Expanded(
                  child: Text(
                    'Subscription details',
                    style: context.text.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SubscriptionActionMenu(
                  subscription: subscription,
                  onEdit: () => onEdit(subscription),
                  onPause: () => onPause(subscription),
                  onResume: () => onResume(subscription),
                  onDelete: () => onDelete(subscription),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          if (shrinkWrap)
            Padding(
              padding: TraqSpacing.surfacePad,
              child: SubscriptionDetailsBody(
                subscription: subscription,
                stats: stats,
                embedded: true,
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: TraqSpacing.surfacePad,
                child: SubscriptionDetailsBody(
                  subscription: subscription,
                  stats: stats,
                  embedded: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
