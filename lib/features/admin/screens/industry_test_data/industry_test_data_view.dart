import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/widgets/industry_pharma_tab.dart';

class IndustryTestDataView extends StatelessWidget {
  const IndustryTestDataView({
    super.key,
    required this.tabController,
    required this.statusMessage,
    required this.isError,
    required this.isLoading,
    required this.gtinProgress,
    required this.gtinTotal,
    required this.glnProgress,
    required this.glnTotal,
    required this.sgtinProgress,
    required this.sgtinTotal,
    required this.ssccProgress,
    required this.ssccTotal,
    required this.eventProgress,
    required this.eventTotal,
    required this.hierarchyLevelsController,
    required this.hierarchyChildrenController,
    required this.lastHierarchyRunId,
    required this.lastHierarchyRootEpc,
    required this.lastHierarchyRootSscc,
    required this.onGeneratePharmaGTINs,
    required this.onGeneratePharmaGLNs,
    required this.onGeneratePharmaSGTINs,
    required this.onGeneratePharmaSSCCs,
    required this.onGeneratePharmaFullSupplyChain,
    required this.onGeneratePackedHierarchy,
    required this.onCleanupPackedHierarchy,
  });
  final TabController tabController;
  final String? statusMessage;
  final bool isError;
  final bool isLoading;
  final int gtinProgress, gtinTotal, glnProgress, glnTotal;
  final int sgtinProgress, sgtinTotal, ssccProgress, ssccTotal;
  final int eventProgress, eventTotal;
  final TextEditingController hierarchyLevelsController;
  final TextEditingController hierarchyChildrenController;
  final String? lastHierarchyRunId, lastHierarchyRootEpc, lastHierarchyRootSscc;
  final VoidCallback onGeneratePharmaGTINs;
  final VoidCallback onGeneratePharmaGLNs;
  final VoidCallback onGeneratePharmaSGTINs;
  final VoidCallback onGeneratePharmaSSCCs;
  final VoidCallback onGeneratePharmaFullSupplyChain;
  final VoidCallback onGeneratePackedHierarchy;
  final VoidCallback onCleanupPackedHierarchy;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Industry Test Data Generation'),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: TraqIcon(AppAssets.iconMedical), text: 'Pharmaceutical'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (statusMessage != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: Material(
                color: isError
                    ? AppColorMapper.errorColor(context).withValues(alpha: 0.15)
                    : AppColorMapper.successColor(
                        context,
                      ).withValues(alpha: 0.15),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TraqIcon(
                        isError ? AppAssets.iconXCircle : AppAssets.iconInfo,
                        color: isError
                            ? AppColorMapper.errorColor(context)
                            : AppColorMapper.successColor(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          statusMessage!,
                          style: TextStyle(
                            color: isError
                                ? AppColorMapper.errorColor(context)
                                : AppColorMapper.successColor(context),
                          ),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          if (isLoading &&
              (gtinProgress > 0 ||
                  glnProgress > 0 ||
                  sgtinProgress > 0 ||
                  ssccProgress > 0 ||
                  eventProgress > 0))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (gtinProgress > 0)
                    LinearProgressIndicator(
                      value: gtinTotal > 0 ? gtinProgress / gtinTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (glnProgress > 0)
                    LinearProgressIndicator(
                      value: glnTotal > 0 ? glnProgress / glnTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (sgtinProgress > 0)
                    LinearProgressIndicator(
                      value: sgtinTotal > 0 ? sgtinProgress / sgtinTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (ssccProgress > 0)
                    LinearProgressIndicator(
                      value: ssccTotal > 0 ? ssccProgress / ssccTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (eventProgress > 0)
                    LinearProgressIndicator(
                      value: eventTotal > 0 ? eventProgress / eventTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                IndustryPharmaTab(
                  isDarkMode: isDarkMode,
                  isLoading: isLoading,
                  hierarchyLevelsController: hierarchyLevelsController,
                  hierarchyChildrenController: hierarchyChildrenController,
                  lastHierarchyRunId: lastHierarchyRunId,
                  lastHierarchyRootEpc: lastHierarchyRootEpc,
                  lastHierarchyRootSscc: lastHierarchyRootSscc,
                  onGeneratePharmaGTINs: onGeneratePharmaGTINs,
                  onGeneratePharmaGLNs: onGeneratePharmaGLNs,
                  onGeneratePharmaSGTINs: onGeneratePharmaSGTINs,
                  onGeneratePharmaSSCCs: onGeneratePharmaSSCCs,
                  onGeneratePharmaFullSupplyChain:
                      onGeneratePharmaFullSupplyChain,
                  onGeneratePackedHierarchy: onGeneratePackedHierarchy,
                  onCleanupPackedHierarchy: onCleanupPackedHierarchy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
