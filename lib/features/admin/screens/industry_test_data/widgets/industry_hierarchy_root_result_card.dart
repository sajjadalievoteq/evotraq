import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/widgets/industry_test_copyable_root_row.dart';

class IndustryHierarchyRootResultCard extends StatelessWidget {
  const IndustryHierarchyRootResultCard({
    super.key,
    this.sscc,
    this.epc,
    this.runId,
  });

  final String? sscc;
  final String? epc;
  final String? runId;

  @override
  Widget build(BuildContext context) {
    final ssccValue = sscc;
    final epcValue = epc;
    final runIdValue = runId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D4A3E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D4A3E).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Root parent — paste into Product Hierarchy search',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (ssccValue != null && ssccValue.isNotEmpty)
            IndustryTestCopyableRootRow(label: 'SSCC', value: ssccValue),
          if (epcValue != null && epcValue.isNotEmpty) ...[
            const SizedBox(height: 6),
            IndustryTestCopyableRootRow(label: 'EPC', value: epcValue),
          ],
          if (runIdValue != null && runIdValue.isNotEmpty) ...[
            const SizedBox(height: 6),
            IndustryTestCopyableRootRow(label: 'runId', value: runIdValue),
          ],
        ],
      ),
    );
  }
}
