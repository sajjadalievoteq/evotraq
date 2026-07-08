import 'package:flutter/material.dart';

import 'package:traqtrace_app/core/utils/responsive_utils.dart';

import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';

import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';


class PackingReviewStep extends StatelessWidget {

  const PackingReviewStep({

    super.key,

    required this.packingLocationGln,

    required this.workOrder,

    required this.batchNumber,

    required this.productionOrder,

    required this.parentContainerId,

    required this.scannedEpcs,

    required this.closeContainer,

    required this.onCloseContainerChanged,

    this.eventTime,

    this.showPageHeader = true,

  });


  final GLN? packingLocationGln;

  final String workOrder;

  final String batchNumber;

  final String productionOrder;

  final String? parentContainerId;

  final List<String> scannedEpcs;

  final bool closeContainer;

  final ValueChanged<bool> onCloseContainerChanged;

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

          const SectionLabel('Review Packing Operation'),

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

                SgtinInfoRow('Packing Reference', 'Auto-generated on submit'),

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

                  packingLocationGln?.locationName ??

                      packingLocationGln?.glnCode,

                ),

                const SizedBox(height: 12),

                SgtinInfoRow(

                  'Parent Container',

                  parentContainerId,

                  monospace: true,

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

            title: 'Items to Pack (${scannedEpcs.length})',

            outlineColor: outline,

            child: scannedEpcs.isEmpty

                ? const SgtinInfoRow('Items', 'None added yet')

                : ConstrainedBox(

                    constraints: const BoxConstraints(maxHeight: 200),

                    child: ListView.separated(

                      shrinkWrap: true,

                      itemCount: scannedEpcs.length,

                      separatorBuilder: (_, __) => const SizedBox(height: 8),

                      itemBuilder: (context, index) => SgtinInfoRow(

                        '${index + 1}',

                        scannedEpcs[index],

                        monospace: true,

                      ),

                    ),

                  ),

          ),

          const SizedBox(height: 16),

          Gs1GroupCard(

            title: 'Container Sealing',

            outlineColor: outline,

            margin: EdgeInsets.zero,

            child: SwitchListTile(

              contentPadding: EdgeInsets.zero,

              title: const Text('Seal container after packing'),

              subtitle: const Text(

                'Sets disposition to container_closed (GS1 CBV)',

                style: TextStyle(fontSize: 11),

              ),

              value: closeContainer,

              onChanged: onCloseContainerChanged,

            ),

          ),

        ],

      ),

    );

  }

}


