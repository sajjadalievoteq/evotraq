import 'package:flutter/foundation.dart';

class DrawerScrollMemory {
  DrawerScrollMemory._();
  static double _savedOffset = 0.0;
  static bool _pendingRestore = false;
  static final openNotifier = ValueNotifier<int>(0);
  static void saveForRestore(double offset) {
    _savedOffset = offset;
    _pendingRestore = true;
  }

  static void clearRestore() {
    _savedOffset = 0.0;
    _pendingRestore = false;
  }

  static double consumeOffset() {
    final offset = _pendingRestore ? _savedOffset : 0.0;
    _pendingRestore = false;
    return offset;
  }

  static void notifyDrawerOpened() => openNotifier.value++;
}
