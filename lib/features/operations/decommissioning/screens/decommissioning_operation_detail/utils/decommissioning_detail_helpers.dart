import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';

class DecommissioningDetailHelpers {
  DecommissioningDetailHelpers._();

  static bool hasComments(DecommissioningResponse operation) {
    return operation.comments != null && operation.comments!.isNotEmpty;
  }
}
