import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_records.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_records_content.dart';

class TatmeenRecordsScreen extends StatefulWidget {
  const TatmeenRecordsScreen({
    super.key,
    required this.filter,
    this.embedded = false,
  });

  final RecordsFilter filter;
  final bool embedded;

  @override
  State<TatmeenRecordsScreen> createState() => _TatmeenRecordsScreenState();
}

class _TatmeenRecordsScreenState extends State<TatmeenRecordsScreen> {
  late final UseTatmeenRecords _records;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _records = UseTatmeenRecords(
      service: getIt<TatmeenIntegrationService>(),
      filter: widget.filter,
    )..load();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _records.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return AnimatedBuilder(
        animation: _records,
        builder: (context, _) => TatmeenRecordsContent(
          records: _records,
          searchController: _searchController,
          title: widget.filter.title,
          summaryText: _summaryText(),
        ),
      );
    }
    return Scaffold(
      appBar: TraqAppBar(context, title: Text(widget.filter.title)),
      drawer: const AppDrawer(),
      body: AnimatedBuilder(
        animation: _records,
        builder: (context, _) => TatmeenRecordsContent(
          records: _records,
          searchController: _searchController,
          title: widget.filter.title,
          summaryText: _summaryText(),
        ),
      ),
    );
  }

  String _summaryText() {
    final count = NumberFormat.decimalPattern().format(_records.total);
    final label = switch (_records.status) {
      TatmeenRecordsStatusFilter.all => 'records',
      TatmeenRecordsStatusFilter.successful => 'successful records',
      TatmeenRecordsStatusFilter.failed => 'failed records',
      TatmeenRecordsStatusFilter.pending => 'pending records',
    };
    return 'Showing $count $label · last 30 days';
  }
}
