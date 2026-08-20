import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_batch_models.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';

class CommissioningDetailData {
  const CommissioningDetailData({
    required this.batch,
    required this.items,
    required this.itemStatuses,
  });

  final CommissioningBatch? batch;
  final List<CommissioningBatchItem> items;
  final Map<String, ItemStatus> itemStatuses;
}
