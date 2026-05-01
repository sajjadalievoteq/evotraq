import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_record_info_section.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_results_list.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

/// Screen to display and manage GLNs — layout aligned with [GTINListScreen].
class GLNListScreen extends StatefulWidget {
  const GLNListScreen({
    Key? key,
    this.embedded = false,
    this.onSelectGln,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  }) : super(key: key);

  final bool embedded;
  final ValueChanged<String>? onSelectGln;
  final void Function(VoidCallback refresh)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  State<GLNListScreen> createState() => _GLNListScreenState();
}

class _GLNListScreenState extends State<GLNListScreen> {
  final _searchController = TextEditingController();
  late Gs1ListSearchDebouncer _searchDebouncer;
  final _glnCodeController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  String? _selectedLocationType;
  String _sortBy = 'locationName';
  String _sortOrder = 'asc';
  int _pageSize = 25;

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
      _searchImmediate();
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    _glnCodeController.dispose();
    _locationNameController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _contactEmailController.dispose();
    _contactNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _getAdvancedFilterValue(String filterType) {
    switch (filterType) {
      case 'glnCode':
        return _glnCodeController.text.isEmpty ? null : _glnCodeController.text;
      case 'locationName':
        return _locationNameController.text.isEmpty
            ? null
            : _locationNameController.text;
      case 'address':
        return _addressController.text.isEmpty ? null : _addressController.text;
      case 'licenseNumber':
        return _licenseNumberController.text.isEmpty
            ? null
            : _licenseNumberController.text;
      case 'contactEmail':
        return _contactEmailController.text.isEmpty
            ? null
            : _contactEmailController.text;
      case 'contactName':
        return _contactNameController.text.isEmpty
            ? null
            : _contactNameController.text;
      default:
        return null;
    }
  }

  String? _locationTypeApiValue() {
    if (_selectedLocationType == null || _selectedLocationType == 'All') {
      return null;
    }
    return _selectedLocationType!.replaceAll(' ', '_').toLowerCase();
  }

  void _runSearch({required int page}) {
    context.read<GLNCubit>().searchGLNsAdvanced(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          glnCode: _getAdvancedFilterValue('glnCode'),
          locationName: _getAdvancedFilterValue('locationName'),
          address: _getAdvancedFilterValue('address'),
          licenseNumber: _getAdvancedFilterValue('licenseNumber'),
          contactEmail: _getAdvancedFilterValue('contactEmail'),
          contactName: _getAdvancedFilterValue('contactName'),
          active: _selectedStatus == null || _selectedStatus == 'All'
              ? null
              : (_selectedStatus!.toLowerCase() == 'active'),
          locationType: _locationTypeApiValue(),
          page: page,
          size: _pageSize,
          sortBy: _sortBy,
          direction: _sortOrder.toUpperCase(),
        );
  }

  void _search() {
    _runSearch(page: 0);
  }

  void _searchImmediate() {
    _searchDebouncer.cancel();
    _search();
  }

  void _onSearchTextChanged(String _) {
    _searchDebouncer.schedule();
  }

  void _loadMore() {
    final cubitState = context.read<GLNCubit>().state;
    if (!cubitState.hasMoreData || cubitState.isFetchingMore) return;
    if (cubitState.status == GLNStatus.loading && cubitState.glns.isEmpty) {
      return;
    }
    _runSearch(page: cubitState.currentPage + 1);
  }

  Future<void> _refresh() async {
    _searchImmediate();
  }

  void _showFilterDialog() {
    GlnQuickFilterDialog.open(
      context,
      locationNameController: _locationNameController,
      selectedStatus: _selectedStatus,
      selectedLocationType: _selectedLocationType,
    ).then((result) {
      if (result == null) return;

      if (result.cleared) {
        setState(() {
          _locationNameController.clear();
          _selectedStatus = 'All';
          _selectedLocationType = 'All';
        });
        _searchImmediate();
        return;
      }

      setState(() {
        _selectedStatus = result.status;
        _selectedLocationType = result.locationType;
      });
      _searchImmediate();
    });
  }

