import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/tatmeen_view_stack_scope.dart';

abstract final class TatmeenNavigation {
  static const recordsView = 'records';

  static void navigateToRecords(BuildContext context, RecordsFilter filter) {
    final stack = TatmeenViewStackScope.maybeOf(context);
    if (context.layout.isDesktopUp && stack != null) {
      stack.pushView(recordsView, {'filter': filter});
      return;
    }
    context.push(Constants.tatmeenIntegrationRecordsRoute, extra: filter);
  }

  static void goBack(BuildContext context) {
    final stack = TatmeenViewStackScope.maybeOf(context);
    if (context.layout.isDesktopUp && stack != null && stack.canPop) {
      stack.popView();
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Constants.tatmeenIntegrationRoute);
  }
}
