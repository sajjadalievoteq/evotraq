import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_status_badge.dart';

Future<void> showTatmeenOperationDetailsDialog(
  BuildContext context, {
  required TatmeenSyncRecord record,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.all(TraqSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  TraqSpacing.md,
                  TraqSpacing.sm,
                  TraqSpacing.xs,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Operation details',
                        style: dialogContext.text.h3,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const TraqIcon(AppAssets.iconX, size: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    TraqSpacing.md,
                    TraqSpacing.sm,
                    TraqSpacing.md,
                    TraqSpacing.lg,
                  ),
                  children: [
                    OperationDetailStatusBanner(
                      title: record.operationType,
                      operationId: record.operationId,
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    OperationDetailGroupCard(
                      title: 'Operation',
                      children: [
                        OperationDetailInfoRow(
                          label: 'Operation ID',
                          value: record.operationId,
                        ),
                        OperationDetailInfoRow(
                          label: 'Type',
                          value: record.operationType,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: TraqSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: dialogContext.text.bodySm.copyWith(
                                    color: dialogContext.colors.textMuted,
                                  ),
                                ),
                              ),
                              TatmeenSyncStatusBadge(status: record.status),
                            ],
                          ),
                        ),
                        OperationDetailInfoRow(
                          label: 'Timestamp',
                          value: DisplayDateUtils.dmyHm(record.createdAt),
                        ),
                      ],
                    ),
                    OperationDetailGroupCard(
                      title: 'Sync',
                      children: [
                        OperationDetailInfoRow(
                          label: 'Attempts',
                          value: record.attemptsLabel,
                        ),
                        OperationDetailInfoRow(
                          label: 'Duration',
                          value: record.durationLabel,
                        ),
                        OperationDetailInfoRow(
                          label: 'Message',
                          value: record.message,
                        ),
                      ],
                    ),
                    if (record.attemptHistory.isNotEmpty)
                      OperationDetailGroupCard(
                        title: 'Attempt history',
                        children: [
                          for (final attempt in record.attemptHistory)
                            OperationDetailInfoRow(
                              label: DisplayDateUtils.dmyHm(attempt.timestamp),
                              value: attempt.errorMessage,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
