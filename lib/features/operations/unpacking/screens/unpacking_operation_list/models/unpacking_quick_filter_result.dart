import 'package:flutter/foundation.dart';

@immutable
class UnpackingQuickFilterResult {
  const UnpackingQuickFilterResult.cleared() : cleared = true, status = null;

  const UnpackingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
