import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_route_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/filters/sscc_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/filters/sscc_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/list/sscc_record_info_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/list/sscc_results_list.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart' as edit_rules;
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

class SSCCListScreen extends StatefulWidget {
  const SSCCListScreen({
    super.key,
    this.embedded = false,
    this.selectedSsccCode,
    this.onSelectSscc,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final String? selectedSsccCode;
  final ValueChanged<String>? onSelectSscc;
  final void Function(VoidCallback refresh)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  State<SSCCListScreen> createState() => _SSCCListScreenState();
}

class _SSCCListScreenState extends State<SSCCListScreen> {
  final _searchController = TextEditingController();
  late Gs1ListSearchDebouncer _searchDebouncer;
  final _sourceLocationController = TextEditingController();
  final _destinationLocationController = TextEditingController();
  final _companyPrefixController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  String? _selectedContainerType;
  DateTime? _packingDateFrom;
  DateTime? _packingDateTo;
  DateTime? _shippingDateFrom;
  DateTime? _shippingDateTo;
  DateTime? _receivingDateFrom;
  DateTime? _receivingDateTo;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onBindRefresh?.call(() {
        if (mounted) _searchImmediate();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRunPrimaryInitialFetch) return;
    final primary = PrimaryFetchScope.maybeOf(context)?.isPrimary ?? true;
    if (!primary) return;
    _didRunPrimaryInitialFetch = true;
    _loadList();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    _sourceLocationController.dispose();
    _destinationLocationController.dispose();
    _companyPrefixController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadList() {
    context.read<SSCCCubit>().loadSSCCList(
      page: 0,
      size: _pageSize,
      sortBy: _selectedSortBy ?? 'createdAt',
      sortDirection: _sortDirection,
    );
  }

  void _search() {
    context.read<SSCCCubit>().fetchSSCCList(
          ssccCode: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
          containerType: _selectedContainerType,
          containerStatus: _selectedStatus,
          sourceLocationName: _sourceLocationController.text.isNotEmpty
              ? _sourceLocationController.text
              : null,
          destinationLocationName:
              _destinationLocationController.text.isNotEmpty
                  ? _destinationLocationController.text
                  : null,
          gs1CompanyPrefix: _companyPrefixController.text.isNotEmpty
              ? _companyPrefixController.text
              : null,
          packingDateFrom: _packingDateFrom,
          packingDateTo: _packingDateTo,
          shippingDateFrom: _shippingDateFrom,
          shippingDateTo: _shippingDateTo,
          receivingDateFrom: _receivingDateFrom,
          receivingDateTo: _receivingDateTo,
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
    final cubitState = context.read<SSCCCubit>().state;
    if (!cubitState.hasMoreData) return;

    context.read<SSCCCubit>().fetchSSCCList(
          ssccCode: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
          containerType: _selectedContainerType,
          containerStatus: _selectedStatus,
          sourceLocationName: _sourceLocationController.text.isNotEmpty
              ? _sourceLocationController.text
              : null,
          destinationLocationName:
              _destinationLocationController.text.isNotEmpty
                  ? _destinationLocationController.text
                  : null,
          gs1CompanyPrefix: _companyPrefixController.text.isNotEmpty
              ? _companyPrefixController.text
              : null,
          packingDateFrom: _packingDateFrom,
          packingDateTo: _packingDateTo,
          shippingDateFrom: _shippingDateFrom,
          shippingDateTo: _shippingDateTo,
          receivingDateFrom: _receivingDateFrom,
          receivingDateTo: _receivingDateTo,
          page: cubitState.page + 1,
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
    SsccQuickFilterDialog.open(
      context,
      selectedStatus: _selectedStatus,
      selectedContainerType: _selectedContainerType,
    ).then((result) {
      if (result == null) return;
      if (result.cleared) {
        setState(() {
          _selectedStatus = null;
          _selectedContainerType = null;
        });
        _searchImmediate();
        return;
      }
      setState(() {
        _selectedStatus = result.status;
        _selectedContainerType = result.containerType;
      });
      _searchImmediate();
    });
  }

  void _showAdvancedFiltersDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(SsccUiConstants.dialogAdvancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            child: SsccAdvancedFiltersPanel(
              sourceLocationController: _sourceLocationController,
              destinationLocationController: _destinationLocationController,
              companyPrefixController: _companyPrefixController,
              selectedStatus: _selectedStatus,
              selectedContainerType: _selectedContainerType,
              onStatusChanged: (v) => setState(() => _selectedStatus = v),
              onContainerTypeChanged: (v) =>
                  setState(() => _selectedContainerType = v),
              packingDateFrom: _packingDateFrom,
              packingDateTo: _packingDateTo,
              shippingDateFrom: _shippingDateFrom,
              shippingDateTo: _shippingDateTo,
              receivingDateFrom: _receivingDateFrom,
              receivingDateTo: _receivingDateTo,
              onPackingDateFromChanged: (v) =>
                  setState(() => _packingDateFrom = v),
              onPackingDateToChanged: (v) => setState(() => _packingDateTo = v),
              onShippingDateFromChanged: (v) =>
                  setState(() => _shippingDateFrom = v),
              onShippingDateToChanged: (v) =>
                  setState(() => _shippingDateTo = v),
              onReceivingDateFromChanged: (v) =>
                  setState(() => _receivingDateFrom = v),
              onReceivingDateToChanged: (v) =>
                  setState(() => _receivingDateTo = v),
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
            title: SsccUiConstants.buttonClose,
            onTap: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(String ssccCode) {
    if (widget.onSelectSscc != null) {
      widget.onSelectSscc!(ssccCode);
      return;
    }
    context.go(SsccRouteConstants.pathForSsccCode(ssccCode));
    _searchImmediate();
  }

  void _navigateToEdit(String ssccCode) {
    context.go(SsccRouteConstants.pathForSsccCodeEdit(ssccCode));
    _searchImmediate();
  }

  void _navigateToCreate() {
    if (widget.onEmbeddedCreate != null) {
      widget.onEmbeddedCreate!();
      return;
    }
    context.go(Constants.gs1SsccNewRoute);
    _searchImmediate();
  }

  void _handleSsccRowMenu(SSCC sscc, String action) {
    switch (action) {
      case 'view':
        _navigateToDetails(sscc.ssccCode);
        break;
      case 'edit':
        if (!edit_rules.canEditSsccRecord(sscc.status)) {
          context.showInfo(edit_rules.readOnlyLifecycleMessage(sscc.status));
          _navigateToDetails(sscc.ssccCode);
          return;
        }
        _navigateToEdit(sscc.ssccCode);
        break;
      case 'delete':
        if (!edit_rules.canDeleteSscc(sscc.status)) {
          context.showInfo(SsccUiConstants.deleteNotAllowedMessage);
          return;
        }
        _showDeleteConfirmation(sscc);
        break;
    }
  }

  void _showDeleteConfirmation(SSCC sscc) {
    final deleteId = sscc.id ?? sscc.ssccCode;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(SsccUiConstants.dialogConfirmDeletionTitle),
        content: Text(SsccUiConstants.deleteSsccConfirm(sscc.ssccCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(SsccUiConstants.dialogCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SSCCCubit>().deleteSSCC(deleteId);
              _searchImmediate();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(SsccUiConstants.dialogDelete),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedContainerType = null;
      _searchController.clear();
      _sourceLocationController.clear();
      _destinationLocationController.clear();
      _companyPrefixController.clear();
      _packingDateFrom = null;
      _packingDateTo = null;
      _shippingDateFrom = null;
      _shippingDateTo = null;
      _receivingDateFrom = null;
      _receivingDateTo = null;
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
                          hintText: SsccUiConstants.listSearchHint,
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
                    SsccRecordInfoSection(
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
          results: SsccResultsList(
            scrollController: _scrollController,
            selectedSsccCode: widget.selectedSsccCode,
            onRefresh: _refresh,
            onClearFilters: _clearAllFilters,
            onTapSscc: _navigateToDetails,
            onRowMenuAction: _handleSsccRowMenu,
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
        title: const Text(SsccUiConstants.appBarManagement),
      ),
      drawer: const AppDrawer(),
      body: content,
      floatingActionButton: FloatingActionButton(
        heroTag: 'sscc_list_standalone_add_fab',
        onPressed: _navigateToCreate,
        tooltip: SsccUiConstants.fabAddNew,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _sortLabel() {
    final fieldLabel = SsccUiConstants.sortFieldLabels[_selectedSortBy] ??
        SsccUiConstants.sortFieldFallback;
    final orderLabel =
        _sortDirection == 'ASC' ? 'A–Z / Oldest' : 'Z–A / Newest';
    return 'Sort by $fieldLabel ($orderLabel)';
  }
}