  void _showAdvancedFiltersDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Advanced Filters'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setLocalState) {
                  return GlnAdvancedFiltersPanel(
                    locationNameController: _locationNameController,
                    glnCodeController: _glnCodeController,
                    addressController: _addressController,
                    licenseNumberController: _licenseNumberController,
                    contactEmailController: _contactEmailController,
                    contactNameController: _contactNameController,
                    selectedLocationType: _selectedLocationType ?? 'All',
                    selectedStatus: _selectedStatus ?? 'All',
                    sortBy: _sortBy,
                    onLocationTypeChanged: (value) {
                      setLocalState(() => _selectedLocationType = value);
                    },
                    onStatusChanged: (value) {
                      setLocalState(() => _selectedStatus = value);
                    },
                    onSortByChanged: (value) {
                      if (value != null) {
                        setLocalState(() => _sortBy = value);
                      }
                    },
                    onApply: () {
                      Navigator.of(dialogContext).pop();
                      setState(() {});
                      _searchImmediate();
                    },
                    onClearAll: () {
                      Navigator.of(dialogContext).pop();
                      _clearAllFilters();
                    },
                  );
                },
              ),
            ),
          ),
          actions: [
            CustomTextButtonWidget(
              title: 'Close',
              onTap: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreateGLN() {
    if (widget.onEmbeddedCreate != null) {
      widget.onEmbeddedCreate!();
      return;
    }
    context.push(Constants.gs1GlnNewRoute).then((_) => _searchImmediate());
  }

  void _openGlnDetail(String glnCode) {
    if (widget.onSelectGln != null) {
      widget.onSelectGln!(glnCode);
      return;
    }
    context.push('${Constants.gs1GlnsRoute}/$glnCode').then((_) => _searchImmediate());
  }

  void _openGlnEdit(String glnCode) {
    context
        .push('${Constants.gs1GlnsRoute}/$glnCode/edit')
        .then((_) => _searchImmediate());
  }

  void _handleGlnRowMenu(GLN gln, String action) {
    switch (action) {
      case 'view':
        _openGlnDetail(gln.glnCode);
        break;
      case 'edit':
        _openGlnEdit(gln.glnCode);
        break;
      case 'delete':
        _showDeleteConfirmation(gln);
        break;
    }
  }

  void _showDeleteConfirmation(GLN gln) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the GLN for "${gln.locationName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GLNCubit>().deleteGLN(gln.glnCode);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
    });
    _searchImmediate();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedLocationType = 'All';
      _sortBy = 'locationName';
      _sortOrder = 'asc';
      _searchController.clear();
      _glnCodeController.clear();
      _locationNameController.clear();
      _addressController.clear();
      _licenseNumberController.clear();
      _contactEmailController.clear();
      _contactNameController.clear();
    });
    _searchImmediate();
  }

  String _sortFieldDisplayLabel() {
    return GlnUiConstants.sortFieldLabels[_sortBy] ?? 'location name';
  }

  @override
  Widget build(BuildContext context) {
    final content = AppLayoutBuilder(
      builder: (context, layout) {
        return Gs1MasterListBody(
          toolbar: Column(
            children: [
              ListenableBuilder(
                listenable: _searchController,
                builder: (context, _) {
                  return Gs1ListSearchBar(
                    hintText: GlnUiConstants.listSearchHint,
                    controller: _searchController,
                    showAdvancedFilters: false,
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
              GlnRecordInfoSection(
                pageSize: _pageSize,
                onPageSizeChanged: (newSize) {
                  setState(() {
                    _pageSize = newSize;
                  });
                  _searchImmediate();
                },
              ),
              SizedBox(height: Constants.spacing),
              Gs1ListSortingControls(
                label:
                    'Sort by ${_sortFieldDisplayLabel()} (${_sortOrder == 'asc' ? 'A–Z' : 'Z–A'})',
                sortOrder: _sortOrder,
                onToggleSortOrder: _toggleSortOrder,
              ),
            ],
          ),
          results: GlnResultsList(
            scrollController: _scrollController,
            onRefresh: _refresh,
            onClearFilters: _clearAllFilters,
            onTapGln: _openGlnDetail,
            onRowMenuAction: _handleGlnRowMenu,
            onLoadMore: _loadMore,
          ),
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('GLN Management')),
      drawer: const AppDrawer(),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateGLN,
        tooltip: 'Add New GLN',
        child: const Icon(Icons.add),
      ),
    );
  }
}
