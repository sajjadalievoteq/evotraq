import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/data/services/operations/update_status/update_status_operation_service.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/widgets/update_status_detail_content.dart';

final _updateStatusDetailConfig =
    OperationDetailScreenConfig<UpdateStatusResponse>(
  loader: (id) =>
      getIt<UpdateStatusOperationService>().getUpdateStatusOperation(id),
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
      UpdateStatusDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.decommissioningReference ?? 'Update Status Detail',
  listRoute: Constants.opUpdateStatusRoute,
  defaultTitle: 'Update Status Detail',
  fallbackErrorMessage:
      'Unable to load this Update Status operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

/// Screen to display update status operation details.
class UpdateStatusOperationDetailScreen
    extends GenericOperationDetailScreen<UpdateStatusResponse> {
  UpdateStatusOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _updateStatusDetailConfig);
}
