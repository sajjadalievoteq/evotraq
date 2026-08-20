import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/automation_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';

List<RouteBase> automationRoutes(RouteAccess access) => [
  GoRoute(
    path: Constants.automationCenterRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: AutomationCenterScreen(
        initialSection: state.uri.queryParameters['section'],
      ),
    ),
    redirect: (context, state) {
      if (!access.authState.isAuthenticated) return null;
      final tab = AutomationCenterSections.normalizeTab(
        state.uri.queryParameters['section'],
        isAdmin: access.authState.isAdmin,
      );
      final requested = state.uri.queryParameters['section'];
      // Non-admins deep-linked to Job Operations land on Subscriptions.
      if (requested != null &&
          AutomationCenterSections.adminOnlyTabs.contains(
            AutomationCenterSections.normalizeTab(requested),
          ) &&
          !access.authState.isAdmin) {
        return AutomationCenterSections.location(
          AutomationCenterSections.alertSubscriptions,
        );
      }
      // Normalize unknown / legacy aliases onto a canonical tab query.
      if (requested != tab &&
          requested != AutomationCenterSections.notifications) {
        return AutomationCenterSections.location(tab);
      }
      return null;
    },
  ),
];
