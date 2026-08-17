import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_validation_demo/transaction_event_validation_demo.dart';

class TransactionEventValidationDemoRoute {
  static GoRoute getRoute() {
    return GoRoute(
      path: '/demo/transaction-validation',
      pageBuilder: (context, state) =>
          TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: const TransactionEventValidationDemo(),
          ),
    );
  }
}
