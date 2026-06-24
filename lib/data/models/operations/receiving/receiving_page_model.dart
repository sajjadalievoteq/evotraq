import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';

class ReceivingPage {
  const ReceivingPage({
    required this.operations,
    required this.total,
    required this.totalPages,
  });

  final List<ReceivingResponse> operations;
  final int total;
  final int totalPages;
}
