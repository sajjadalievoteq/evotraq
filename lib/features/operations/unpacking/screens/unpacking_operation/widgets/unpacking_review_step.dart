import 'package:flutter/material.dart';

import 'package:traqtrace_app/core/utils/responsive_utils.dart';

import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';

import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';


class UnpackingReviewStep extends StatelessWidget {

  const UnpackingReviewStep({

    super.key,

    required this.unpackingLocationGln,

    required this.workOrder,

    required this.batchNumber,

    required this.productionOrder,

    required this.parentContainerId,

    required this.scannedEpcs,

    required this.unpackingScope,

    this.eventTime,

    this.showPageHeader = true,

  });


  final GLN? unpackingLocationGln;

  final String workOrder;

  final String batchNumber;

  final String productionOrder;

  final String? parentContainerId;

  final List<String> scannedEpcs;

  final UnpackingScope unpackingScope;

  final DateTime? eventTime;

  final bool showPageHeader;


  @override

  Widget build(BuildContext context) {

    final outline = Theme.of(context).colorScheme.outlineVariant;


    return SingleChildScrollView(

      physics: const ClampingScrollPhysics(),

      padding: ResponsiveUtils.paddingAll(context),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const SectionLabel('Review Unpacking Operation'),

          const SizedBox(height: 8),

          if (showPageHeader)

            const Text(

              'Please review all details before submitting.',

              style: TextStyle(color: Colors.grey),

            ),

          if (showPageHeader) const SizedBox(height: 16),

          Gs1GroupCard(

            title: 'Operation Details',

            outlineColor: outline,

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                SgtinInfoRow('Unpacking Reference', 'Auto-generated on submit'),

                const SizedBox(height: 12),

                SgtinInfoRow(
                  'Event Time',
                  eventTime != null
                      ? '${eventTime!.toLocal()}'.substring(0, 16)
                      : 'At time of submission',
                ),

                const SizedBox(height: 12),

                SgtinInfoRow(

                  'Location',

                  unpackingLocationGln?.locationName ??

                      unpackingLocationGln?.glnCode,

                ),

                const SizedBox(height: 12),

                SgtinInfoRow(

                  'Container to Unpack',

                  parentContainerId,

                  monospace: true,

                ),

                const SizedBox(height: 12),

                SgtinInfoRow(

                  'Unpack scope',

                  unpackingScope == UnpackingScope.wholeContainer

                      ? 'Whole container (${scannedEpcs.length} items)'

                      : 'Partial (${scannedEpcs.length} items)',

                ),

                if (workOrder.isNotEmpty) ...[

                  const SizedBox(height: 12),

                  SgtinInfoRow('Work Order', workOrder),

                ],

                if (batchNumber.isNotEmpty) ...[

                  const SizedBox(height: 12),

                  SgtinInfoRow('Batch / Lot Number', batchNumber),

                ],

                if (productionOrder.isNotEmpty) ...[

                  const SizedBox(height: 12),

                  SgtinInfoRow('Production Order', productionOrder),

                ],

              ],

            ),

          ),

          Gs1GroupCard(

            title: 'Items to Unpack (${scannedEpcs.length})',

            outlineColor: outline,

            child: scannedEpcs.isEmpty

                ? const SgtinInfoRow('Items', 'None added yet')

                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scannedEpcs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => SgtinInfoRow(
                      '${index + 1}',
                      scannedEpcs[index],
                      monospace: true,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          Gs1GroupCard(

            title: 'GS1 Event Summary',

            outlineColor: outline,

            margin: EdgeInsets.zero,

            child: const Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                SgtinInfoRow('Event Type', 'AggregationEvent'),

                SizedBox(height: 12),

                SgtinInfoRow('Action', 'DELETE'),

                SizedBox(height: 12),

                SgtinInfoRow(

                  'bizStep',

                  'https://ref.gs1.org/cbv/BizStep-unpacking',

                  monospace: true,

                ),

                SizedBox(height: 12),

                SgtinInfoRow(

                  'Disposition',

                  'https://ref.gs1.org/cbv/Disp-in_progress',

                  monospace: true,

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}

