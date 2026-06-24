import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';

class PackingPageResponse {
  const PackingPageResponse({
    required this.operations,
    required this.page,
    required this.size,
    required this.count,
    required this.total,
    required this.totalPages,
  });

  final List<PackingResponse> operations;
  final int page;
  final int size;
  final int count;
  final int total;
  final int totalPages;

  factory PackingPageResponse.fromJson(Map<String, dynamic> json) {
    final ops = (json['operations'] as List? ?? [])
        .map((op) => PackingResponse.fromJson(op as Map<String, dynamic>))
        .toList();
    return PackingPageResponse(
      operations: ops,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? ops.length,
      count: (json['count'] as num?)?.toInt() ?? ops.length,
      total: (json['total'] as num?)?.toInt() ?? ops.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
