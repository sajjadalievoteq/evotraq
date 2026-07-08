import 'package:traqtrace_app/data/models/operations/shared/operation.dart';

extension OperationMetadata on Operation {
  String? get sourceGLN => metadataString('sourceGLN');
  String? get destinationGLN => metadataString('destinationGLN');
  String? get receivingGLN => metadataString('receivingGLN');
  String? get locationGLN =>
      metadataString('locationGLN') ?? primaryGln;
  String? get packingLine => metadataString('packingLine');
  String? get unpackingLine => metadataString('unpackingLine');
  String? get reason => metadataString('reason');
  String? get disposition => metadataString('disposition');
  String? get carrier => metadataString('carrier');
  String? get trackingNumber => metadataString('trackingNumber');
  String? get cancelReason => metadataString('cancelReason');
  String? get originalShippingReference =>
      metadataString('originalShippingReference');
  String? get originalReceivingReference =>
      metadataString('originalReceivingReference');
  String? get parentContainerId => metadataString('parentContainerId');
  String? get gtinCode => metadataString('gtinCode');
  String? get batchLotNumber => metadataString('batchLotNumber');
  String? get workOrderNumber => metadataString('workOrderNumber');
  String? get batchNumber => metadataString('batchNumber');
  String? get productionOrder => metadataString('productionOrder');
  String? get operatorId => metadataString('operatorId');
  int? get failedCount => metadataInt('failedCount');
  int? get totalCommissioned => metadataInt('totalCommissioned');
  int? get totalFailedCount => metadataInt('totalFailed');
  String? get commissioningBatchStatus =>
      metadataString('commissioningBatchStatus');

  String? get navigableOperationId {
    if (operationId != null && operationId!.isNotEmpty) {
      return operationId;
    }
    if (eventIds != null && eventIds!.isNotEmpty) {
      return eventIds!.first;
    }
    return null;
  }

  int get itemCount => processedItemCount ?? epcList?.length ?? 0;
}
