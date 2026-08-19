import 'package:flutter/foundation.dart';

class TatmeenPaneView {
  const TatmeenPaneView({required this.view, this.params = const {}});

  final String view;
  final Map<String, Object?> params;
}

class TatmeenViewStack extends ChangeNotifier {
  TatmeenViewStack({String initialView = 'dashboard'})
    : _stack = [TatmeenPaneView(view: initialView)];

  List<TatmeenPaneView> _stack;

  TatmeenPaneView get current => _stack.last;

  bool get canPop => _stack.length > 1;

  void pushView(String view, [Map<String, Object?> params = const {}]) {
    _stack = [..._stack, TatmeenPaneView(view: view, params: params)];
    notifyListeners();
  }

  void popView() {
    if (_stack.length <= 1) return;
    _stack = _stack.sublist(0, _stack.length - 1);
    notifyListeners();
  }

  void resetTo(String view) {
    _stack = [TatmeenPaneView(view: view)];
    notifyListeners();
  }
}
