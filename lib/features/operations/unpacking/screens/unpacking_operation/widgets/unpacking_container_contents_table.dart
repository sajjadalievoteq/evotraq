import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';

/// Table of items currently packed in the parent container.
class UnpackingContainerContentsTable extends StatelessWidget {
  const UnpackingContainerContentsTable({
    super.key,
    required this.parentContainerId,
    required this.contents,
    required this.scope,
    required this.selectedEpcs,
    required this.onSelectionChanged,
    this.isLoading = false,
    this.loadError,
    this.onRetry,
  });

  final String? parentContainerId;
  final List<HierarchyNode> contents;
  final UnpackingScope scope;
  final Set<String> selectedEpcs;
  final void Function(String epc, bool selected) onSelectionChanged;
  final bool isLoading;
  final String? loadError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant;
    final parentLabel = parentContainerId ?? '—';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Packed in container',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              scope == UnpackingScope.wholeContainer
                  ? '${contents.length} direct child EPC(s) — all will be unpacked on submit.'
                  : '${selectedEpcs.length} of ${contents.length} selected. '
                      'Tick rows below, or add items by scanning / typing an EPC.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (loadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(loadError!, style: TextStyle(color: theme.colorScheme.error)),
                    if (onRetry != null) ...[
                      const SizedBox(height: 8),
                      TextButton(onPressed: onRetry, child: const Text('Retry')),
                    ],
                  ],
                ),
              )
            else if (contents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No packed items found in this container.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 44,
                      dataRowMaxHeight: 56,
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Unpack')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('EPC')),
                        DataColumn(label: Text('Parent container')),
                      ],
                      rows: contents.map((node) {
                        final selected = scope == UnpackingScope.wholeContainer ||
                            selectedEpcs.contains(node.epc);
                        return DataRow(
                          selected: selected,
                          cells: [
                            if (scope == UnpackingScope.partial)
                              DataCell(
                                Checkbox(
                                  value: selected,
                                  onChanged: (value) => onSelectionChanged(
                                    node.epc,
                                    value ?? false,
                                  ),
                                ),
                              )
                            else
                              DataCell(
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            DataCell(Text(node.type)),
                            DataCell(
                              Tooltip(
                                message: node.epc,
                                child: SizedBox(
                                  width: 280,
                                  child: Text(
                                    node.epc,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        const TextStyle(fontFamily: 'monospace'),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                parentLabel.length > 24
                                    ? '…${parentLabel.substring(parentLabel.length - 24)}'
                                    : parentLabel,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
