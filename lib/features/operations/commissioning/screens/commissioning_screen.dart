import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list_screen.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// Main entry-point for the Commissioning Operations feature.
///
/// On desktop/wide layouts: split view — list left, detail right.
/// On mobile/narrow layouts: full-width list that navigates to detail via go_router.
class CommissioningScreen extends StatelessWidget {
  const CommissioningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return const _CommissioningDesktopSplit();
        }
        return const CommissioningOperationListScreen();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop split
// ---------------------------------------------------------------------------

class _CommissioningDesktopSplit extends StatefulWidget {
  const _CommissioningDesktopSplit();

  @override
  State<_CommissioningDesktopSplit> createState() =>
      _CommissioningDesktopSplitState();
}

class _CommissioningDesktopSplitState
    extends State<_CommissioningDesktopSplit> {
  String? _selectedBatchId;
  bool _isListLoading = true;

  void _onSelect(String batchId) {
    if (_selectedBatchId == batchId) return;
    setState(() => _selectedBatchId = batchId);
  }

  void _onListLoadingChanged(bool loading) {
    if (_isListLoading == loading) return;
    setState(() => _isListLoading = loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('Commissioning'),
      ),
      drawer: const AppDrawer(),
      body: MasterDetailSplitLayout(
        list: CommissioningOperationListScreen(
          embedded: true,
          selectedBatchId: _selectedBatchId,
          onSelectOperation: _onSelect,
          onLoadingChanged: _onListLoadingChanged,
        ),
        detail: Scaffold(
          primary: false,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/operations/commissioning/new'),
            icon: const Icon(Icons.add),
            label: const Text('New Commissioning'),
          ),
          body: CommissioningOperationDetailScreen(
            key: ValueKey(_selectedBatchId ?? '__await__'),
            batchId: _selectedBatchId,
            embedded: true,
            awaitingSelection: _selectedBatchId == null,
            listLoading: _isListLoading,
          ),
        ),
      ),
    );
  }
}
