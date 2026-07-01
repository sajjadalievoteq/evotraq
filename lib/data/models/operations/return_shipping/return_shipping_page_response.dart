import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';

class ReturnShippingPageResponse {
  const ReturnShippingPageResponse({
    required this.operations,
    required this.page,
    required this.size,
    required this.count,
    required this.total,
    required this.totalPages,
  });

  final List<ReturnShippingResponse> operations;
  final int page;
  final int size;
  final int count;
  final int total;
  final int totalPages;

  factory ReturnShippingPageResponse.fromJson(Map<String, dynamic> json) {
    final ops = (json['operations'] as List? ?? [])
        .map((op) => ReturnShippingResponse.fromJson(op as Map<String, dynamic>))
        .toList();
    return ReturnShippingPageResponse(
      operations: ops,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? ops.length,
      count: (json['count'] as num?)?.toInt() ?? ops.length,
      total: (json['total'] as num?)?.toInt() ?? ops.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
