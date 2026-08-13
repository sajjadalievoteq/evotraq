import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/automation_center/inbound_catalog.dart';
import 'package:traqtrace_app/features/automation_center/cubit/inbound_catalog_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/inbound_catalog_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/inbound_catalog_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';

IconData inboundCatalogCategoryIcon(String categoryId) {
  return switch (categoryId) {
    'authentication' => Icons.login_outlined,
    'master-data' => Icons.inventory_2_outlined,
    'serialization' => Icons.code_outlined,
    'operations' => Icons.local_shipping_outlined,
    'traceability' => Icons.account_tree_outlined,
    _ => Icons.api_outlined,
  };
}

class InboundApiCatalog extends StatefulWidget {
  const InboundApiCatalog({super.key});

  @override
  State<InboundApiCatalog> createState() => _InboundApiCatalogState();
}

class _InboundApiCatalogState extends State<InboundApiCatalog> {
  @override
  void initState() {
    super.initState();
    // Load only when this cubit instance has not completed a fetch yet.
    // Workspace-scoped cubit survives Outbound ↔ Inbound section switches.
    final cubit = context.read<InboundCatalogCubit>();
    if (cubit.state.status == InboundCatalogStatus.initial) {
      cubit.load();
    }
  }

  Future<void> _copy(
    BuildContext context,
    InboundCatalogEndpoint endpoint,
  ) async {
    await Clipboard.setData(ClipboardData(text: buildCatalogCurl(endpoint)));
    if (context.mounted) context.showSuccess('curl command copied');
  }

  Future<void> _downloadCollection(
    BuildContext context,
    InboundCatalogCategory category,
  ) async {
    try {
      final bytes = await context
          .read<InboundCatalogCubit>()
          .downloadPostmanCollection(category.id);
      web_download.downloadBytes(
        bytes: bytes,
        filename: 'traqtrace-${category.id}-collection.json',
        mimeType: 'application/json',
      );
      if (!context.mounted) return;
      context.showSuccess(
        '${category.title} collection downloaded with sample test data - '
        'import it into Postman and set the token variable.',
      );
    } catch (e) {
      if (!context.mounted) return;
      context.showError('Failed to download Postman collection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboundCatalogCubit, InboundCatalogState>(
      builder: (context, state) {
        // Keep existing catalog visible during refresh; skeleton only when
        // there is nothing to show yet.
        final showSkeleton = state.catalog == null &&
            (state.status == InboundCatalogStatus.loading ||
                state.status == InboundCatalogStatus.initial);
        if (showSkeleton) {
          return const InboundCatalogLoadingSkeleton();
        }

        if (state.status == InboundCatalogStatus.error &&
            state.catalog == null) {
          return SubscriptionErrorView(
            title: 'Unable to load API catalog',
            message: state.error ?? 'Failed to load inbound API catalog',
            onRetry: () =>
                context.read<InboundCatalogCubit>().load(force: true),
          );
        }

        final catalog = state.catalog;
        if (catalog == null || catalog.categories.isEmpty) {
          return SubscriptionErrorView(
            title: 'API catalog is empty',
            message:
                'No published inbound endpoints are available in this environment.',
            onRetry: () =>
                context.read<InboundCatalogCubit>().load(force: true),
          );
        }

        final selected = state.selectedCategory;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('API Collections', style: context.text.h3),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              'Select a collection to view B2B-Service-accessible endpoints, copy authenticated '
              'requests, or download the whole group as a Postman collection pre-filled '
              'with sample test data.',
              style: context.text.body.copyWith(color: context.colors.textMuted),
            ),
            const SizedBox(height: TraqSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 165,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: catalog.categories.length,
              itemBuilder: (context, index) {
                final category = catalog.categories[index];
                final isSelected = selected?.id == category.id;
                return Card(
                  color: isSelected ? context.colors.primary : null,
                  child: InkWell(
                    onTap: () => context
                        .read<InboundCatalogCubit>()
                        .selectCategory(category.id),
                    child: Padding(
                      padding: const EdgeInsets.all(TraqSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                inboundCatalogCategoryIcon(category.id),
                                color: isSelected
                                    ? Colors.white
                                    : context.colors.primary,
                              ),
                              const Spacer(),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : context.colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(
                                      '${category.endpoints.length}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? context.colors.primary
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TraqSpacing.sm),
                          Text(
                            category.title,
                            style: context.text.h3.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : context.colors.primary,
                            ),
                          ),
                          const SizedBox(height: TraqSpacing.xs),
                          Text(
                            category.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : context.colors.primary,
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _downloadCollection(context, category),
                              icon: Icon(
                                Icons.download,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : context.colors.primary,
                              ),
                              label: Text(
                                'Download collection',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : context.colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (selected != null) ...[
              const SizedBox(height: TraqSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${selected.title} endpoints',
                      style: context.text.h3,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _downloadCollection(context, selected),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download collection'),
                  ),
                ],
              ),
              ...selected.endpoints.map(
                (endpoint) => ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    '${endpoint.method}  ${buildCatalogExampleUrl(endpoint)}',
                  ),
                  subtitle: Text(endpoint.description),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    TraqSpacing.md,
                    0,
                    TraqSpacing.md,
                    TraqSpacing.md,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        'Request\n${formatCatalogRequestExample(endpoint)}\n\n'
                        'Response\n${endpoint.expectedResult.displayText}',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _copy(context, endpoint),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy as curl'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
