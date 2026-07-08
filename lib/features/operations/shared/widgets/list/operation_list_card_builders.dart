import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/text_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_batch_status_utils.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';

abstract final class OperationListCardBuilders {
  static Widget shippingCard({
    required ShippingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (operation.destinationGLN != null)
        OperationListCardRow(
          text: 'To: ${operation.destinationGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
    ];

    final carrierTracking = _carrierTrackingRow(
      operation.carrier,
      operation.trackingNumber,
    );
    if (carrierTracking != null) rows.add(carrierTracking);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel:
            '${operation.shippedEpcsCount ?? operation.epcList?.length ?? 0} EPCs',
      ),
      title: operation.shippingReference ?? 'Shipping Operation',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget receivingCard({
    required ReceivingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (operation.receivingGLN != null)
        OperationListCardRow(
          text: 'To: ${operation.receivingGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
    ];

    final carrierTracking = _carrierTrackingRow(
      operation.carrier,
      operation.trackingNumber,
    );
    if (carrierTracking != null) rows.add(carrierTracking);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel:
            '${operation.processedEpcsCount ?? operation.epcList?.length ?? 0} EPCs',
      ),
      title: operation.receivingReference ?? 'Receiving Operation',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget returnShippingCard({
    required ReturnShippingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (operation.destinationGLN != null)
        OperationListCardRow(
          text: 'To: ${operation.destinationGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
    ];

    final carrierTracking = _carrierTrackingRow(
      operation.carrier,
      operation.trackingNumber,
    );
    if (carrierTracking != null) rows.add(carrierTracking);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel:
            '${operation.shippedEpcsCount ?? operation.epcList?.length ?? 0} EPCs',
      ),
      title: operation.returnReference ?? 'Return Shipping',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget returnReceivingCard({
    required ReturnReceivingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (operation.receivingGLN != null)
        OperationListCardRow(
          text: 'To: ${operation.receivingGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
    ];

    final carrierTracking = _carrierTrackingRow(
      operation.carrier,
      operation.trackingNumber,
    );
    if (carrierTracking != null) rows.add(carrierTracking);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel:
            '${operation.processedEpcsCount ?? operation.epcList?.length ?? 0} EPCs',
      ),
      title: operation.returnReceivingReference ?? 'Return Receiving',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget cancelShippingCard({
    required CancelShippingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (operation.destinationGLN != null)
        OperationListCardRow(
          text: 'To: ${operation.destinationGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
      if (operation.cancelReason != null && operation.cancelReason!.isNotEmpty)
        OperationListCardRow(
          text: operation.cancelReason!,
          iconAsset: AppAssets.iconDocument,
          iconColor: Colors.orange,
          maxLines: 2,
          fontSize: 12,
        ),
    ];

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel:
            '${operation.cancelledEpcsCount ?? operation.epcList?.length ?? 0} EPCs',
      ),
      title: operation.cancelShippingReference ?? 'Cancel Shipping',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget cancelReceivingCard({
    required CancelReceivingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (operation.receivingGLN != null)
        OperationListCardRow(
          text: 'To: ${operation.receivingGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
      if (operation.cancelReason != null && operation.cancelReason!.isNotEmpty)
        OperationListCardRow(
          text: operation.cancelReason!,
          iconAsset: AppAssets.iconDocument,
          iconColor: Colors.orange,
          maxLines: 2,
          fontSize: 12,
        ),
    ];

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel:
            '${operation.cancelledEpcsCount ?? operation.epcList?.length ?? 0} EPCs',
      ),
      title: operation.cancelReceivingReference ?? 'Cancel Receiving',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget packingCard({
    required PackingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.parentContainerId != null)
        OperationListCardRow(
          text: 'Container: ${operation.parentContainerId}',
          iconAsset: AppAssets.iconPackage,
          iconColor: Colors.brown,
        ),
      if (operation.packingLocationGLN != null)
        OperationListCardRow(
          text: 'Location: ${operation.packingLocationGLN}',
          iconAsset: AppAssets.iconGln,
          iconColor: Colors.blue,
        ),
    ];

    final productionRow = _workOrderBatchRow(
      operation.workOrderNumber,
      operation.batchNumber,
    );
    if (productionRow != null) rows.add(productionRow);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.packedItemsCount ?? 0} items',
        countAsBadge: true,
      ),
      title: operation.packingReference ?? 'Packing Operation',
      rows: rows,
      footerLeft: '${operation.packedItemsCount ?? 0} items packed',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget unpackingCard({
    required UnpackingResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.parentContainerId != null)
        OperationListCardRow(
          text: 'Container: ${operation.parentContainerId}',
          iconAsset: AppAssets.iconPackage,
          iconColor: Colors.brown,
        ),
      if (operation.unpackingLocationGLN != null)
        OperationListCardRow(
          text: 'Location: ${operation.unpackingLocationGLN}',
          iconAsset: AppAssets.iconGln,
          iconColor: Colors.blue,
        ),
    ];

    final productionRow = _workOrderBatchRow(
      operation.workOrderNumber,
      operation.batchNumber,
    );
    if (productionRow != null) rows.add(productionRow);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.unpackedItemsCount ?? 0} items',
        countAsBadge: true,
      ),
      title: operation.unpackingReference ?? 'Unpacking Operation',
      rows: rows,
      footerLeft: '${operation.unpackedItemsCount ?? 0} items unpacked',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget updateStatusCard({
    required UpdateStatusResponse operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.locationGLN != null)
        OperationListCardRow(
          text: operation.locationGLN!,
          iconAsset: AppAssets.iconMapPin,
          iconColor: isSelected ? Colors.white70 : Colors.grey,
        ),
    ];

    final footerRows = <Widget>[
      if (operation.disposition != null) ...[
        Text(
          'Status: ${TextUtils().capitalize(UpdateStatusDisposition.labelFor(operation.disposition))}',
          style: TextStyle(
            color: isSelected ? Colors.white70 : Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ],
      if (operation.processedAt != null) ...[
        if (operation.disposition != null) const SizedBox(height: 8),
        Text(
          DateFormat.yMMMd().add_jm().format(operation.processedAt!.toLocal()),
          style: TextStyle(
            color: isSelected ? Colors.white70 : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    ];

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.itemCount ?? 0} EPCs',
      ),
      title: operation.decommissioningReference ?? 'Update Status Operation',
      rows: rows,
      footerRows: footerRows,
    );
  }

  static Widget commissioningCard({
    required CommissioningBatch operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final rows = <OperationListCardRow>[
      if (operation.gtinCode != null)
        OperationListCardRow(
          text: 'GTIN: ${operation.gtinCode}',
          iconAsset: AppAssets.iconPackage,
          iconColor: Colors.orange,
        ),
      if (operation.batchLotNumber != null)
        OperationListCardRow(
          text: 'Lot #: ${operation.batchLotNumber}',
          iconAsset: AppAssets.iconQr,
          iconColor: Colors.purple,
        ),
      if (operation.commissioningLocationGLN != null)
        OperationListCardRow(
          text: 'Location: ${operation.commissioningLocationGLN}',
          iconAsset: AppAssets.iconGln,
          iconColor: Colors.blue,
        ),
    ];

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: CommissioningBatchStatusUtils.color(operation.status),
        label: CommissioningBatchStatusUtils.label(operation.status),
        countLabel: '${operation.totalCommissioned} items',
        countAsBadge: true,
      ),
      title: operation.commissioningReference ??
          (operation.gtinCode != null
              ? 'GTIN: ${operation.gtinCode}'
              : 'Commissioning Operation'),
      rows: rows,
      footerRows: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconCheck,
                  size: 14,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${operation.totalCommissioned} commissioned',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (operation.totalFailed > 0) ...[
                  const SizedBox(width: 12),
                  TraqIcon(
                    AppAssets.iconAlert,
                    size: 14,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${operation.totalFailed} failed',
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            if (operation.createdAt != null)
              Text(
                OperationListCard.formatTimestamp(operation.createdAt)!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  static Widget forOperation({
    required Operation operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return switch (operation.operationType) {
      OperationType.shipping => _cardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Shipping Operation',
            countSuffix: 'EPCs',
            fromLabel: operation.sourceGLN,
            toLabel: operation.destinationGLN,
          ),
      OperationType.receiving => _cardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Receiving Operation',
            countSuffix: 'EPCs',
            fromLabel: operation.sourceGLN,
            toLabel: operation.receivingGLN,
            toPrefix: 'Receiving: ',
          ),
      OperationType.returnShipping => _cardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Return Shipping Operation',
            countSuffix: 'EPCs',
            fromLabel: operation.sourceGLN,
            toLabel: operation.destinationGLN,
          ),
      OperationType.returnReceiving => _cardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Return Receiving Operation',
            countSuffix: 'EPCs',
            fromLabel: operation.sourceGLN,
            toLabel: operation.receivingGLN,
            toPrefix: 'Return Receiving: ',
          ),
      OperationType.cancelShipping => _cancelCardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Cancel Shipping Operation',
          ),
      OperationType.cancelReceiving => _cancelCardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Cancel Receiving Operation',
            receivingStyle: true,
          ),
      OperationType.packing => _productionCardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Packing Operation',
            lineLabel: operation.packingLine,
          ),
      OperationType.unpacking => _productionCardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
            defaultTitle: 'Unpacking Operation',
            lineLabel: operation.unpackingLine,
          ),
      OperationType.updateStatus => _updateStatusCardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
          ),
      OperationType.commissioning => _commissioningCardFromOperation(
            operation: operation,
            isSelected: isSelected,
            onTap: onTap,
          ),
    };
  }

  static Widget _cardFromOperation({
    required Operation operation,
    required bool isSelected,
    required VoidCallback onTap,
    required String defaultTitle,
    required String countSuffix,
    String? fromLabel,
    String? toLabel,
    String toPrefix = 'To: ',
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (fromLabel != null)
        OperationListCardRow(
          text: 'From: $fromLabel',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if (toLabel != null)
        OperationListCardRow(
          text: '$toPrefix$toLabel',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
    ];
    final carrierTracking =
        _carrierTrackingRow(operation.carrier, operation.trackingNumber);
    if (carrierTracking != null) rows.add(carrierTracking);

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.itemCount} $countSuffix',
      ),
      title: operation.operationReference ?? defaultTitle,
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget _cancelCardFromOperation({
    required Operation operation,
    required bool isSelected,
    required VoidCallback onTap,
    required String defaultTitle,
    bool receivingStyle = false,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.sourceGLN != null)
        OperationListCardRow(
          text: 'From: ${operation.sourceGLN}',
          iconAsset: AppAssets.iconAirplaneUp,
          iconColor: Colors.green,
        ),
      if ((receivingStyle ? operation.receivingGLN : operation.destinationGLN) !=
          null)
        OperationListCardRow(
          text:
              '${receivingStyle ? 'Receiving: ' : 'To: '}${receivingStyle ? operation.receivingGLN : operation.destinationGLN}',
          iconAsset: AppAssets.iconAirplaneD,
          iconColor: Colors.red,
        ),
      if (operation.cancelReason != null)
        OperationListCardRow(
          text: operation.cancelReason!,
          iconAsset: AppAssets.iconAlert,
          iconColor: Colors.orange,
          maxLines: 2,
        ),
    ];

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.itemCount} EPCs',
      ),
      title: operation.operationReference ?? defaultTitle,
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget _productionCardFromOperation({
    required Operation operation,
    required bool isSelected,
    required VoidCallback onTap,
    required String defaultTitle,
    String? lineLabel,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.parentContainerId != null)
        OperationListCardRow(
          text: 'Container: ${operation.parentContainerId}',
          iconAsset: AppAssets.iconPackage,
          iconColor: Colors.blue,
        ),
      if (operation.locationGLN != null)
        OperationListCardRow(
          text: 'GLN: ${operation.locationGLN}',
          iconAsset: AppAssets.iconGln,
          iconColor: Colors.teal,
        ),
    ];
    final workOrderBatch =
        _workOrderBatchRow(operation.workOrderNumber, operation.batchNumber);
    if (workOrderBatch != null) rows.add(workOrderBatch);
    if (lineLabel != null) {
      rows.add(OperationListCardRow(
        text: lineLabel,
        iconAsset: AppAssets.iconList,
        iconColor: Colors.indigo,
      ));
    }

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.itemCount} items',
      ),
      title: operation.operationReference ?? defaultTitle,
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget _updateStatusCardFromOperation({
    required Operation operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = operation.status ?? OperationStatus.failed;
    final rows = <OperationListCardRow>[
      if (operation.locationGLN != null)
        OperationListCardRow(
          text: 'GLN: ${operation.locationGLN}',
          iconAsset: AppAssets.iconGln,
          iconColor: Colors.blue,
        ),
      if (operation.disposition != null)
        OperationListCardRow(
          text: UpdateStatusDisposition.labelFor(operation.disposition),
          iconAsset: AppAssets.iconTag,
          iconColor: Colors.purple,
        ),
      if (operation.reason != null)
        OperationListCardRow(
          text: operation.reason!,
          iconAsset: AppAssets.iconAlert,
          iconColor: Colors.orange,
          maxLines: 2,
        ),
    ];

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: OperationStatusUtils.colorFor(status),
        label: OperationStatusUtils.label(status),
        countLabel: '${operation.itemCount} EPCs',
      ),
      title: operation.operationReference ?? 'Update Status Operation',
      rows: rows,
      footerLeft: '${operation.eventIds?.length ?? 0} events',
      footerRight: OperationListCard.formatTimestamp(operation.processedAt),
    );
  }

  static Widget _commissioningCardFromOperation({
    required Operation operation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final batchStatusName = operation.commissioningBatchStatus;
    CommissioningBatchStatus batchStatus = CommissioningBatchStatus.pending;
    if (batchStatusName != null) {
      batchStatus = CommissioningBatchStatus.values.firstWhere(
        (s) => s.name == batchStatusName,
        orElse: () => CommissioningBatchStatus.pending,
      );
    }

    final rows = <OperationListCardRow>[
      if (operation.gtinCode != null)
        OperationListCardRow(
          text: 'GTIN: ${operation.gtinCode}',
          iconAsset: AppAssets.iconPackage,
          iconColor: Colors.orange,
        ),
      if (operation.batchLotNumber != null)
        OperationListCardRow(
          text: 'Lot #: ${operation.batchLotNumber}',
          iconAsset: AppAssets.iconQr,
          iconColor: Colors.purple,
        ),
      if (operation.locationGLN != null)
        OperationListCardRow(
          text: 'Location: ${operation.locationGLN}',
          iconAsset: AppAssets.iconGln,
          iconColor: Colors.blue,
        ),
    ];

    final commissioned = operation.totalCommissioned ?? operation.itemCount;
    final failed = operation.totalFailedCount ?? 0;

    return OperationListCard(
      isSelected: isSelected,
      onTap: onTap,
      status: OperationListCardStatus(
        color: CommissioningBatchStatusUtils.color(batchStatus),
        label: CommissioningBatchStatusUtils.label(batchStatus),
        countLabel: '$commissioned items',
        countAsBadge: true,
      ),
      title: operation.operationReference ??
          (operation.gtinCode != null
              ? 'GTIN: ${operation.gtinCode}'
              : 'Commissioning Operation'),
      rows: rows,
      footerRows: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconCheck,
                  size: 14,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '$commissioned commissioned',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (failed > 0) ...[
                  const SizedBox(width: 12),
                  TraqIcon(
                    AppAssets.iconAlert,
                    size: 14,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$failed failed',
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            if (operation.processedAt != null)
              Text(
                OperationListCard.formatTimestamp(operation.processedAt)!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  static OperationListCardRow? _carrierTrackingRow(
    String? carrier,
    String? tracking,
  ) {
    final hasCarrier = carrier != null && carrier.isNotEmpty;
    final hasTracking = tracking != null && tracking.isNotEmpty;
    if (!hasCarrier && !hasTracking) return null;

    if (hasCarrier && hasTracking) {
      return OperationListCardRow(
        text: carrier,
        iconAsset: AppAssets.iconShipment,
        iconColor: Colors.orange,
        secondaryText: tracking,
        secondaryIconAsset: AppAssets.iconQr,
        secondaryIconColor: Colors.blue,
      );
    }
    if (hasCarrier) {
      return OperationListCardRow(
        text: carrier,
        iconAsset: AppAssets.iconShipment,
        iconColor: Colors.orange,
      );
    }
    return OperationListCardRow(
      text: tracking!,
      iconAsset: AppAssets.iconQr,
      iconColor: Colors.blue,
    );
  }

  static OperationListCardRow? _workOrderBatchRow(
    String? workOrderNumber,
    String? batchNumber,
  ) {
    final hasWorkOrder = workOrderNumber != null;
    final hasBatch = batchNumber != null;
    if (!hasWorkOrder && !hasBatch) return null;

    if (hasWorkOrder && hasBatch) {
      return OperationListCardRow(
        text: 'WO: $workOrderNumber',
        iconAsset: AppAssets.iconList,
        iconColor: Colors.orange,
        secondaryText: 'Batch: $batchNumber',
        secondaryIconAsset: AppAssets.iconSpinner,
        secondaryIconColor: Colors.purple,
      );
    }
    if (hasWorkOrder) {
      return OperationListCardRow(
        text: 'WO: $workOrderNumber',
        iconAsset: AppAssets.iconList,
        iconColor: Colors.orange,
      );
    }
    return OperationListCardRow(
      text: 'Batch: $batchNumber',
      iconAsset: AppAssets.iconSpinner,
      iconColor: Colors.purple,
    );
  }
}
