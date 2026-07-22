import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/models/commissioning_detail_data.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

Future<Map<String, ItemStatus>> _fetchCommissioningItemStatuses(
  CommissioningBatch? batch,
  List<CommissioningBatchItem> items,
) async {
  final successItems = items
      .where((i) => i.success && i.serialNumber.isNotEmpty)
      .toList();
  if (successItems.isEmpty) return {};

  final sgtinService = getIt<SGTINService>();
  final result = <String, ItemStatus>{};
  final lot = batch?.batchLotNumber?.trim();
  final gtinCode = batch?.gtinCode?.trim();

  if (lot != null && lot.isNotEmpty) {
    try {
      final sgtins = await sgtinService.findSGTINsByBatchLotNumber(lot);
      for (final sgtin in sgtins) {
        if (gtinCode != null &&
            gtinCode.isNotEmpty &&
            sgtin.gtinCode != gtinCode) {
          continue;
        }
        result[sgtin.serialNumber] = sgtin.status;
      }
    } catch (_) {
      
    }
  }

  final missing = successItems
      .where((item) => !result.containsKey(item.serialNumber))
      .toList();
  if (missing.isEmpty) return result;

  const chunkSize = 8;
  for (var i = 0; i < missing.length; i += chunkSize) {
    final chunk = missing.skip(i).take(chunkSize);
    final entries = await Future.wait(
      chunk.map((item) async {
        try {
          final sgtin =
              await sgtinService.getSGTINBySerialNumber(item.serialNumber);
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

Future<CommissioningDetailData> _loadCommissioningDetail(String id) async {
  final service = getIt<CommissioningOperationService>();
  final results = await Future.wait([
    service.getBatch(id),
    service.getBatchItems(id),
  ]);
  final batch = results[0] as CommissioningBatch?;
  final items = (results[1] as List<CommissioningBatchItem>?) ?? [];
  final itemStatuses = await _fetchCommissioningItemStatuses(batch, items);
  return CommissioningDetailData(
    batch: batch,
    items: items,
    itemStatuses: itemStatuses,
  );
}

final _commissioningDetailConfig =
    OperationDetailScreenConfig<CommissioningDetailData>(
  loader: _loadCommissioningDetail,
  contentBuilder: (
    context, {
    required awaitingSelection,
    required listLoading,
    required isLoading,
    required errorMessage,
    required operation,
    required onRetry,
    onOperationUpdated,
  }) =>
      CommissioningDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    batch: operation?.batch,
    items: operation?.items ?? const [],
    itemStatuses: operation?.itemStatuses ?? const {},
    onRetry: onRetry,
  ),
  titleBuilder: (data) =>
      data.batch?.commissioningReference ?? 'Commissioning Detail',
  listRoute: Constants.opCommissioningRoute,
  defaultTitle: 'Commissioning Detail',
  fallbackErrorMessage:
      'Unable to load this commissioning batch. '
      'Check your connection and tap Retry.',
  drawer: const AppDrawer(),
);

class CommissioningOperationDetailScreen
    extends GenericOperationDetailScreen<CommissioningDetailData> {
  CommissioningOperationDetailScreen({
    super.key,
    String? batchId,
    String? operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(
          operationId: batchId ?? operationId,
          config: _commissioningDetailConfig,
        );
}
