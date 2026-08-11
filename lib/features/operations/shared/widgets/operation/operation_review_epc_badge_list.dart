import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';

class OperationReviewEpcBadgeList extends StatelessWidget {
  const OperationReviewEpcBadgeList({
    super.key,
    required this.epcs,
    required this.outlineColor,
    this.titlePrefix = 'EPC List',
    this.emptyMessage = 'No EPCs added yet',
  });

  final List<String> epcs;
  final Color outlineColor;
  final String titlePrefix;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: '$titlePrefix (${epcs.length})',
      outlineColor: outlineColor,
      child: epcs.isEmpty
          ? Text(emptyMessage)
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: epcs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final epc = epcs[index];
                final badgeColor = OperationEpcTypeUtils.colorFromValue(
                  context,
                  epc,
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            epc,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: badgeColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              OperationEpcTypeUtils.labelFromValue(epc),
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
