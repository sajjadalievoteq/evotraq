import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_batch_status_utils.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';

/// Single list card used by every operation list screen.
class OperationListCard extends StatelessWidget {
  const OperationListCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final Operation operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final titleColor =
        Gs1ListItemSelectionStyle.primaryTextColor(isSelected);
    final rowColor =
        Gs1ListItemSelectionStyle.mutedColor(isSelected, muted);

    final status = _status();
    final rows = _rows();
    final countLabel = _countLabel();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Gs1ListItemSelectionStyle.cardBackground(context, isSelected),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (countLabel != null)
                    Text(
                      countLabel,
                      style: TextStyle(
                        color: rowColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _title(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              for (final row in rows) ...[
                _RowLine(row: row, color: rowColor),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 4),
              _Footer(
                operation: operation,
                isSelected: isSelected,
                rowColor: rowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title() {
    final ref = operation.operationReference;
    return switch (operation.operationType) {
      OperationType.commissioning =>
        ref ??
            (operation.gtinCode != null
                ? 'GTIN: ${operation.gtinCode}'
                : 'Commissioning Operation'),
      OperationType.returnReceiving => ref ??
          (operation.epcList?.isNotEmpty == true
              ? 'Return Receiving: ${operation.epcList!.first}'
              : 'Return Receiving Operation'),
      OperationType.shipping => ref ?? 'Shipping Operation',
      OperationType.receiving => ref ?? 'Receiving Operation',
      OperationType.returnShipping => ref ?? 'Return Shipping Operation',
      OperationType.cancelShipping => ref ?? 'Cancel Shipping Operation',
      OperationType.cancelReceiving => ref ?? 'Cancel Receiving Operation',
      OperationType.packing => ref ?? 'Packing Operation',
      OperationType.unpacking => ref ?? 'Unpacking Operation',
      OperationType.updateStatus => ref ?? 'Update Status Operation',
    };
  }

  ({Color color, String label}) _status() {
    if (operation.operationType == OperationType.commissioning) {
      final name = operation.commissioningBatchStatus;
      final batchStatus = name == null
          ? CommissioningBatchStatus.pending
          : CommissioningBatchStatus.values.firstWhere(
              (s) => s.name == name,
              orElse: () => CommissioningBatchStatus.pending,
            );
      return (
        color: CommissioningBatchStatusUtils.color(batchStatus),
        label: CommissioningBatchStatusUtils.label(batchStatus),
      );
    }
    final status = operation.status ?? OperationStatus.failed;
    return (
      color: OperationStatusUtils.colorFor(status),
      label: OperationStatusUtils.label(status),
    );
  }

  String? _countLabel() {
    final n = operation.itemCount;
    return switch (operation.operationType) {
      OperationType.commissioning =>
        '${operation.totalCommissioned ?? n} items',
      OperationType.packing || OperationType.unpacking => '$n items',
      _ => '$n EPCs',
    };
  }

  /// Three middle rows — commissioning shows product identity; others use shared fields.
  List<_CardRow> _rows() {
    if (operation.operationType == OperationType.commissioning) {
      return [
        _row(
          'GTIN: ${_orFallback(operation.gtinCode, 'No GTIN')}',
          NavIcons.gtin,
        ),
        _row(
          'Lot #: ${_orFallback(operation.batchLotNumber, 'No lot')}',
          AppAssets.iconQr,
        ),
        _row(
          _commissioningSerialOrLocation(),
          operation.epcList?.isNotEmpty == true
              ? NavIcons.packaging
              : NavIcons.gln,
        ),
      ];
    }

    return [
      _row('Location: ${_sharedLocation()}', NavIcons.gln),
      _row(_sharedItemsLabel(), AppAssets.iconList),
      _row(_sharedProcessedLabel(), AppAssets.iconCalendar),
    ];
  }

  /// Prefer a serial/EPC sample so the card shows what was commissioned.
  String _commissioningSerialOrLocation() {
    final epcs = operation.epcList;
    if (epcs != null && epcs.isNotEmpty) {
      final sample = epcs.first.trim();
      if (sample.isNotEmpty) {
        final more = epcs.length > 1 ? ' (+${epcs.length - 1})' : '';
        return 'Serial: $sample$more';
      }
    }
    return 'Location: ${_sharedLocation()}';
  }

  String _orFallback(String? value, String fallback) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  _CardRow _row(String text, String icon) =>
      _CardRow(text: text, iconAsset: icon);

  /// Any GLN / location present on the shared [Operation] model.
  String _sharedLocation() {
    for (final value in [
      operation.locationGLN,
      operation.sourceGLN,
      operation.destinationGLN,
      operation.receivingGLN,
      operation.primaryGln,
      operation.primaryLocation?.glnCode,
      operation.primaryLocation?.locationName,
    ]) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return 'No location';
  }

  String _sharedItemsLabel() {
    final n = operation.itemCount;
    return switch (operation.operationType) {
      OperationType.commissioning =>
        '${operation.totalCommissioned ?? n} items',
      OperationType.packing || OperationType.unpacking => '$n items',
      _ => '$n EPCs',
    };
  }

  String _sharedProcessedLabel() {
    final ts = formatTimestamp(operation.processedAt);
    if (ts != null) return ts;
    return 'Not yet processed';
  }

  static String? formatTimestamp(DateTime? value) {
    if (value == null) return null;
    return DateFormat('MMM dd, yyyy HH:mm').format(value);
  }
}

class _CardRow {
  const _CardRow({
    required this.text,
    required this.iconAsset,
  });

  final String text;
  final String iconAsset;
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.row, required this.color});

  final _CardRow row;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(row.iconAsset, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            row.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.operation,
    required this.isSelected,
    required this.rowColor,
  });

  final Operation operation;
  final bool isSelected;
  final Color rowColor;

  @override
  Widget build(BuildContext context) {
    if (operation.operationType == OperationType.commissioning) {
      final commissioned =
          operation.totalCommissioned ?? operation.itemCount;
      final failed = operation.totalFailedCount ?? 0;
      return Row(
        children: [
          TraqIcon(AppAssets.iconCheck, size: 14, color: rowColor),
          const SizedBox(width: 4),
          Text(
            '$commissioned commissioned',
            style: TextStyle(color: rowColor, fontSize: 12),
          ),
          if (failed > 0) ...[
            const SizedBox(width: 12),
            TraqIcon(AppAssets.iconAlert, size: 14, color: Colors.red[600]),
            const SizedBox(width: 4),
            Text(
              '$failed failed',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ],
        ],
      );
    }

    return Text(
      '${operation.eventIds?.length ?? 0} events',
      style: TextStyle(color: rowColor, fontSize: 12),
    );
  }
}
