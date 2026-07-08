import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_event_validation_demo.dart';

class TransactionEventValidationDemoRoute {
  static GoRoute getRoute() {
    return GoRoute(
      path: '/demo/transaction-validation',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const TransactionEventValidationDemo(),
      ),
    );
  }
}
