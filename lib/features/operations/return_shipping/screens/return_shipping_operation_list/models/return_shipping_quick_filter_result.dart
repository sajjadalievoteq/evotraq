import 'package:flutter/foundation.dart';

@immutable
class ReturnShippingQuickFilterResult {
  const ReturnShippingQuickFilterResult.cleared() : cleared = true, status = null;

  const ReturnShippingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
