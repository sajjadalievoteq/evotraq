import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_detail_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/models/commissioning_detail_data.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _commissioningDetailConfig =
    OperationDetailScreenConfig<CommissioningDetailData>(
  createCubit: (fallbackErrorMessage) => CommissioningDetailCubit(
    commissioningService: getIt<CommissioningOperationService>(),
    sgtinService: getIt<SGTINService>(),
    fallbackErrorMessage: fallbackErrorMessage,
  ),
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
