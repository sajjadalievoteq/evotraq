import 'package:traqtrace_app/data/models/operations/shared/pharma_return_context.dart';

PharmaReturnContext? pharmaReturnContextFromExtra(Object? extra) {
  if (extra is! Map<String, dynamic>) return null;
  try {
    return PharmaReturnContext.fromExtra(extra);
  } catch (_) {
    return null;
  }
}
