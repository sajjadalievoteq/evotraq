import 'package:flutter/foundation.dart';

@immutable
class CancelShippingQuickFilterResult {
  const CancelShippingQuickFilterResult.cleared() : cleared = true, status = null;

  const CancelShippingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
