import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/tatmeen_view_stack.dart';

class TatmeenViewStackScope extends InheritedNotifier<TatmeenViewStack> {
  const TatmeenViewStackScope({
    super.key,
    required TatmeenViewStack stack,
    required super.child,
  }) : super(notifier: stack);

  static TatmeenViewStack? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TatmeenViewStackScope>()
        ?.notifier;
  }

  static TatmeenViewStack of(BuildContext context) {
    final stack = maybeOf(context);
    assert(stack != null, 'TatmeenViewStackScope is missing');
    return stack!;
  }
}
