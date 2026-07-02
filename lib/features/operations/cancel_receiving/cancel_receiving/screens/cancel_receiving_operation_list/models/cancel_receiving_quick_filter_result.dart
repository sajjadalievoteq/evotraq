import 'package:flutter/foundation.dart';

@immutable
class CancelReceivingQuickFilterResult {
  const CancelReceivingQuickFilterResult.cleared() : cleared = true, status = null;

  const CancelReceivingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
