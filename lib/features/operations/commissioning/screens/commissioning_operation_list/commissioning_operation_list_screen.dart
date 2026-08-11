import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_list_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/utils/commissioning_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/commissioning_operation_list_body.dart';

class CommissioningOperationListScreen extends StatefulWidget {
  const CommissioningOperationListScreen({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedBatchId,
    this.onLoadingChanged,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedBatchId;
  final ValueChanged<bool>? onLoadingChanged;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  State<CommissioningOperationListScreen> createState() =>
      _CommissioningOperationListScreenState();
}

class _CommissioningOperationListScreenState
    extends State<CommissioningOperationListScreen> {
  final TextEditingController _gtinFilterController = TextEditingController();

  late CommissioningOperationListCubit _cubit;
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _cubit = _buildCubit()..loadInitial();
  }

  @override
  void dispose() {
    _cubit.close();
    _gtinFilterController.dispose();
    super.dispose();
  }

  CommissioningOperationListCubit _buildCubit() {
    final cubit = CommissioningOperationListCubit(
      service: getIt<CommissioningOperationService>(),
      pageSize: _pageSize,
    );
    cubit.configure(
      gtin: _gtinFilterController.text,
      sortBy: _sortBy,
      sortDir: _sortDir,
    );
    return cubit;
  }

  void _reloadFromServer() {
    _cubit.configure(
      gtin: _gtinFilterController.text,
      sortBy: _sortBy,
      sortDir: _sortDir,
    );
    _cubit.refresh();
  }

  void _onPageSizeChanged(int newSize) {
    if (_pageSize == newSize) return;
    setState(() {
      _pageSize = newSize;
      _cubit.close();
      _cubit = _buildCubit();
    });
    _cubit.loadInitial();
  }

  void _onServerSortChanged({String? sortBy, String? sortDir}) {
    setState(() {
      if (sortBy != null) _sortBy = sortBy;
      if (sortDir != null) _sortDir = sortDir;
    });
    _reloadFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: CommissioningOperationListBody(
        embedded: widget.embedded,
        onSelectOperation: widget.onSelectOperation,
        selectedBatchId: widget.selectedBatchId,
        onLoadingChanged: widget.onLoadingChanged,
        onBindRefresh: widget.onBindRefresh,
        onEmbeddedCreate: widget.onEmbeddedCreate,
        gtinFilterController: _gtinFilterController,
        sortBy: _sortBy,
        sortDir: _sortDir,
        pageSize: _pageSize,
        onServerSortChanged: _onServerSortChanged,
        onPageSizeChanged: _onPageSizeChanged,
        onServerReload: _reloadFromServer,
      ),
    );
  }
}
