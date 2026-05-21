import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Batch and date information card for the SGTIN detail / create form.
///
/// Expiry, production, and best-before dates are editable only when creating
/// a new SGTIN (inherited from batch on existing instances). Extended expiry
/// (AI 7003) is always read-only.
class SgtinBatchDateCard extends StatelessWidget {
  const SgtinBatchDateCard({
    super.key,
    required this.borderColor,
    required this.isCreating,
    required this.onPickExpiry,
    required this.onPickProduction,
    required this.onPickBestBefore,
    this.expiryDate,
    this.productionDate,
    this.bestBeforeDate,
    this.expiryDateTime,
  });

  final Color borderColor;
  final bool isCreating;
  final VoidCallback onPickExpiry;
  final VoidCallback onPickProduction;
  final VoidCallback onPickBestBefore;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  /// Extended expiry (AI 7003) from a loaded SGTIN record — always read-only.
  final DateTime? expiryDateTime;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Batch & Date Information',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1DatePickerField(
            label: 'Expiry Date *',
            value: expiryDate,
            // Spec: inherited from batch; read-only on existing instances.
            onTap: isCreating ? onPickExpiry : null,
          ),
          const SizedBox(height: 12),
          Gs1DatePickerField(
            label: 'Production Date',
            value: productionDate,
            onTap: isCreating ? onPickProduction : null,
          ),
          const SizedBox(height: 12),
          Gs1DatePickerField(
            label: 'Best Before Date',
            value: bestBeforeDate,
            onTap: isCreating ? onPickBestBefore : null,
          ),
          if (expiryDateTime != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Extended Expiry',
              sgtinFormatDt(expiryDateTime),
            ),
          ],
        ],
      ),
    );
  }
}
