import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:uuid/uuid.dart';

/// A screen for managing validation rules
class ValidationRuleManagementScreen extends StatefulWidget {
  /// Constructor
  const ValidationRuleManagementScreen({Key? key}) : super(key: key);

  @override
  State<ValidationRuleManagementScreen> createState() =>
      _ValidationRuleManagementScreenState();
}

class _ValidationRuleManagementScreenState
    extends State<ValidationRuleManagementScreen> {
  String _filter = '';
  String _selectedEventType = '';
  RuleSeverity? _selectedSeverity;
  bool _showOnlyCustomRules = false;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    // No need to explicitly load rules, the provider does this in its constructor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Rule Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelp(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to defaults',
            onPressed: () => _confirmResetToDefaults(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildRuleList()),
        ],
      ),
      floatingActionButton: _buildFloatingMenu(),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search rules...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _filter = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Types'),
                  selected: _selectedEventType.isEmpty,
                  onSelected: (selected) {
                    setState(() {
                      _selectedEventType = '';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Object'),
                  selected: _selectedEventType == 'ObjectEvent',
                  onSelected: (selected) {
                    setState(() {
                      _selectedEventType = selected ? 'ObjectEvent' : '';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Aggregation'),
                  selected: _selectedEventType == 'AggregationEvent',
                  onSelected: (selected) {
                    setState(() {
                      _selectedEventType = selected ? 'AggregationEvent' : '';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Transaction'),
                  selected: _selectedEventType == 'TransactionEvent',
                  onSelected: (selected) {
                    setState(() {
                      _selectedEventType = selected ? 'TransactionEvent' : '';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Transformation'),
                  selected: _selectedEventType == 'TransformationEvent',
                  onSelected: (selected) {
                    setState(() {
                      _selectedEventType = selected
                          ? 'TransformationEvent'
                          : '';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Common'),
                  selected: _selectedEventType == 'Common',
                  onSelected: (selected) {
                    setState(() {
                      _selectedEventType = selected ? 'Common' : '';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Severities'),
                  selected: _selectedSeverity == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeverity = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...RuleSeverity.values.map(
                  (severity) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(severity.displayName),
                      selected: _selectedSeverity == severity,
                      selectedColor: severity.color.withOpacity(0.2),
                      onSelected: (selected) {
                        setState(() {
                          _selectedSeverity = selected ? severity : null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Custom Rules Only'),
                  selected: _showOnlyCustomRules,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyCustomRules = selected;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Help button
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isFabOpen ? 56.0 : 0.0,
          child: _isFabOpen
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    heroTag: "help",
                    mini: true,
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false;
                      });
                      _showHelp();
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.help_outline),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Import rules button
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isFabOpen ? 56.0 : 0.0,
          child: _isFabOpen
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    heroTag: "import",
                    mini: true,
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false;
                      });
                      _importRules();
                    },
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.file_upload),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Add rule button
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isFabOpen ? 56.0 : 0.0,
          child: _isFabOpen
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    heroTag: "add",
                    mini: true,
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false;
                      });
                      _addNewRule();
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Main FAB
        FloatingActionButton(
          heroTag: "main",
          onPressed: () {
            setState(() {
              _isFabOpen = !_isFabOpen;
            });
          },
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isFabOpen ? 0.125 : 0.0, // 45 degrees when open
            child: Icon(_isFabOpen ? Icons.close : Icons.menu),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleList() {
    return BlocBuilder<ValidationRuleCubit, ValidationRuleState>(
      builder: (context, state) {
        final cubit = context.read<ValidationRuleCubit>();
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading rules: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cubit.reloadRules(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Apply filters
        List<ValidationRule> filteredRules = state.validationRules;

        // Custom rules filter
        if (_showOnlyCustomRules) {
          final predefinedRuleIds = cubit
              .getPredefinedRules()
              .map((r) => r.id)
              .toSet();
          filteredRules = filteredRules
              .where((r) => !predefinedRuleIds.contains(r.id))
              .toList();
        }

        // Event type filter
        if (_selectedEventType.isNotEmpty) {
          if (_selectedEventType == 'Common') {
            filteredRules = filteredRules
                .where((r) => r.eventType == null)
                .toList();
          } else {
            filteredRules = filteredRules
                .where((r) => r.eventType == _selectedEventType)
                .toList();
          }
        }

        // Severity filter
        if (_selectedSeverity != null) {
          filteredRules = filteredRules
              .where((r) => r.severity == _selectedSeverity)
              .toList();
        }

        // Text search
        if (_filter.isNotEmpty) {
          final searchLower = _filter.toLowerCase();
          filteredRules = filteredRules
              .where(
                (r) =>
                    r.name.toLowerCase().contains(searchLower) ||
                    (r.description?.toLowerCase().contains(searchLower) ??
                        false) ||
                    (r.field?.toLowerCase().contains(searchLower) ?? false),
              )
              .toList();
        }

        if (filteredRules.isEmpty) {
          return const Center(
            child: Text('No rules match the current filters'),
          );
        }

        return ListView.builder(
          itemCount: filteredRules.length,
          itemBuilder: (context, index) {
            final rule = filteredRules[index];
            final isPredefined = cubit.getPredefinedRules().any(
              (r) => r.id == rule.id,
            );

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: rule.severity.color.withOpacity(0.5),
                  width: 1.0,
                ),
              ),
              child: ListTile(
                title: Text(rule.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.description ?? 'No description'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (rule.eventType != null) ...[
                          Chip(
                            label: Text(
                              rule.eventType!
                                  .toString()
                                  .split('.')
                                  .last
                                  .replaceAll('Event', ''),
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (rule.field != null) ...[
                          Chip(
                            label: Text(
                              rule.field!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                        const Spacer(),
                        Chip(
                          avatar: Icon(
                            rule.severity.icon,
                            size: 16,
                            color: rule.severity.color,
                          ),
                          label: Text(
                            rule.severity.displayName,
                            style: TextStyle(
                              color: rule.severity.color,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: rule.severity.color.withOpacity(0.1),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Switch(
                  value: rule.enabled,
                  onChanged: (value) {
                    final updatedRule = rule.copyWith(enabled: value);
                    cubit.updateRule(updatedRule);
                  },
                ),
                onTap: () => _editRule(rule, isPredefined),
              ),
            );
          },
        );
      },
    );
  }

  void _editRule(ValidationRule rule, bool isPredefined) {
    context.push(
      '/admin/validation-rules/${Uri.encodeComponent(rule.ruleId)}/edit'
      '?predefined=$isPredefined',
    );
  }

  void _addNewRule() {
    final ruleId = 'custom_${const Uuid().v4()}';

    context.push('/admin/validation-rules/new/${Uri.encodeComponent(ruleId)}');
  }

  void _confirmResetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will remove all custom rules and reset all predefined rules to their default settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ValidationRuleCubit>().resetToDefaults();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    context.push('/admin/validation-rules/help');
  }

  void _importRules() {
    // TODO: Implement rule import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rule import functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
