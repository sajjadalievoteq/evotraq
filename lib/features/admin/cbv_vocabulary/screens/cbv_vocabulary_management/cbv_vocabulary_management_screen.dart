import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_error_view.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_pairings_tab.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_statistics_header.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_vocab_flat_tab.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_vocabulary_form_dialog.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_vocabulary_skeleton.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/utils/cbv_vocabulary_search_utils.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

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

  bool get _isAdmin => context.read<AuthCubit>().state.user?.role == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = normalizeCbvSearchQuery(_searchController.text));
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
              leading: TraqIcon(NavIcons.aggregationEvents),
              title: const Text('Add Biz Step'),
              onTap: () {
                Navigator.of(dialogCtx).pop();
                _showCreateDialog(CbvVocabType.bizStep);
              },
            ),
            ListTile(
              leading: const TraqIcon(AppAssets.iconTag),
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
                  label: TraqIcon(AppAssets.iconPlus),
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
            return CbvErrorView(
              message: state.error ?? 'An error occurred.',
              onRetry: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: context.padding.top,
                    left: context.padding.left,
                    right: context.padding.right,
                  ),
                  child: CbvStatisticsHeader(state: state),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.padding.left,
                    vertical: TraqSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by label or code…',
                      prefixIcon: TraqIcon(AppAssets.iconSearch),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: TraqIcon(AppAssets.iconX),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: TraqRadius.input,
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: TraqSpacing.md,
                        horizontal: TraqSpacing.lg,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      CbvPairingsTab(
                        state: state,
                        searchQuery: _searchQuery,
                        isAdmin: isAdmin,
                      ),
                      CbvVocabFlatTab(
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
                        onDelete: (item) => _confirmDelete(item, isBizStep: true),
                      ),
                      CbvVocabFlatTab(
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
                                .toggleDisposition(item.code, enabled: enabled);
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
            style: FilledButton.styleFrom(backgroundColor: context.colors.error),
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
