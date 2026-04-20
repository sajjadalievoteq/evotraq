import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';

class RuleEditorRouteScreen extends StatefulWidget {
  final String ruleId;
  final bool isPredefined;
  final bool isNew;

  const RuleEditorRouteScreen({
    super.key,
    required this.ruleId,
    required this.isPredefined,
    this.isNew = false,
  });

  @override
  State<RuleEditorRouteScreen> createState() => _RuleEditorRouteScreenState();
}

class _RuleEditorRouteScreenState extends State<RuleEditorRouteScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ValidationRuleCubit>();
    if (!widget.isNew &&
        cubit.getRuleByRuleId(widget.ruleId) == null &&
        !cubit.isLoading) {
      cubit.loadValidationRules();
    }
  }

  ValidationRule _buildNewRule() {
    return ValidationRule(
      ruleId: widget.ruleId,
      name: '',
      description: '',
      severity: RuleSeverity.WARNING,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNew) {
      return RuleEditorScreen(
        rule: _buildNewRule(),
        isPredefined: false,
        isNew: true,
      );
    }

    return BlocBuilder<ValidationRuleCubit, ValidationRuleState>(
      builder: (context, state) {
        final rule = context.read<ValidationRuleCubit>().getRuleByRuleId(
          widget.ruleId,
        );

        if (rule != null) {
          return RuleEditorScreen(
            rule: rule,
            isPredefined: widget.isPredefined,
          );
        }

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Rule Editor')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'The requested validation rule could not be found.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A screen for editing validation rules
class RuleEditorScreen extends StatefulWidget {
  /// The rule to edit
  final ValidationRule rule;

  /// Whether this is a predefined rule
  final bool isPredefined;

  /// Whether this is a new rule
  final bool isNew;

  /// Constructor
  const RuleEditorScreen({
    Key? key,
    required this.rule,
    required this.isPredefined,
    this.isNew = false,
  }) : super(key: key);

  @override
  State<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends State<RuleEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _fieldController;
  late TextEditingController _ruleExpressionController;
  late TextEditingController _errorMessageController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  late TextEditingController _priorityController;
  late String? _eventType;
  late RuleSeverity _severity;
  late bool _enabled;

  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule.name);
    _descriptionController = TextEditingController(
      text: widget.rule.description ?? '',
    );
    _fieldController = TextEditingController(text: widget.rule.field ?? '');
    _ruleExpressionController = TextEditingController(
      text: widget.rule.ruleExpression ?? '',
    );
    _errorMessageController = TextEditingController(
      text: widget.rule.errorMessage ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.rule.category ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.rule.tags?.join(', ') ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.rule.priority?.toString() ?? '100',
    );
    _eventType = _mapBackendEventTypeToDropdownValue(widget.rule.eventType);
    _severity = widget.rule.severity;
    _enabled = widget.rule.enabled;

    // Add listeners to detect changes
    _nameController.addListener(_markAsChanged);
    _descriptionController.addListener(_markAsChanged);
    _fieldController.addListener(_markAsChanged);
    _ruleExpressionController.addListener(_markAsChanged);
    _errorMessageController.addListener(_markAsChanged);
    _categoryController.addListener(_markAsChanged);
    _tagsController.addListener(_markAsChanged);
    _priorityController.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fieldController.dispose();
    _ruleExpressionController.dispose();
    _errorMessageController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.isNew
        ? 'Add New Rule'
        : (widget.isPredefined ? 'Edit Predefined Rule' : 'Edit Custom Rule');

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        actions: [
          if (!widget.isNew && !widget.isPredefined)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteRule(),
              tooltip: 'Delete rule',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isPredefined)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      color: Color(0xFFFFF9C4), // Light yellow background
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'This is a predefined system rule. You can modify its severity and '
                          'enable/disable status, but other properties cannot be changed.',
                          style: TextStyle(color: Colors.brown),
                        ),
                      ),
                    ),
                  ),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Rule Name',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.isPredefined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Rule name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: !widget.isPredefined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildEventTypeDropdown(),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _fieldController,
                  decoration: const InputDecoration(
                    labelText: 'Field Path',
                    hintText:
                        r'e.g., $.eventTime, $.businessStep, $.epcList[*]',
                    border: OutlineInputBorder(),
                    helperText: 'JSONPath expression for the field to validate',
                  ),
                  enabled: !widget.isPredefined,
                ),
                const SizedBox(height: 16),

                // Rule Expression - Advanced validation logic
                TextFormField(
                  controller: _ruleExpressionController,
                  decoration: const InputDecoration(
                    labelText: 'Rule Expression',
                    hintText: 'e.g., eventTime != null && eventTime <= now()',
                    border: OutlineInputBorder(),
                    helperText:
                        'Complex validation logic using JavaScript-like expressions',
                  ),
                  maxLines: 3,
                  enabled: !widget.isPredefined,
                ),
                const SizedBox(height: 16),

                // Error Message - Custom error message when validation fails
                TextFormField(
                  controller: _errorMessageController,
                  decoration: const InputDecoration(
                    labelText: 'Error Message',
                    hintText: 'Custom error message when validation fails',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  enabled: !widget.isPredefined,
                ),
                const SizedBox(height: 16),

                // Category - Business categorization
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText:
                        'e.g., REQUIRED, BUSINESS, REFERENTIAL, DATA_QUALITY',
                    border: OutlineInputBorder(),
                    helperText: 'Business category for organizing rules',
                  ),
                  enabled: !widget.isPredefined,
                ),
                const SizedBox(height: 16),

                // Tags - For organization and filtering
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'e.g., EPCIS, GS1, manufacturing, pharma',
                    border: OutlineInputBorder(),
                    helperText: 'Comma-separated tags for organization',
                  ),
                  enabled: !widget.isPredefined,
                ),
                const SizedBox(height: 16),

                // Priority - Execution order
                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    hintText: '1-1000 (lower numbers = higher priority)',
                    border: OutlineInputBorder(),
                    helperText: 'Execution priority (1=highest, 1000=lowest)',
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !widget.isPredefined,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final priority = int.tryParse(value);
                      if (priority == null || priority < 1 || priority > 1000) {
                        return 'Priority must be between 1 and 1000';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildSeveritySelector(),
                const SizedBox(height: 24),

                SwitchListTile(
                  title: const Text('Enable Rule'),
                  subtitle: const Text('Turn this rule on or off'),
                  value: _enabled,
                  onChanged: (value) {
                    setState(() {
                      _enabled = value;
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 32),

                Center(
                  child: ElevatedButton(
                    onPressed: _hasChanges ? _saveChanges : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    const eventTypes = [
      {'label': 'All Event Types', 'value': null},
      {'label': 'Object Event', 'value': 'ObjectEvent'},
      {'label': 'Aggregation Event', 'value': 'AggregationEvent'},
      {'label': 'Transaction Event', 'value': 'TransactionEvent'},
      {'label': 'Transformation Event', 'value': 'TransformationEvent'},
    ];

    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(),
      ),
      value: _eventType,
      items: eventTypes.map((type) {
        return DropdownMenuItem<String?>(
          value: type['value'],
          child: Text(type['label'] as String),
        );
      }).toList(),
      onChanged: widget.isPredefined
          ? null
          : (value) {
              setState(() {
                _eventType = value;
                _hasChanges = true;
              });
            },
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rule Severity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12.0,
          children: RuleSeverity.values.map((severity) {
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    severity.icon,
                    size: 18,
                    color: _severity == severity
                        ? Colors.white
                        : severity.color,
                  ),
                  const SizedBox(width: 8),
                  Text(severity.displayName),
                ],
              ),
              selected: _severity == severity,
              selectedColor: severity.color,
              labelStyle: TextStyle(
                color: _severity == severity ? Colors.white : null,
                fontWeight: _severity == severity
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _severity = severity;
                    _hasChanges = true;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedRule = widget.rule.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      field: _fieldController.text.trim().isEmpty
          ? null
          : _fieldController.text.trim(),
      ruleExpression: _ruleExpressionController.text.trim().isEmpty
          ? null
          : _ruleExpressionController.text.trim(),
      errorMessage: _errorMessageController.text.trim().isEmpty
          ? null
          : _errorMessageController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      tags: _tagsController.text.trim().isEmpty
          ? null
          : _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
      priority: _priorityController.text.trim().isEmpty
          ? 100
          : int.tryParse(_priorityController.text.trim()),
      eventType: _eventType != null ? _parseEventType(_eventType!) : null,
      severity: _severity,
      enabled: _enabled,
    );

    final cubit = context.read<ValidationRuleCubit>();

    if (widget.isNew) {
      cubit.addRule(updatedRule).then((_) {
        Navigator.of(context).pop();
      });
    } else {
      cubit.updateRule(updatedRule).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  EventType? _parseEventType(String value) {
    switch (value) {
      case 'All':
      case 'ALL':
        return EventType.ALL;
      case 'ObjectEvent':
        return EventType.ObjectEvent;
      case 'AggregationEvent':
        return EventType.AggregationEvent;
      case 'TransactionEvent':
        return EventType.TransactionEvent;
      case 'TransformationEvent':
        return EventType.TransformationEvent;
      default:
        return null;
    }
  }

  /// Maps backend EventType values to dropdown values
  String? _mapBackendEventTypeToDropdownValue(EventType? eventType) {
    if (eventType == null) return null;

    switch (eventType) {
      case EventType.ALL:
        return null; // "All Event Types" option in dropdown
      case EventType.ObjectEvent:
        return 'ObjectEvent';
      case EventType.AggregationEvent:
        return 'AggregationEvent';
      case EventType.TransactionEvent:
        return 'TransactionEvent';
      case EventType.TransformationEvent:
        return 'TransformationEvent';
    }
  }

  void _confirmDeleteRule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: const Text(
          'Are you sure you want to delete this rule? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ValidationRuleCubit>().deleteRule(widget.rule).then((
                _,
              ) {
                Navigator.of(context).pop();
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
