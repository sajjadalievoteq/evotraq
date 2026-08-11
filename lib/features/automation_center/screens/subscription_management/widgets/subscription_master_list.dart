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
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_master_row.dart';

class SubscriptionMasterList extends StatelessWidget {
  const SubscriptionMasterList({
    required this.subscriptions,
    required this.selectedId,
    required this.onSelected,
  });

  final List<NotificationSubscription> subscriptions;
  final String selectedId;
  final ValueChanged<NotificationSubscription> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: subscriptions.length,
      separatorBuilder: (_, _) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        return SubscriptionMasterRow(
          subscription: sub,
          selected: sub.id == selectedId,
          onTap: () => onSelected(sub),
        );
      },
    );
  }
}
