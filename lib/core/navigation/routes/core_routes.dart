import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/auth/screens/check_email/check_email_screen.dart';
import 'package:traqtrace_app/features/auth/screens/forgot_password/forgot_password_screen.dart';
import 'package:traqtrace_app/features/auth/screens/login/login_screen.dart';
import 'package:traqtrace_app/features/auth/screens/reset_password/reset_password_screen.dart';
import 'package:traqtrace_app/features/auth/screens/signup/register_screen.dart';
import 'package:traqtrace_app/features/auth/screens/verify_email/verify_email_screen.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell.dart';
import 'package:traqtrace_app/features/home/screens/home/home_screen.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/inbox_outbox_screen.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/product_hierarchy_screen.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/journey_dashboard_screen.dart';
import 'package:traqtrace_app/features/splash/screens/splash_screen.dart';
import 'package:traqtrace_app/features/user/screens/profile/profile_screen.dart';

List<RouteBase> coreRoutes() => [
  GoRoute(
    path: Constants.splashRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      animate: false,
      child: const SplashScreen(),
    ),
  ),

  ShellRoute(
    builder: (context, state, child) => AuthShell(child: child),
    routes: [
      GoRoute(
        path: Constants.loginRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.authShellPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Constants.registerRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.authShellPage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: Constants.checkEmailRoute,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return TraqRouterTransitions.authShellPage(
            key: state.pageKey,
            child: CheckEmailScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.forgotPasswordRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.authShellPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: Constants.resetPasswordRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return TraqRouterTransitions.authShellPage(
            key: state.pageKey,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: Constants.authResetPasswordRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return TraqRouterTransitions.authShellPage(
            key: state.pageKey,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: Constants.verifyEmailRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'];
          return TraqRouterTransitions.authShellPage(
            key: state.pageKey,
            child: VerifyEmailScreen(token: token, email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.verifyEmailAliasRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'];
          return TraqRouterTransitions.authShellPage(
            key: state.pageKey,
            child: VerifyEmailScreen(token: token, email: email),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: Constants.homeRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const HomeScreen(),
    ),
  ),
  GoRoute(
    path: Constants.profileRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ProfileScreen(),
    ),
  ),
  GoRoute(
    path: Constants.journeyDashboardRoute,
    pageBuilder: (context, state) {
      final epc = state.uri.queryParameters['epc'];
      return TraqRouterTransitions.fadeThroughPage(
        key: state.pageKey,
        child: JourneyDashboardScreen(initialEpc: epc),
      );
    },
  ),
  GoRoute(
    path: Constants.inboxOutboxRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const InboxOutboxScreen(),
    ),
  ),
  GoRoute(
    path: Constants.productHierarchyRoute,
    pageBuilder: (context, state) {
      final epc = state.uri.queryParameters['epc'];
      return TraqRouterTransitions.fadeThroughPage(
        key: state.pageKey,
        child: ProductHierarchyScreen(initialEpc: epc),
      );
    },
  ),
];
