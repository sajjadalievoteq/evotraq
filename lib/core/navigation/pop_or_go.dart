import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Leaves the current form: pop the route stack when possible, otherwise go to
/// [fallbackRoute] (typically the list). Never navigates to a detail page.
void popOrGo(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute);
  }
}
