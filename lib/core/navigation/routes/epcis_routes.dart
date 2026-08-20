import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_detail/aggregation_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event/aggregation_event_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_batch_import/object_event_batch_import_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/object_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event/object_event_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/utils/object_event_route_constants.dart';
import 'package:traqtrace_app/features/epcis/screens/epcis_generic_event_detail/epcis_generic_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document_help/transaction_document_help_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/transaction_document_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_form/transaction_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_events_help/transaction_events_help_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_events_list/transaction_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/transformation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/transformation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/widgets/epcis_shell.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';

List<RouteBase> epcisRoutes(RouteAccess access) => [
  ShellRoute(
    pageBuilder: (context, state, child) =>
        TraqRouterTransitions.featureShellPage(
          key: state.pageKey,
          child: EpcisShell(child: child),
        ),
    routes: [
      GoRoute(
        path: Constants.epcisObjectEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ObjectEventScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisAggregationEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const AggregationEventScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisTransactionEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const TransactionEventsListScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisTransformationEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const TransformationEventsListScreen(),
        ),
      ),

      GoRoute(
        path: Constants.epcisObjectEventNewRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const ObjectEventFormScreen(),
            ),
      ),
      GoRoute(
        path: Constants.epcisObjectEventBatchImportRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const ObjectEventBatchImportScreen(),
            ),
      ),
      GoRoute(
        path: Constants.epcisAggregationEventNewRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const AggregationEventFormScreen(),
            ),
      ),
      GoRoute(
        path: Constants.epcisTransactionEventNewRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const TransactionEventFormScreen(),
            ),
      ),
      GoRoute(
        path: Constants.epcisTransactionEventHelpRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const TransactionEventsHelpScreen(),
            ),
      ),
      GoRoute(
        path: Constants.epcisTransformationEventNewRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const TransformationEventFormScreen(),
            ),
      ),

      GoRoute(
        path: Constants.epcisEventDetailRoute,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: EpcisGenericEventDetailScreen(eventId: eventId),
          );
        },
      ),
      GoRoute(
        path: Constants.epcisObjectEventDetailQueryRoute,
        pageBuilder: (context, state) {
          final eventId =
              state.uri.queryParameters[ObjectEventRouteConstants
                  .queryEventId] ??
              '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: ObjectEventDetailScreen(eventId: eventId),
          );
        },
      ),
      GoRoute(
        path: Constants.epcisObjectEventDetailRoute,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: ObjectEventDetailScreen(eventId: id),
          );
        },
        redirect: (context, state) {
          if (!access.authState.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          final id = state.pathParameters['id'] ?? '';
          if (id.contains(':') || id.contains(';') || id.contains('/')) {
            return ObjectEventRouteConstants.detailLocation(id);
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisAggregationEventDetailRoute,
        pageBuilder: (context, state) {
          final aggregationEventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: AggregationEventDetailScreen(eventId: aggregationEventId),
          );
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionEventDetailRoute,
        pageBuilder: (context, state) {
          final transactionEventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: TransactionEventFormScreen(
              transactionEventId: transactionEventId,
            ),
          );
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionDocumentsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const TransactionDocumentScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisTransactionDocumentHelpRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.sharedAxisHorizontalPage(
              key: state.pageKey,
              child: const TransactionDocumentHelpScreen(),
            ),
      ),
      GoRoute(
        path: Constants.epcisTransformationEventDetailRoute,
        pageBuilder: (context, state) {
          final transformationEventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: TransformationEventFormScreen(
              transformationEventId: transformationEventId,
            ),
          );
        },
      ),
    ],
  ),
];
