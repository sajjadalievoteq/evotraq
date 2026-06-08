import 'package:flutter/foundation.dart';

@immutable
class CommissioningQuickFilterResult {
  const CommissioningQuickFilterResult.cleared() : cleared = true, status = null;

  const CommissioningQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
