import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/widgets/sgtin_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/widgets/sgtin_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/widgets/sgtin_record_info_section.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/widgets/sgtin_results_list.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_filter_value.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

class SGTINListScreen extends StatefulWidget {
  const SGTINListScreen({
    super.key,
    this.embedded = false,
    this.selectedSgtinId,
    this.onSelectSgtin,
  });

  final bool embedded;
  final String? selectedSgtinId;
  final ValueChanged<String>? onSelectSgtin;

  @override
  State<SGTINListScreen> createState() => _SGTINListScreenState();
}

class _SGTINListScreenState extends State<SGTINListScreen> {
  final _searchController = TextEditingController();
  late Gs1ListSearchDebouncer _searchDebouncer;
  final _gtinCodeController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _batchLotController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  String? _selectedSortBy = 'createdAt';
  String _sortDirection = 'DESC';
  int _pageSize = 25;
  bool _showAdvancedFilters = false;

  bool _didRunPrimaryInitialFetch = false;

  @override
  void initState() {
    super.initState();
    _searchDebouncer = Gs1ListSearchDebouncer(
      onDebounced: () {
        if (!mounted) return;
        _search();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRunPrimaryInitialFetch) return;
    final primary = PrimaryFetchScope.maybeOf(context)?.isPrimary ?? true;
    if (!primary) return;
    _didRunPrimaryInitialFetch = true;
    _search();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    _gtinCodeController.dispose();
    _serialNumberController.dispose();
    _batchLotController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<SGTINCubit>().fetchSGTINList(
      gtinCode: _gtinCodeController.text.isNotEmpty ? _gtinCodeController.text : null,
      serialNumber: _searchController.text.isNotEmpty
          ? _searchController.text
          : (_serialNumberController.text.isNotEmpty ? _serialNumberController.text : null),
      batchLotNumber:
          _batchLotController.text.isNotEmpty ? _batchLotController.text : null,
      status: gs1ValueUnlessAll(_selectedStatus),
      page: 0,
      size: _pageSize,
      sortBy: _selectedSortBy ?? 'createdAt',
      sortDirection: _sortDirection,
    );
  }

  void _searchImmediate() {
    _searchDebouncer.cancel();
    _search();
  }

  void _onSearchTextChanged(String _) {
    _searchDebouncer.schedule();
  }

  void _loadMore() {
    final cubitState = context.read<SGTINCubit>().state;
    if (!cubitState.hasMoreData) return;

    context.read<SGTINCubit>().fetchSGTINList(
      gtinCode: _gtinCodeController.text.isNotEmpty ? _gtinCodeController.text : null,
      serialNumber: _searchController.text.isNotEmpty
          ? _searchController.text
          : (_serialNumberController.text.isNotEmpty ? _serialNumberController.text : null),
      batchLotNumber:
          _batchLotController.text.isNotEmpty ? _batchLotController.text : null,
      status: gs1ValueUnlessAll(_selectedStatus),
      page: cubitState.currentPage + 1,
      size: _pageSize,
      sortBy: _selectedSortBy ?? 'createdAt',
      sortDirection: _sortDirection,
      isLoadMore: true,
    );
  }

  Future<void> _refresh() async {
    _searchImmediate();
  }

  void _showFilterDialog() {
    SgtinQuickFilterDialog.open(
      context,
      selectedStatus: _selectedStatus,
    ).then((result) {
      if (result == null) return;
      if (result.cleared) {
        setState(() => _selectedStatus = null);
        _searchImmediate();
        return;
      }
      setState(() => _selectedStatus = result.status);
      _searchImmediate();
    });
  }

  void _showAdvancedFiltersDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(SgtinUiConstants.dialogAdvancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            child: SgtinAdvancedFiltersPanel(
              gtinCodeController: _gtinCodeController,
              serialNumberController: _serialNumberController,
              batchLotController: _batchLotController,
              selectedStatus: _selectedStatus,
              onStatusChanged: (v) => setState(() => _selectedStatus = v),
              onApply: () {
                Navigator.of(dialogContext).pop();
                _searchImmediate();
              },
              onClearAll: () {
                Navigator.of(dialogContext).pop();
                _clearAllFilters();
              },
            ),
          ),
        ),
        actions: [
          CustomTextButtonWidget(
            title: SgtinUiConstants.buttonClose,
            onTap: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(String id) {
    if (widget.onSelectSgtin != null) {
      widget.onSelectSgtin!(id);
      return;
    }
    context.go('${Constants.gs1SgtinsRoute}/$id');
  }

  void _navigateToCreate() {
    context.go(Constants.gs1SgtinNewRoute);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = null;
      _searchController.clear();
      _gtinCodeController.clear();
      _serialNumberController.clear();
      _batchLotController.clear();
    });
    _searchImmediate();
  }

  void _toggleSortDirection() {
    setState(() {
      _sortDirection = _sortDirection == 'DESC' ? 'ASC' : 'DESC';
    });
    _searchImmediate();
  }

  @override
  Widget build(BuildContext context) {
    final content = AppLayoutBuilder(
      builder: (context, layout) {
        return Gs1MasterListBody(
          toolbar: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: context.padding.left,
                  left: context.padding.left,
                  right: context.padding.left,
                ),
                child: Column(
                  children: [
                    ListenableBuilder(
                      listenable: _searchController,
                      builder: (context, _) {
                        return Gs1ListSearchBar(
                          hintText: SgtinUiConstants.listSearchHint,
                          controller: _searchController,
                          showAdvancedFilters: _showAdvancedFilters,
                          onSearch: _searchImmediate,
                          onQueryChanged: _onSearchTextChanged,
                          onRefresh: _searchImmediate,
                          onQuickFilters: _showFilterDialog,
                          onToggleAdvancedFilters: _showAdvancedFiltersDialog,
                          onClear: () {
                            _searchDebouncer.cancel();
                            _searchController.clear();
                            _search();
                          },
                        );
                      },
                    ),
                    SgtinRecordInfoSection(
                      pageSize: _pageSize,
                      onPageSizeChanged: (newSize) {
                        setState(() => _pageSize = newSize);
                        _searchImmediate();
                      },
                    ),
                    SizedBox(height: Constants.spacing),
                    Gs1ListSortingControls(
                      label: _sortLabel(),
                      sortOrder: _sortDirection.toLowerCase(),
                      onToggleSortOrder: _toggleSortDirection,
                    ),
                  ],
                ),
              ),
            ],
          ),
          results: SgtinResultsList(
            scrollController: _scrollController,
            selectedSgtinId: widget.selectedSgtinId,
            onRefresh: _refresh,
            onClearFilters: () {
              _searchController.clear();
              _clearAllFilters();
            },
            onTapSgtin: _navigateToDetails,
            onLoadMore: _loadMore,
          ),
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text(SgtinUiConstants.appBarManagement),
      ),
      drawer: const AppDrawer(),
      body: content,
      floatingActionButton: FloatingActionButton(
        heroTag: 'sgtin_list_standalone_add_fab',
        onPressed: _navigateToCreate,
        tooltip: SgtinUiConstants.fabAddNew,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _sortLabel() {
    final fieldLabel = SgtinUiConstants.sortFieldLabels[_selectedSortBy] ??
        SgtinUiConstants.sortFieldFallback;
    final orderLabel =
        _sortDirection == 'ASC' ? 'A–Z / Oldest' : 'Z–A / Newest';
    return 'Sort by $fieldLabel ($orderLabel)';
  }
}
