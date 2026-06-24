import 'package:flutter/foundation.dart';

@immutable
class SsccQuickFilterResult {
  const SsccQuickFilterResult.cleared()
      : cleared = true,
        status = null,
        containerType = null;

  const SsccQuickFilterResult.applied({
    this.status,
    this.containerType,
  }) : cleared = false;

  final bool cleared;
  final String? status;
  final String? containerType;
}
