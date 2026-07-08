import 'package:flutter/foundation.dart';

@immutable
class OperationQuickFilterResult {
  const OperationQuickFilterResult.cleared()
      : cleared = true,
        status = null;

  const OperationQuickFilterResult.applied({this.status}) : cleared = false;

  final bool cleared;
  final String? status;
}
