import 'package:equatable/equatable.dart';

/// One commissioning-throughput window (buckets + total) cached for a range toggle.
class ThroughputWindow extends Equatable {
  const ThroughputWindow({
    required this.buckets,
    required this.total,
  });

  final Map<int, int> buckets;
  final int total;

  @override
  List<Object?> get props => [buckets, total];
}
