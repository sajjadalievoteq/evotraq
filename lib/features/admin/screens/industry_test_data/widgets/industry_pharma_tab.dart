import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/widgets/industry_hierarchy_root_result_card.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/widgets/industry_test_action_card.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/widgets/industry_test_section_header.dart';

class IndustryPharmaTab extends StatelessWidget {
  const IndustryPharmaTab({
    super.key,
    required this.isDarkMode,
    required this.isLoading,
    required this.hierarchyLevelsController,
    required this.hierarchyChildrenController,
    this.lastHierarchyRunId,
    this.lastHierarchyRootEpc,
    this.lastHierarchyRootSscc,
    required this.onGeneratePharmaGTINs,
    required this.onGeneratePharmaGLNs,
    required this.onGeneratePharmaSGTINs,
    required this.onGeneratePharmaSSCCs,
    required this.onGeneratePharmaFullSupplyChain,
    required this.onGeneratePackedHierarchy,
    required this.onCleanupPackedHierarchy,
  });

  final bool isDarkMode;
  final bool isLoading;
  final TextEditingController hierarchyLevelsController;
  final TextEditingController hierarchyChildrenController;
  final String? lastHierarchyRunId;
  final String? lastHierarchyRootEpc;
  final String? lastHierarchyRootSscc;
  final VoidCallback onGeneratePharmaGTINs;
  final VoidCallback onGeneratePharmaGLNs;
  final VoidCallback onGeneratePharmaSGTINs;
  final VoidCallback onGeneratePharmaSSCCs;
  final VoidCallback onGeneratePharmaFullSupplyChain;
  final VoidCallback onGeneratePackedHierarchy;
  final VoidCallback onCleanupPackedHierarchy;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF121F17), const Color(0xFF2D4A3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const TraqIcon(AppAssets.iconMedical, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Pharmaceutical Industry Test Data',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate real pharmaceutical product data for the UAE market. '
                    'This includes major medications with accurate specifications.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            elevation: 3,
            color: const Color(0xFF1B3328),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'One-Click Connected Supply Chain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seeds master data and runs real operations (commissioning, packing, '
                    'shipping, receiving, returns, unpack, decommission) so operation lists, '
                    'Inbox, Outbox, and product journey screens populate with linked data.',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onGeneratePharmaFullSupplyChain,
                      icon: const TraqIcon(AppAssets.iconArrowR, color: Colors.white),
                      label: const Text('Generate Full Connected Pharma Supply Chain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2D4A3E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D4A3E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const TraqIcon(
                          NavIcons.productHierarchy,
                          color: Color(0xFF2D4A3E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Deep Packed Hierarchy (Product Hierarchy stress test)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Builds a nested SSCC chain for the Product Hierarchy screen. '
                    'Each level packs ~N direct children (N−1 leaf SGTINs + 1 nested SSCC; '
                    'deepest level is all SGTINs). Requires pharma GLN + GTIN already seeded. '
                    'Defaults: 10 levels × 100 children (~1k items).',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hierarchyLevelsController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Levels (1–12)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: hierarchyChildrenController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Children / level (1–200)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (lastHierarchyRunId != null) ...[
                    const SizedBox(height: 12),
                    IndustryHierarchyRootResultCard(sscc: lastHierarchyRootSscc, epc: lastHierarchyRootEpc, runId: lastHierarchyRunId),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              isLoading ? null : onGeneratePackedHierarchy,
                          icon: const TraqIcon(
                            NavIcons.aggregationHierarchy,
                            color: Colors.white,
                          ),
                          label: const Text('Generate Deep Hierarchy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D4A3E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLoading || lastHierarchyRunId == null
                              ? null
                              : onCleanupPackedHierarchy,
                          icon: const TraqIcon(AppAssets.iconXCircle),
                          label: const Text('Cleanup Last Run'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2D4A3E),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          IndustryTestSectionHeader('Master Data Generation', NavIcons.masterData),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: IndustryTestActionCard(
                  title: 'Generate GTINs',
                  description: 'Create 50 pharmaceutical product GTINs with complete '
                      'pharma extension data (active ingredient, dosage, etc.)',
                  iconAsset: AppAssets.iconQr,
                  color: const Color(0xFF2D4A3E),
                  onPressed: isLoading ? null : onGeneratePharmaGTINs,
                  buttonText: 'Generate 50 GTINs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: IndustryTestActionCard(
                  title: 'Generate GLNs',
                  description: 'Create 50 pharmaceutical-related location GLNs '
                      '(manufacturers, wholesalers, pharmacies, hospitals)',
                  iconAsset: AppAssets.iconMapPin,
                  color: const Color(0xFF2D4A3E),
                  onPressed: isLoading ? null : onGeneratePharmaGLNs,
                  buttonText: 'Generate 50 GLNs',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          IndustryTestSectionHeader('Serialization', AppAssets.iconNumbers),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: IndustryTestActionCard(
                  title: 'Generate SSCCs',
                  description: 'Create shipping containers with pharma extension data '
                      '(temperature control, batch tracking)',
                  iconAsset: AppAssets.iconBox,
                  color: const Color(0xFF2D4A3E),
                  onPressed: isLoading ? null : onGeneratePharmaSSCCs,
                  buttonText: 'Generate 50 SSCCs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: IndustryTestActionCard(
                  title: 'Generate SGTINs',
                  description: 'Create serialized pharmaceutical products with batch, '
                      'expiry date, and lot number',
                  iconAsset: AppAssets.iconQr,
                  color: const Color(0xFF2D4A3E),
                  onPressed: isLoading ? null : onGeneratePharmaSGTINs,
                  buttonText: 'Generate SGTINs',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          IndustryTestSectionHeader('EPCIS Events', NavIcons.epcisEvents),
          const SizedBox(height: 12),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D4A3E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TraqIcon(NavIcons.epcisEvents, color: Color(0xFF2D4A3E), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Generate Full Supply Chain',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Creates lifecycle EPCIS events via real operations (same as Connected Supply Chain):\n'
                    '• Commissioning (SGTIN + SSCC)\n'
                    '• Packing / aggregation\n'
                    '• Shipping & receiving (manufacturer → distributor → pharmacy)\n'
                    'Raw event inserts are disabled so Product Journey never shows duplicate steps.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onGeneratePharmaFullSupplyChain,
                      icon: TraqIcon(AppAssets.iconArrowR),
                      label: const Text('Generate via Connected Supply Chain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4A3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}