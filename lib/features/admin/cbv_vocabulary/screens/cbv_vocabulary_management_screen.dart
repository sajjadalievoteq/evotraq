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
import 'package:traqtrace_app/features/admin/cbv_vocabulary/widgets/cbv_statistics_header.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/widgets/cbv_vocabulary_skeleton.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/widgets/cbv_vocabulary_form_dialog.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

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
    extends State<_CbvVocabularyManagementView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _tabs = ['Pairings', 'Biz Steps', 'Dispositions'];

  bool get _isAdmin =>
      context.read<AuthCubit>().state.user?.role == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController
      ..removeListener(() {})
      ..dispose();
    super.dispose();
  }

  Future<void> _refresh() =>
      context.read<AdminCbvVocabularyCubit>().load(forceRefresh: true);

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
    final existingCodes = (isBizStep ? state.bizSteps : state.dispositions)
        .map((i) => i.code)
        .toList();

    final result = await showCbvVocabularyFormDialog(
      context: context,
      type: type,
      existingCodes: existingCodes,
    );
    if (result == null || !mounted) return;

    try {
      if (isBizStep) {
        await context.read<AdminCbvVocabularyCubit>().createBizStep(
              code: result.code,
              label: result.label,
              urn: result.urn,
              enabled: result.enabled,
              cbvVersion: result.cbvVersion,
            );
      } else {
        await context.read<AdminCbvVocabularyCubit>().createDisposition(
              code: result.code,
              label: result.label,
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
        context.showError('Failed to create "${result.label}": $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin;

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('CBV Vocabulary Management'),
        bottom: TabBar(
          
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
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
                  label: const Icon(Icons.add),
                );
              },
            )
          : null,
      body: BlocBuilder<AdminCbvVocabularyCubit, AdminCbvVocabularyState>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const CbvVocabularySkeleton();
          }
          if (state.hasError) {
            return _ErrorView(
              message: state.error ?? 'An error occurred.',
              onRetry: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // ── Stats header ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(
                    top: context.padding.top,
                    left: context.padding.left,
                    right: context.padding.right,
                  ),
                  child: CbvStatisticsHeader(state: state),
                ),
                // ── Search bar ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.padding.left,
                    vertical: TraqSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by label or code…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: TraqRadius.input,
                        borderSide:
                            BorderSide(color: context.colors.border),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: TraqSpacing.md,
                        horizontal: TraqSpacing.lg,
                      ),
                    ),
                  ),
                ),
                // ── Tab views ─────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PairingsTab(
                        state: state,
                        searchQuery: _searchQuery,
                        isAdmin: isAdmin,
                        onRefresh: _refresh,
                      ),
                      _VocabFlatTab(
                        items: state.bizSteps,
                        searchQuery: _searchQuery,
                        isAdmin: isAdmin,
                        isBizStep: true,
                        togglingCodes: state.togglingCodes,
                        deletingCodes: state.deletingCodes,
                        onToggle: (item, enabled) async {
                          try {
                            await context
                                .read<AdminCbvVocabularyCubit>()
                                .toggleBizStep(item.code, enabled: enabled);
                          } catch (_) {
                            if (context.mounted) {
                              context.showError(
                                'Failed to ${enabled ? 'enable' : 'disable'} "${item.label}".',
                              );
                            }
                          }
                        },
                        onDelete: (item) =>
                            _confirmDelete(item, isBizStep: true),
                      ),
                      _VocabFlatTab(
                        items: state.dispositions,
                        searchQuery: _searchQuery,
                        isAdmin: isAdmin,
                        isBizStep: false,
                        togglingCodes: state.togglingCodes,
                        deletingCodes: state.deletingCodes,
                        onToggle: (item, enabled) async {
                          try {
                            await context
                                .read<AdminCbvVocabularyCubit>()
                                .toggleDisposition(item.code,
                                    enabled: enabled);
                          } catch (_) {
                            if (context.mounted) {
                              context.showError(
                                'Failed to ${enabled ? 'enable' : 'disable'} "${item.label}".',
                              );
                            }
                          }
                        },
                        onDelete: (item) =>
                            _confirmDelete(item, isBizStep: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(CbvVocabularyItem item,
      {required bool isBizStep}) async {
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
                backgroundColor: context.colors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      if (isBizStep) {
        await context.read<AdminCbvVocabularyCubit>().deleteBizStep(item.code);
      } else {
        await context
            .read<AdminCbvVocabularyCubit>()
            .deleteDisposition(item.code);
      }
      if (mounted) context.showSuccess('"${item.label}" deleted.');
    } catch (_) {
      if (mounted) {
        context.showError('Failed to delete "${item.label}". Item restored.');
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pairings tab — shows the bizStep ↔ disposition relation table
// ─────────────────────────────────────────────────────────────────────────────

class _PairingsTab extends StatelessWidget {
  const _PairingsTab({
    required this.state,
    required this.searchQuery,
    required this.isAdmin,
    required this.onRefresh,
  });

  final AdminCbvVocabularyState state;
  final String searchQuery;
  final bool isAdmin;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final bizStepMap = {for (final b in state.bizSteps) b.code: b};
    final dispMap = {for (final d in state.dispositions) d.code: d};

    // Build a unified list of bizSteps — those with pairs appear with their
    // dispositions, those without appear as empty rows so admin can add.
    final allBizCodes = state.bizSteps.map((b) => b.code).toList();

    final filtered = allBizCodes.where((biz) {
      if (searchQuery.isEmpty) return true;
      final item = bizStepMap[biz];
      if (item == null) return false;
      return item.label.toLowerCase().contains(searchQuery) ||
          biz.contains(searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty
              ? 'No biz steps match "$searchQuery".'
              : 'No biz steps found.',
          style: context.text.body.copyWith(color: context.colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.padding.left,
        vertical: TraqSpacing.md,
      ),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final bizCode = filtered[i];
        final bizItem = bizStepMap[bizCode];
        if (bizItem == null) return const SizedBox.shrink();
        final pairedCodes = state.pairMap[bizCode] ?? [];
        return _PairingRow(
          bizItem: bizItem,
          pairedCodes: pairedCodes,
          allDispositions: state.dispositions,
          dispMap: dispMap,
          pairingKeys: state.pairingKeys,
          isAdmin: isAdmin,
          onAdd: (dispCode) async {
            try {
              await context
                  .read<AdminCbvVocabularyCubit>()
                  .addPair(bizCode, dispCode);
            } catch (_) {
              if (context.mounted) {
                context.showError('Failed to add pairing.');
              }
            }
          },
          onRemove: (dispCode) async {
            try {
              await context
                  .read<AdminCbvVocabularyCubit>()
                  .removePair(bizCode, dispCode);
            } catch (_) {
              if (context.mounted) {
                context.showError('Failed to remove pairing.');
              }
            }
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// One row in the pairings table
// ─────────────────────────────────────────────────────────────────────────────

class _PairingRow extends StatelessWidget {
  const _PairingRow({
    required this.bizItem,
    required this.pairedCodes,
    required this.allDispositions,
    required this.dispMap,
    required this.pairingKeys,
    required this.isAdmin,
    required this.onAdd,
    required this.onRemove,
  });

  final CbvVocabularyItem bizItem;
  final List<String> pairedCodes;
  final List<CbvVocabularyItem> allDispositions;
  final Map<String, CbvVocabularyItem> dispMap;
  final Set<String> pairingKeys;
  final bool isAdmin;
  final Future<void> Function(String dispCode) onAdd;
  final Future<void> Function(String dispCode) onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unpairedDispositions =
        allDispositions.where((d) => !pairedCodes.contains(d.code)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BizStep label ──────────────────────────────────────────────
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bizItem.label,
                  style: context.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: bizItem.enabled
                        ? colors.primary
                        : colors.textFaint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bizItem.code,
                  style: context.text.mono.copyWith(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
                if (!bizItem.enabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _StatusChip(
                      label: 'Disabled',
                      color: colors.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: TraqSpacing.lg),
          // ── Disposition chips ──────────────────────────────────────────
          Expanded(
            child: Wrap(
              spacing: TraqSpacing.sm,
              runSpacing: TraqSpacing.xs,
              children: [
                // Paired disposition chips (with × remove)
                for (final dispCode in pairedCodes) ...[
                  _DispChip(
                    label: dispMap[dispCode]?.label ?? dispCode,
                    code: dispCode,
                    isPending: pairingKeys.contains(
                        '${bizItem.code}|$dispCode'),
                    isAdmin: isAdmin,
                    onRemove: () => onRemove(dispCode),
                  ),
                ],
                // Add pairing button (admin only)
                if (isAdmin && unpairedDispositions.isNotEmpty)
                  _AddPairChip(
                    bizCode: bizItem.code,
                    available: unpairedDispositions,
                    onAdd: onAdd,
                  ),
                if (pairedCodes.isEmpty && !isAdmin)
                  Text(
                    'No pairings',
                    style: context.text.bodySm
                        .copyWith(color: colors.textFaint),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Disposition chip with optional remove button
// ─────────────────────────────────────────────────────────────────────────────

class _DispChip extends StatelessWidget {
  const _DispChip({
    required this.label,
    required this.code,
    required this.isPending,
    required this.isAdmin,
    required this.onRemove,
  });

  final String label;
  final String code;
  final bool isPending;
  final bool isAdmin;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isPending) {
      return Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: context.text.cap
                    .copyWith(color: colors.textSecondary)),
            const SizedBox(width: 4),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: colors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: colors.surfaceMuted,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Chip(
      label: Text(
        label,
        style: context.text.cap.copyWith(color: colors.textSecondary),
      ),
      deleteIcon: isAdmin
          ? Icon(Icons.close, size: 14, color: colors.textMuted)
          : null,
      onDeleted: isAdmin ? onRemove : null,
      backgroundColor: colors.primaryMuted,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "+" chip that opens a popup to pick a disposition to pair
// ─────────────────────────────────────────────────────────────────────────────

class _AddPairChip extends StatelessWidget {
  const _AddPairChip({
    required this.bizCode,
    required this.available,
    required this.onAdd,
  });

  final String bizCode;
  final List<CbvVocabularyItem> available;
  final Future<void> Function(String dispCode) onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ActionChip(
      avatar: Icon(Icons.add, size: 14, color: colors.primary),
      label: Text(
        'Add',
        style: context.text.cap.copyWith(color: colors.primary),
      ),
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.primary.withOpacity(0.4)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => _showPicker(context),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Disposition Pairing'),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 340,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: available.length,
            itemBuilder: (_, i) {
              final d = available[i];
              return ListTile(
                dense: true,
                title: Text(d.label),
                subtitle: Text(d.code,
                    style: const TextStyle(fontSize: 11)),
                trailing: d.enabled
                    ? null
                    : const _StatusChip(label: 'Disabled'),
                onTap: () => Navigator.of(ctx).pop(d.code),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (chosen != null) {
      await onAdd(chosen);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flat vocabulary table (Biz Steps or Dispositions tab)
// ─────────────────────────────────────────────────────────────────────────────

class _VocabFlatTab extends StatelessWidget {
  const _VocabFlatTab({
    required this.items,
    required this.searchQuery,
    required this.isAdmin,
    required this.isBizStep,
    required this.togglingCodes,
    required this.deletingCodes,
    required this.onToggle,
    required this.onDelete,
  });

  final List<CbvVocabularyItem> items;
  final String searchQuery;
  final bool isAdmin;
  final bool isBizStep;
  final Set<String> togglingCodes;
  final Set<String> deletingCodes;
  final Future<void> Function(CbvVocabularyItem, bool) onToggle;
  final Future<void> Function(CbvVocabularyItem) onDelete;

  List<CbvVocabularyItem> get _filtered {
    if (searchQuery.isEmpty) return items;
    return items.where((item) {
      return item.label.toLowerCase().contains(searchQuery) ||
          item.code.toLowerCase().contains(searchQuery) ||
          item.urn.toLowerCase().contains(searchQuery) ||
          (item.group?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty
              ? 'No items match "$searchQuery".'
              : 'No ${isBizStep ? 'biz steps' : 'dispositions'} found.',
          style: context.text.body.copyWith(color: context.colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.padding.left,
        vertical: TraqSpacing.md,
      ),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = filtered[i];
        final isToggling = togglingCodes.contains(item.code);
        final isDeleting = deletingCodes.contains(item.code);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: TraqSpacing.xs,
          ),
          title: Row(
            children: [
              Text(item.label, style: context.text.body),
              const SizedBox(width: TraqSpacing.sm),
              if (item.isCustom)
                _StatusChip(
                  label: 'Custom',
                  color: context.colors.warning,
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.code,
                style: context.text.mono
                    .copyWith(fontSize: 11, color: context.colors.textMuted),
              ),
              if (item.group != null)
                Text(
                  item.group!,
                  style: context.text.cap.copyWith(
                      color: context.colors.textFaint, fontSize: 10),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enable toggle
              if (isAdmin)
                isToggling
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch.adaptive(
                        value: item.enabled,
                        onChanged: (v) => onToggle(item, v),
                      )
              else
                _StatusChip(
                  label: item.enabled ? 'Enabled' : 'Disabled',
                  color: item.enabled
                      ? context.colors.success
                      : context.colors.error,
                ),
              // Delete (custom only, admin only)
              if (isAdmin && item.isCustom) ...[
                const SizedBox(width: TraqSpacing.sm),
                isDeleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: context.colors.error, size: 20),
                        tooltip: 'Delete',
                        onPressed: () => onDelete(item),
                      ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: context.text.cap.copyWith(color: c, fontSize: 10),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
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
