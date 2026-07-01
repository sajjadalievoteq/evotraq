import 'package:flutter/foundation.dart';

@immutable
class DecommissioningQuickFilterResult {
  const DecommissioningQuickFilterResult.cleared() : cleared = true, status = null;

  const DecommissioningQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
