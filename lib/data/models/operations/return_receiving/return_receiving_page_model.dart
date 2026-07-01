import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';

class ReturnReceivingPage {
  const ReturnReceivingPage({
    required this.operations,
    required this.total,
    required this.totalPages,
  });

  final List<ReturnReceivingResponse> operations;
  final int total;
  final int totalPages;
}
