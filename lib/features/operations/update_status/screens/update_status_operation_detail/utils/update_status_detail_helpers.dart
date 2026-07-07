import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';

class UpdateStatusDetailHelpers {
  UpdateStatusDetailHelpers._();

  static bool hasComments(UpdateStatusResponse operation) {
    return operation.comments != null && operation.comments!.isNotEmpty;
  }
}
