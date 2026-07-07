/// Generic paginated operation list wrapper shared by all operation services.
class OperationPage<T> {
  const OperationPage({
    required this.operations,
    required this.page,
    required this.size,
    required this.count,
    required this.total,
    required this.totalPages,
  });

  final List<T> operations;
  final int page;
  final int size;
  final int count;
  final int total;
  final int totalPages;

  bool get hasMore => page + 1 < totalPages;

  factory OperationPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final ops = (json['operations'] as List? ?? [])
        .map((op) => fromJsonT(op as Map<String, dynamic>))
        .toList();
    final page = (json['page'] as num?)?.toInt() ?? 0;
    final size = (json['size'] as num?)?.toInt() ?? ops.length;
    final count = (json['count'] as num?)?.toInt() ?? ops.length;
    final total = (json['total'] as num?)?.toInt() ??
        (json['totalElements'] as num?)?.toInt() ??
        ops.length;
    final totalPages = (json['totalPages'] as num?)?.toInt() ??
        (size > 0 ? (total / size).ceil() : (total > 0 ? 1 : 0));

    return OperationPage<T>(
      operations: ops,
      page: page,
      size: size,
      count: count,
      total: total,
      totalPages: totalPages,
    );
  }

  OperationPage<U> map<U>(U Function(T value) transform) {
    return OperationPage<U>(
      operations: operations.map(transform).toList(),
      page: page,
      size: size,
      count: count,
      total: total,
      totalPages: totalPages,
    );
  }
}
