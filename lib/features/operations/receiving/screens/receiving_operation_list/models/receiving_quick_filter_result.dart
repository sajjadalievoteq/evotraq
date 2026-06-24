import 'package:flutter/foundation.dart';

@immutable
class ReceivingQuickFilterResult {
  const ReceivingQuickFilterResult.cleared() : cleared = true, status = null;

  const ReceivingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
