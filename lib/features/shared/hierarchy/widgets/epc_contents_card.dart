import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_hierarchy_row.dart';

class EpcContentsCard extends StatefulWidget {
  const EpcContentsCard({
    super.key,
    required this.title,
    required this.epcs,
    required this.emptyMessage,
    required this.hierarchyScreenTitle,
    this.initialPageSize = 20,
  });

  final String title;
  final List<String> epcs;
  final String emptyMessage;
  final String hierarchyScreenTitle;
  final int initialPageSize;

  @override
  State<EpcContentsCard> createState() => _EpcContentsCardState();
}

class _EpcContentsCardState extends State<EpcContentsCard> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.epcs;

    return Gs1GroupCard(
      title: widget.title,
      outlineColor: theme.colorScheme.outlineVariant,
      child: items.isEmpty
          ? Text(widget.emptyMessage)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...(_showAll
                        ? items
                        : items.take(widget.initialPageSize).toList())
                    .map(
                  (epc) => EpcHierarchyRow(
                    epc: epc,
                    hierarchyScreenTitle: widget.hierarchyScreenTitle,
                  ),
                ),
                if (items.length > widget.initialPageSize && !_showAll)
                  TextButton(
                    onPressed: () => setState(() => _showAll = true),
                    child: Text('Show all ${items.length} items'),
                  ),
              ],
            ),
    );
  }
}
