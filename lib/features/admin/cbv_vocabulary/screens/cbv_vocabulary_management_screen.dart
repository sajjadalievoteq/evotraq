import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/widgets/cbv_group_section.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/widgets/cbv_statistics_header.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/widgets/cbv_vocabulary_form_dialog.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter enum (kept in screen — UI-only concern)
// ─────────────────────────────────────────────────────────────────────────────

enum _VocabFilter { all, system, custom, enabledOnly, disabledOnly }

extension on _VocabFilter {
  String get label {
    switch (this) {
      case _VocabFilter.all:
        return 'All';
      case _VocabFilter.system:
        return 'System';
      case _VocabFilter.custom:
        return 'Custom';
      case _VocabFilter.enabledOnly:
        return 'Enabled';
      case _VocabFilter.disabledOnly:
        return 'Disabled';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen entry point
// ─────────────────────────────────────────────────────────────────────────────

class CbvVocabularyManagementScreen extends StatelessWidget {
  const CbvVocabularyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<AdminCbvVocabularyCubit>()..load(),
      child: const _CbvVocabularyManagementView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────

class _CbvVocabularyManagementView extends StatefulWidget {
  const _CbvVocabularyManagementView();

  @override
  State<_CbvVocabularyManagementView> createState() =>
      _CbvVocabularyManagementViewState();
}

class _CbvVocabularyManagementViewState
    extends State<_CbvVocabularyManagementView> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, ExpansionTileController> _expansionControllers = {};

  String _searchQuery = '';
  _VocabFilter _filter = _VocabFilter.all;
  bool _sortAlpha = false;

  // ── Auth helper ─────────────────────────────────────────────────────────

  bool get _isAdmin =>
      context.read<AuthCubit>().state.user?.role == 'ADMIN';

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  // ── Expansion controllers ────────────────────────────────────────────────

  ExpansionTileController _controllerFor(String key) =>
      _expansionControllers.putIfAbsent(key, () => ExpansionTileController());

  void _expandAll() {
    for (final c in _expansionControllers.values) {
      try {
        c.expand();
      } on StateError catch (_) {}
    }
  }

  void _collapseAll() {
    for (final c in _expansionControllers.values) {
      try {
        c.collapse();
      } on StateError catch (_) {}
    }
  }

  // ── Filtering ────────────────────────────────────────────────────────────

  List<CbvVocabularyItem> _applyFilter(List<CbvVocabularyItem> items) {
    var result = items;
    if (_searchQuery.isNotEmpty) {
      result = result.where((item) {
        return item.label.toLowerCase().contains(_searchQuery) ||
            item.code.toLowerCase().contains(_searchQuery) ||
            item.urn.toLowerCase().contains(_searchQuery) ||
            (item.group?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
    switch (_filter) {
      case _VocabFilter.system:
        result = result.where((i) => i.isSystem).toList();
        break;
      case _VocabFilter.custom:
        result = result.where((i) => i.isCustom).toList();
        break;
      case _VocabFilter.enabledOnly:
        result = result.where((i) => i.enabled).toList();
        break;
      case _VocabFilter.disabledOnly:
        result = result.where((i) => !i.enabled).toList();
        break;
      case _VocabFilter.all:
        break;
    }
    if (_sortAlpha) {
      result = [...result]..sort((a, b) => a.label.compareTo(b.label));
    }
    return result;
  }

  Map<String, List<CbvVocabularyItem>> _groupBy(
      List<CbvVocabularyItem> items) {
    final map = <String, List<CbvVocabularyItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.group ?? 'Other', () => []).add(item);
    }
    // Keep groups alphabetically sorted
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  // ── Toggle ───────────────────────────────────────────────────────────────

  Future<void> _onToggleBizStep(CbvVocabularyItem item, bool enabled) async {
    try {
      await context
          .read<AdminCbvVocabularyCubit>()
          .toggleBizStep(item.code, enabled: enabled);
    } catch (_) {
      if (mounted) {
        context.showError(
          'Failed to ${enabled ? 'enable' : 'disable'} "${item.label}". Change reverted.',
        );
      }
    }
  }

  Future<void> _onToggleDisposition(
      CbvVocabularyItem item, bool enabled) async {
    try {
      await context
          .read<AdminCbvVocabularyCubit>()
          .toggleDisposition(item.code, enabled: enabled);
    } catch (_) {
      if (mounted) {
        context.showError(
          'Failed to ${enabled ? 'enable' : 'disable'} "${item.label}". Change reverted.',
        );
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> _confirmDelete(
    CbvVocabularyItem item, {
    required bool isBizStep,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${item.label}"?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      if (isBizStep) {
        await context
            .read<AdminCbvVocabularyCubit>()
            .deleteBizStep(item.code);
      } else {
        await context
            .read<AdminCbvVocabularyCubit>()
            .deleteDisposition(item.code);
      }
      if (mounted) {
        context.showSuccess('"${item.label}" deleted.');
      }
    } catch (_) {
      if (mounted) {
        context.showError(
            'Failed to delete "${item.label}". Item restored.');
      }
    }
  }

  // ── Create ───────────────────────────────────────────────────────────────

  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add Vocabulary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: const Text('Add Biz Step'),
              onTap: () {
                Navigator.of(dialogCtx).pop();
                _showCreateDialog(CbvVocabType.bizStep);
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Add Disposition'),
              onTap: () {
                Navigator.of(dialogCtx).pop();
                _showCreateDialog(CbvVocabType.disposition);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(CbvVocabType type) async {
    final state = context.read<AdminCbvVocabularyCubit>().state;
    final isBizStep = type == CbvVocabType.bizStep;
    final currentItems = isBizStep ? state.bizSteps : state.dispositions;
    final existingCodes = currentItems.map((i) => i.code).toList();
    final existingGroups = currentItems
        .map((i) => i.group ?? 'Other')
        .toSet()
        .toList()
      ..sort();

    final result = await showCbvVocabularyFormDialog(
      context: context,
      type: type,
      existingCodes: existingCodes,
      existingGroups: existingGroups,
    );
    if (result == null || !mounted) return;

    try {
      if (isBizStep) {
        await context.read<AdminCbvVocabularyCubit>().createBizStep(
              code: result.code,
              label: result.label,
              group: result.group,
              urn: result.urn,
              enabled: result.enabled,
              cbvVersion: result.cbvVersion,
            );
      } else {
        await context.read<AdminCbvVocabularyCubit>().createDisposition(
              code: result.code,
              label: result.label,
              group: result.group,
              urn: result.urn,
              enabled: result.enabled,
              cbvVersion: result.cbvVersion,
            );
      }
      if (mounted) {
        context.showSuccess(
          '${isBizStep ? 'Biz Step' : 'Disposition'} "${result.label}" created.',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showError(
          'Failed to create "${result.label}": ${e.toString()}',
        );
      }
    }
  }

  // ── Refresh ──────────────────────────────────────────────────────────────

  Future<void> _refresh() =>
      context.read<AdminCbvVocabularyCubit>().load(forceRefresh: true);

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin;

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('CBV Vocabulary Management'),
        actions: [
          IconButton(
            tooltip: 'Expand all groups',
            icon: const Icon(Icons.unfold_more),
            onPressed: _expandAll,
          ),
          IconButton(
            tooltip: 'Collapse all groups',
            icon: const Icon(Icons.unfold_less),
            onPressed: _collapseAll,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: isAdmin
          ? BlocBuilder<AdminCbvVocabularyCubit, AdminCbvVocabularyState>(
              buildWhen: (prev, next) =>
                  prev.isCreating != next.isCreating ||
                  prev.isLoaded != next.isLoaded,
              builder: (context, state) {
                if (!state.isLoaded) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: state.isCreating ? null : _showAddDialog,

               label: Icon(Icons.add),
                );
              },
            )
          : null,
      body: BlocBuilder<AdminCbvVocabularyCubit, AdminCbvVocabularyState>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.hasError) {
            return _ErrorView(
              message: state.error ?? 'An error occurred.',
              onRetry: _refresh,
            );
          }

          final filteredBizSteps = _applyFilter(state.bizSteps);
          final filteredDispositions = _applyFilter(state.dispositions);
          final bizStepGroups = _groupBy(filteredBizSteps);
          final dispositionGroups = _groupBy(filteredDispositions);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                // ── Stats + search ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(
                      top: context.padding.top,
                      left:  context.padding.top,
                      right:  context.padding.top
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        CbvStatisticsHeader(state: state),
                        const SizedBox(height: TraqSpacing.lg),
                        _SearchAndFilters(
                          searchController: _searchController,
                          activeFilter: _filter,
                          sortAlpha: _sortAlpha,
                          onFilterChanged: (f) =>
                              setState(() => _filter = f),
                          onSortAlphaChanged: (v) =>
                              setState(() => _sortAlpha = v),
                        ),
                        const SizedBox(height: TraqSpacing.xl),
                      ],
                    ),
                  ),
                ),

                // ── Biz Steps ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    label: 'Biz Steps',
                    icon: Icons.account_tree_outlined,
                    totalCount: state.bizSteps.length,
                    filteredCount: filteredBizSteps.length,
                  ),
                ),
                if (filteredBizSteps.isEmpty)
                  SliverToBoxAdapter(
                    child: _InlineEmpty(
                      message: _emptyMessage(
                          'biz steps', filteredBizSteps.isEmpty),
                    ),
                  )
                else
                  SliverPadding(
                    padding:  EdgeInsets.symmetric(
                        horizontal:context.padding.left ),
                    sliver: SliverList.separated(
                      itemCount: bizStepGroups.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: TraqSpacing.sm),
                      itemBuilder: (context, i) {
                        final name =
                            bizStepGroups.keys.elementAt(i);
                        return CbvGroupSection(
                          groupName: name,
                          items: bizStepGroups[name]!,
                          togglingCodes: state.togglingCodes,
                          deletingCodes: state.deletingCodes,
                          isAdmin: isAdmin,
                          onToggle: _onToggleBizStep,
                          onDelete: (item) => _confirmDelete(
                            item,
                            isBizStep: true,
                          ),
                          controller: _controllerFor('bs_$name'),
                        );
                      },
                    ),
                  ),

                // ── Dispositions ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: TraqSpacing.xl),
                    child: _SectionHeader(
                      label: 'Dispositions',
                      icon: Icons.label_outline,
                      totalCount: state.dispositions.length,
                      filteredCount: filteredDispositions.length,
                    ),
                  ),
                ),
                if (filteredDispositions.isEmpty)
                  SliverToBoxAdapter(
                    child: _InlineEmpty(
                      message: _emptyMessage(
                          'dispositions', filteredDispositions.isEmpty),
                    ),
                  )
                else
                  SliverPadding(
                    padding:  EdgeInsets.symmetric(
                        horizontal: context.padding.left),
                    sliver: SliverList.separated(
                      itemCount: dispositionGroups.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: TraqSpacing.sm),
                      itemBuilder: (context, i) {
                        final name =
                            dispositionGroups.keys.elementAt(i);
                        return CbvGroupSection(
                          groupName: name,
                          items: dispositionGroups[name]!,
                          togglingCodes: state.togglingCodes,
                          deletingCodes: state.deletingCodes,
                          isAdmin: isAdmin,
                          onToggle: _onToggleDisposition,
                          onDelete: (item) => _confirmDelete(
                            item,
                            isBizStep: false,
                          ),
                          controller: _controllerFor('dis_$name'),
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: TraqSpacing.xxxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _emptyMessage(String type, bool isEmpty) {
    if (_searchQuery.isNotEmpty) return 'No $type match "$_searchQuery".';
    switch (_filter) {
      case _VocabFilter.custom:
        return 'No custom $type found.';
      case _VocabFilter.system:
        return 'No system $type found.';
      case _VocabFilter.enabledOnly:
        return 'No enabled $type found.';
      case _VocabFilter.disabledOnly:
        return 'No disabled $type found.';
      default:
        return 'No $type found.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.totalCount,
    required this.filteredCount,
  });

  final String label;
  final IconData icon;
  final int totalCount;
  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFiltered = filteredCount < totalCount;

    return Padding(
      padding:  EdgeInsets.symmetric(
        horizontal: context.padding.left,

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: TraqSpacing.sm),
              Text(label, style: context.text.h2),
              const SizedBox(width: TraqSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TraqSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryMuted,
                  borderRadius: BorderRadius.all(TraqRadius.pill),
                ),
                child: Text(
                  isFiltered ? '$filteredCount of $totalCount' : '$totalCount',
                  style: context.text.cap.copyWith(
                    color: colors.primary,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.sm),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search + filter bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.searchController,
    required this.activeFilter,
    required this.sortAlpha,
    required this.onFilterChanged,
    required this.onSortAlphaChanged,
  });

  final TextEditingController searchController;
  final _VocabFilter activeFilter;
  final bool sortAlpha;
  final ValueChanged<_VocabFilter> onFilterChanged;
  final ValueChanged<bool> onSortAlphaChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search by label, code, URN or group…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: searchController.clear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: TraqRadius.input,
              borderSide: BorderSide(color: colors.border),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: TraqSpacing.md,
              horizontal: TraqSpacing.lg,
            ),
          ),
        ),
        const SizedBox(height: TraqSpacing.sm),
        Wrap(
          spacing: TraqSpacing.sm,
          runSpacing: TraqSpacing.xs,
          children: [
            // Type / enabled filters (mutually exclusive)
            for (final f in _VocabFilter.values)
              FilterChip(
                selectedColor: context.colors.primary,
                label: Text(f.label),
                selected: activeFilter == f,
                onSelected: (_) => onFilterChanged(f),
              ),
            const SizedBox(width: TraqSpacing.sm),
            // Sort (independent toggle)
            FilterChip(
              selectedColor: context.colors.primary,
              label: const Text('Sort A–Z'),
              selected: sortAlpha,
              onSelected: onSortAlphaChanged,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline empty state
// ─────────────────────────────────────────────────────────────────────────────

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(
        horizontal:context.padding.left ,
        vertical: TraqSpacing.xl,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.textFaint, size: 18),
          const SizedBox(width: TraqSpacing.sm),
          Text(
            message,
            style:
                context.text.body.copyWith(color: context.colors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: TraqSpacing.pagePad,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: TraqSpacing.lg),
            Text('Failed to load CBV vocabulary', style: context.text.h3),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              message,
              style: context.text.bodySm
                  .copyWith(color: context.colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraqSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
