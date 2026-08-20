import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/records/tatmeen_operation_details_dialog.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/records/tatmeen_record_confirm_dialogs.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_status_badge.dart';

import 'package:traqtrace_app/core/utils/responsive_utils.dart';

part 'tatmeen_record_tile.dart';
part 'tatmeen_records_table_skeleton.dart';

class TatmeenRecordsTable extends StatelessWidget {
  const TatmeenRecordsTable({
    super.key,
    required this.records,
    required this.isLoading,
    required this.isBusy,
    required this.onRetry,
  });

  final List<TatmeenSyncRecord> records;
  final bool isLoading;
  final bool Function(String id) isBusy;
  final Future<void> Function(TatmeenSyncRecord record) onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const TatmeenRecordsTableSkeleton();
    if (records.isEmpty) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconHistory,
        title: 'No sync records found',
        subtitle: 'Try adjusting filters or search.',
      );
    }

    return ListView.separated(
      itemCount: records.length,
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, index) {
        final record = records[index];
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                index == 0 ? TraqSpacing.lg : TraqSpacing.lg,
                0,
                index == records.length - 1 ? context.gutter : 0,
              ),
              child: TatmeenRecordTile(
                record: record,
                busy: isBusy(record.id),
                onRetry: () => onRetry(record),
              ),
            ),
          ],
        );
      },
    );
  }
}
