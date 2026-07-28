import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/models/commissioning_detail_data.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_detail_cubit.dart';

class CommissioningDetailCubit extends OperationDetailCubit<CommissioningDetailData> {
  CommissioningDetailCubit({
    required CommissioningOperationService commissioningService,
    required SGTINService sgtinService,
    required String fallbackErrorMessage,
  }) : super(
          fallbackErrorMessage: fallbackErrorMessage,
          fetchDetail: (id) async {
            final results = await Future.wait([
              commissioningService.getBatch(id),
              commissioningService.getBatchItems(id),
            ]);
            final batch = results[0] as CommissioningBatch?;
            final items = (results[1] as List<CommissioningBatchItem>?) ?? [];
            final itemStatuses = await _fetchCommissioningItemStatuses(
              sgtinService: sgtinService,
              batch: batch,
              items: items,
            );
            return CommissioningDetailData(
              batch: batch,
              items: items,
              itemStatuses: itemStatuses,
            );
          },
        );
}

Future<Map<String, ItemStatus>> _fetchCommissioningItemStatuses({
  required SGTINService sgtinService,
  required CommissioningBatch? batch,
  required List<CommissioningBatchItem> items,
}) async {
  final successItems = items.where((i) => i.success && i.serialNumber.isNotEmpty).toList();
  if (successItems.isEmpty) return {};

  final result = <String, ItemStatus>{};
  final lot = batch?.batchLotNumber?.trim();
  final gtinCode = batch?.gtinCode?.trim();

  if (lot != null && lot.isNotEmpty) {
    try {
      final sgtins = await sgtinService.findSGTINsByBatchLotNumber(lot);
      for (final sgtin in sgtins) {
        if (gtinCode != null && gtinCode.isNotEmpty && sgtin.gtinCode != gtinCode) {
          continue;
        }
        result[sgtin.serialNumber] = sgtin.status;
      }
    } catch (_) {}
  }

  final missing = successItems.where((item) => !result.containsKey(item.serialNumber)).toList();
  if (missing.isEmpty) return result;

  const chunkSize = 8;
  for (var i = 0; i < missing.length; i += chunkSize) {
    final chunk = missing.skip(i).take(chunkSize);
    final entries = await Future.wait(
      chunk.map((item) async {
        try {
          final sgtin = await sgtinService.getSGTINBySerialNumber(item.serialNumber);
          return MapEntry(item.serialNumber, sgtin.status);
        } catch (_) {
          return null;
        }
      }),
    );
    for (final entry in entries.whereType<MapEntry<String, ItemStatus>>()) {
      result[entry.key] = entry.value;
    }
  }

  return result;
}
