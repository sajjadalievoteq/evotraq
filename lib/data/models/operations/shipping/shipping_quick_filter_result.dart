import 'package:flutter/foundation.dart';

@immutable
class ShippingQuickFilterResult {
  const ShippingQuickFilterResult.cleared() : cleared = true, status = null;

  const ShippingQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
