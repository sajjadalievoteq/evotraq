import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';

class CancelShippingPageResponse {
  const CancelShippingPageResponse({
    required this.operations,
    required this.page,
    required this.size,
    required this.count,
    required this.total,
    required this.totalPages,
  });

  final List<CancelShippingResponse> operations;
  final int page;
  final int size;
  final int count;
  final int total;
  final int totalPages;

  factory CancelShippingPageResponse.fromJson(Map<String, dynamic> json) {
    final ops = (json['operations'] as List? ?? [])
        .map((op) => CancelShippingResponse.fromJson(op as Map<String, dynamic>))
        .toList();
    return CancelShippingPageResponse(
      operations: ops,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? ops.length,
      count: (json['count'] as num?)?.toInt() ?? ops.length,
      total: (json['total'] as num?)?.toInt() ?? ops.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
