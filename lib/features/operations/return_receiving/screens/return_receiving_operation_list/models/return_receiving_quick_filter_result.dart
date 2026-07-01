import 'package:flutter/foundation.dart';

@immutable
class ReturnReceivingQuickFilterResult {
  const ReturnReceivingQuickFilterResult.cleared() : cleared = true, status = null;

  const ReturnReceivingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
