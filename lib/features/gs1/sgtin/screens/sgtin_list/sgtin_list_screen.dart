import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_list/widgets/sgtin_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_list/widgets/sgtin_list_body.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_list/widgets/sgtin_quick_filter_dialog.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_search_input_resolver.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_filter_value.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
    final criteria = _buildSearchCriteria();
    if (criteria.parseError != null) {
      context.showError(criteria.parseError!);
      return;
    }

    context.read<SGTINCubit>().fetchSGTINList(
      gtinCode: criteria.gtinCode,
      serialNumber: criteria.serialNumber,
      epcUri: criteria.epcUri,
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

    final criteria = _buildSearchCriteria();
    context.read<SGTINCubit>().fetchSGTINList(
      gtinCode: criteria.gtinCode,
      serialNumber: criteria.serialNumber,
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

  ({
    String? gtinCode,
    String? serialNumber,
    String? epcUri,
    String? parseError,
  }) _buildSearchCriteria() {
    var gtinCode = _gtinCodeController.text.trim().isEmpty
        ? null
        : _gtinCodeController.text.trim();
    var serialNumber = _serialNumberController.text.trim().isEmpty
        ? null
        : _serialNumberController.text.trim();
    String? epcUri;

    final rawMain = _searchController.text.trim();
    if (rawMain.isNotEmpty) {
      final resolved = SgtinSearchInputResolver.resolve(rawMain);
      if (resolved.hasStructuredParseError) {
        return (
          gtinCode: null,
          serialNumber: null,
          epcUri: null,
          parseError: resolved.parseError,
        );
      }
      if (resolved.parseError != null &&
          resolved.gtinCode == null &&
          resolved.serialNumber == null) {
        return (
          gtinCode: null,
          serialNumber: null,
          epcUri: null,
          parseError: resolved.parseError,
        );
      }

      gtinCode ??= resolved.gtinCode;
      serialNumber ??= resolved.serialNumber;
      epcUri = resolved.epcUri;

      if (serialNumber == null && gtinCode == null) {
        serialNumber = rawMain;
      }
    }

    return (
      gtinCode: gtinCode,
      serialNumber: serialNumber,
      epcUri: epcUri,
      parseError: null,
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

  void _onSortOrderChanged(String order) {
    final target = order.toUpperCase();
    if (_sortDirection == target) return;
    setState(() => _sortDirection = target);
    _searchImmediate();
  }

  @override
  Widget build(BuildContext context) {
    final content = AppLayoutBuilder(
      builder: (context, layout) {
        return SgtinListBody(
          searchController: _searchController,
          searchDebouncer: _searchDebouncer,
          scrollController: _scrollController,
          pageSize: _pageSize,
          selectedSgtinId: widget.selectedSgtinId,
          showAdvancedFilters: _showAdvancedFilters,
          sortLabel: _sortLabel(),
          sortDirection: _sortDirection,
          onSearchImmediate: _searchImmediate,
          onSearchTextChanged: _onSearchTextChanged,
          onSearch: _search,
          onShowFilterDialog: _showFilterDialog,
          onShowAdvancedFiltersDialog: _showAdvancedFiltersDialog,
          onPageSizeChanged: (newSize) {
            setState(() => _pageSize = newSize);
            _searchImmediate();
          },
          onSortOrderChanged: _onSortOrderChanged,
          onRefresh: _refresh,
          onClearFilters: () {
            _searchController.clear();
            _clearAllFilters();
          },
          onTapSgtin: _navigateToDetails,
          onLoadMore: _loadMore,
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
        child: TraqIcon(AppAssets.iconPlus),
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
