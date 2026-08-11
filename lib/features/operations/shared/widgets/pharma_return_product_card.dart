import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/role_gate.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/operations/receiving/cubit/receiving_acceptance_cubit.dart';
import 'package:traqtrace_app/data/models/operations/shared/pharma_return_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_context_builder.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_eligibility.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_row.dart';

class PharmaReturnProductCard extends StatelessWidget {
  const PharmaReturnProductCard({
    super.key,
    this.gtin,
    this.lotNumber,
    this.expiryDate,
    this.quantity,
    this.productDescription,
    this.epcs = const [],
    this.returnReason,
    this.showReturnReason = false,
  });

  final String? gtin;
  final String? lotNumber;
  final DateTime? expiryDate;
  final int? quantity;
  final String? productDescription;
  final List<String> epcs;
  final String? returnReason;
  final bool showReturnReason;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product & Serials',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (productDescription != null && productDescription!.isNotEmpty)
              OperationDetailRow(
                label: 'Description',
                value: productDescription!,
              ),
            if (gtin != null) OperationDetailRow(label: 'GTIN', value: gtin!),
            if (lotNumber != null)
              OperationDetailRow(label: 'Lot', value: lotNumber!),
            if (expiryDate != null)
              OperationDetailRow(
                label: 'Expiry',
                value: dateFormat.format(expiryDate!.toLocal()),
              ),
            if (quantity != null)
              OperationDetailRow(label: 'Quantity', value: quantity.toString()),
            if (showReturnReason && returnReason != null)
              OperationDetailRow(
                label: 'Reason for Return',
                value: returnReason!,
              ),
            if (epcs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'SGTINs / Serials (${epcs.length})',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              const SizedBox(height: 4),
              ...epcs
                  .take(5)
                  .map(
                    (epc) => Text(epc, style: const TextStyle(fontSize: 12)),
                  ),
              if (epcs.length > 5)
                Text(
                  '+ ${epcs.length - 5} more',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
