import 'package:flutter/foundation.dart';

@immutable
class PackingQuickFilterResult {
  const PackingQuickFilterResult.cleared() : cleared = true, status = null;

  const PackingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
