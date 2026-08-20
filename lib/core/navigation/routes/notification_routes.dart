import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/subscription_details_screen.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';

List<RouteBase> notificationRoutes() => [
  GoRoute(
    path: Constants.notificationsRoute,
    redirect: (context, state) => AutomationCenterSections.location(
      AutomationCenterSections.notificationActivity,
    ),
  ),
  GoRoute(
    path: Constants.notificationSubscriptionsRoute,
    redirect: (context, state) => AutomationCenterSections.location(
      AutomationCenterSections.alertSubscriptions,
    ),
  ),
  ShellRoute(
    pageBuilder: (context, state, child) =>
        TraqRouterTransitions.featureShellPage(
          key: state.pageKey,
          child: NotificationsShell(child: child),
        ),
    routes: [
      GoRoute(
        path: Constants.notificationDetailRoute,
        pageBuilder: (context, state) {
          final subscriptionId = state.pathParameters['subscriptionId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: SubscriptionDetailsScreen(subscriptionId: subscriptionId),
          );
        },
      ),
    ],
  ),
];
