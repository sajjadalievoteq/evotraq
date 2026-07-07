import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

/// Shared transport / logistics detail card for shipment-family operations.
class OperationDetailTransportCard extends StatelessWidget {
  const OperationDetailTransportCard({
    super.key,
    required this.title,
    this.carrier,
    this.trackingNumber,
    this.billOfLadingNumber,
    this.purchaseOrderNumber,
    this.despatchAdviceNumber,
    this.gincNumber,
    this.receivingAdviceNumber,
    this.receivingAdviceLabel = 'Receiving Advice',
    this.extraChildren = const [],
  });

  final String title;
  final String? carrier;
  final String? trackingNumber;
  final String? billOfLadingNumber;
  final String? purchaseOrderNumber;
  final String? despatchAdviceNumber;
  final String? gincNumber;
  final String? receivingAdviceNumber;
  final String receivingAdviceLabel;
  final List<Widget> extraChildren;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: title,
      children: [
        if (carrier?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'Carrier', value: carrier!),
        if (trackingNumber?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'Tracking Number', value: trackingNumber!),
        if (billOfLadingNumber?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'Bill of Lading',
            value: billOfLadingNumber!,
          ),
        if (purchaseOrderNumber?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'Purchase Order',
            value: purchaseOrderNumber!,
          ),
        if (despatchAdviceNumber?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'Despatch Advice',
            value: despatchAdviceNumber!,
          ),
        if (gincNumber?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'Consignment Reference (GINC)',
            value: gincNumber!,
          ),
        if (receivingAdviceNumber?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: receivingAdviceLabel,
            value: receivingAdviceNumber!,
          ),
        ...extraChildren,
      ],
    );
  }
}
