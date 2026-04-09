import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_event_validation_demo.dart';

/// Route configuration for the transaction event validation demo screen
class TransactionEventValidationDemoRoute {
  /// Get a GoRoute for the transaction event validation demo
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
