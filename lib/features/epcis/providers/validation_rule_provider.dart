import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/epcis/validation_rule.dart';


import 'package:traqtrace_app/data/services/epcis/validation_rule_service.dart';

class ValidationRuleState extends Equatable {
  final List<ValidationRule> validationRules;
  final bool isLoading;
  final String? error;

  const ValidationRuleState({
    required this.validationRules,
    required this.isLoading,
    required this.error,
  });

  factory ValidationRuleState.initial() => const ValidationRuleState(
    validationRules: [],
    isLoading: false,
    error: null,
  );

  @override
  List<Object?> get props => [validationRules, isLoading, error];
}

class ValidationRuleCubit extends Cubit<ValidationRuleState> {
  final ValidationRuleService _validationRuleService;

  List<ValidationRule> _validationRules = [];
  bool _isLoading = false;
  String? _error;

  ValidationRuleCubit({
    ValidationRuleService? validationRuleService,
  }) : _validationRuleService =
           validationRuleService ?? getIt<ValidationRuleService>(),
       super(ValidationRuleState.initial()) {
    loadValidationRules();
  }

  List<ValidationRule> get validationRules =>
      List.unmodifiable(_validationRules);
  List<ValidationRule> get rules => List.unmodifiable(_validationRules);
  bool get isLoading => _isLoading;
  bool get loading => _isLoading;
  String? get error => _error;

  List<ValidationRule> get enabledRules =>
      _validationRules.where((rule) => rule.enabled).toList();

  List<ValidationRule> getRulesByEventType(EventType eventType) {
    return _validationRules
        .where(
          (rule) =>
              rule.eventType == eventType || rule.eventType == EventType.ALL,
        )
        .toList();
  }

  List<ValidationRule> getRulesByCategory(String category) {
    return _validationRules.where((rule) => rule.category == category).toList();
  }

  ValidationRule? getRuleById(int id) {
    try {
      return _validationRules.firstWhere((rule) => rule.id == id);
    } catch (e) {
      return null;
    }
  }

  ValidationRule? getRuleByRuleId(String ruleId) {
    try {
      return _validationRules.firstWhere((rule) => rule.ruleId == ruleId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadSampleRules() async {
    _setLoading(true);
    _setError(null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _validationRules = getSampleAdvancedRules();
      _emitState();
    } catch (e) {
      _setError('Failed to load sample rules: $e');
      if (kDebugMode) {
        print('Error loading sample rules: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadValidationRules() async {
    _setLoading(true);
    _setError(null);

    try {
      _validationRules = await _validationRuleService.getAllRules();
      _emitState();
    } catch (e) {
      _setError('API not available. Loading sample rules for demonstration.');
      if (kDebugMode) {
        print('Error loading validation rules from API: $e');
        print('Loading sample rules as fallback...');
      }
      await loadSampleRules();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleValidationRule(int ruleId, bool enabled) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedRule = await _validationRuleService.toggleRuleStatus(
        ruleId,
        enabled,
      );

      if (updatedRule != null) {
        final index = _validationRules.indexWhere((rule) => rule.id == ruleId);
        if (index != -1) {
          _validationRules[index] = updatedRule;
          _emitState();
          return true;
        }
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle validation rule: $e');
      if (kDebugMode) {
        print('Error toggling validation rule: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<ValidationRule?> createValidationRule(ValidationRule rule) async {
    _setLoading(true);
    _setError(null);

    try {
      final newRule = await _validationRuleService.createRule(rule);
      _validationRules.add(newRule);
      _emitState();
      return newRule;
    } catch (e) {
      _setError('Failed to create validation rule: $e');
      if (kDebugMode) {
        print('Error creating validation rule: $e');
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<ValidationRule?> updateValidationRule(
    int ruleId,
    ValidationRule rule,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedRule = await _validationRuleService.updateRule(ruleId, rule);

      if (updatedRule != null) {
        final index = _validationRules.indexWhere((r) => r.id == ruleId);
        if (index != -1) {
          _validationRules[index] = updatedRule;
          _emitState();
          return updatedRule;
        }
      }
      return null;
    } catch (e) {
      _setError('Failed to update validation rule: $e');
      if (kDebugMode) {
        print('Error updating validation rule: $e');
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteValidationRule(int ruleId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _validationRuleService.deleteRule(ruleId);

      if (success) {
        _validationRules.removeWhere((rule) => rule.id == ruleId);
        _emitState();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete validation rule: $e');
      if (kDebugMode) {
        print('Error deleting validation rule: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchValidationRules(String searchTerm) async {
    if (searchTerm.isEmpty) {
      await loadValidationRules();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _validationRules = await _validationRuleService.searchRules(searchTerm);
      _emitState();
    } catch (e) {
      _setError('Failed to search validation rules: $e');
      if (kDebugMode) {
        print('Error searching validation rules: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetToDefaults() async {
    _setLoading(true);
    _setError(null);

    try {
      await _validationRuleService.resetToDefaults();
      await loadValidationRules();
    } catch (e) {
      _setError('Failed to reset validation rules: $e');
      if (kDebugMode) {
        print('Error resetting validation rules: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> initializePredefinedRules() async {
    _setLoading(true);
    _setError(null);

    try {
      await _validationRuleService.initializePredefinedRules();
      await loadValidationRules();
    } catch (e) {
      _setError('Failed to initialize predefined rules: $e');
      if (kDebugMode) {
        print('Error initializing predefined rules: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_error != null) {
      _setError(null);
    }
  }

  Future<void> refresh() async {
    await loadValidationRules();
  }

  Future<void> reloadRules() => loadValidationRules();

  Future<ValidationRule?> addRule(ValidationRule rule) =>
      createValidationRule(rule);

  Future<ValidationRule?> updateRule(ValidationRule rule) {
    if (rule.id == null) {
      throw ArgumentError('Rule ID is required for updates');
    }
    return updateValidationRule(rule.id!, rule);
  }

  Future<bool> deleteRule(ValidationRule rule) {
    if (rule.id == null) {
      throw ArgumentError('Rule ID is required for deletion');
    }
    return deleteValidationRule(rule.id!);
  }

  List<ValidationRule> getPredefinedRules() {
    return _validationRules.where((rule) => !rule.isCustom).toList();
  }

  List<ValidationRule> getSampleAdvancedRules() {
    return [
      ValidationRule(
        ruleId: 'REQ_001',
        name: 'Event Time Required',
        description: 'All EPCIS events must have a valid event time',
        eventType: null,
        severity: RuleSeverity.ERROR,
        category: 'REQUIRED',
        tags: ['EPCIS', 'mandatory', 'time'],
        priority: 10,
        field: 'eventTime',
        ruleExpression: 'eventTime != null && eventTime <= now()',
        errorMessage: 'Event time is required and cannot be in the future',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'BIZ_001',
        name: 'Valid Business Step',
        description: 'Business step must be from the GS1 CBV vocabulary',
        eventType: EventType.ObjectEvent,
        severity: RuleSeverity.ERROR,
        category: 'BUSINESS',
        tags: ['GS1', 'CBV', 'business-step'],
        priority: 20,
        field: 'businessStep',
        ruleExpression:
            'businessStep != null && businessStep.startsWith("urn:epcglobal:cbv:bizstep:")',
        errorMessage: 'Business step must be a valid GS1 CBV URI',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'REF_001',
        name: 'Valid GLN References',
        description:
            'Read points and business locations must reference valid GLNs',
        eventType: null,
        severity: RuleSeverity.ERROR,
        category: 'REFERENTIAL',
        tags: ['GLN', 'location', 'reference'],
        priority: 30,
        field: 'readPoint.id',
        ruleExpression: 'readPoint != null ? isValidGLN(readPoint.id) : true',
        errorMessage: 'Read point must be a valid GLN reference',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'DQ_001',
        name: 'SGTIN Serial Number Format',
        description: 'Serial numbers in SGTINs must follow GS1 format',
        eventType: EventType.ObjectEvent,
        severity: RuleSeverity.WARNING,
        category: 'DATA_QUALITY',
        tags: ['SGTIN', 'serial-number', 'format'],
        priority: 50,
        field: 'epcList[*]',
        ruleExpression:
            'epcList.every(epc => isSgtin(epc) ? isValidSGTINSerial(epc) : true)',
        errorMessage: 'SGTIN serial numbers must follow GS1 format guidelines',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'PHARMA_001',
        name: 'Pharmaceutical Lot Tracking',
        description: 'Pharmaceutical products must have lot/batch information',
        eventType: EventType.ObjectEvent,
        severity: RuleSeverity.ERROR,
        category: 'COMPLIANCE',
        tags: ['pharmaceutical', 'lot', 'batch', 'FDA'],
        priority: 15,
        field: 'ilmd',
        ruleExpression:
            'isPharmaceuticalProduct(epcList) ? hasLotInformation(ilmd) : true',
        errorMessage:
            'Pharmaceutical products must include lot/batch information in ILMD',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'AGG_001',
        name: 'Parent-Child Aggregation',
        description:
            'Aggregation events must have valid parent-child relationships',
        eventType: EventType.AggregationEvent,
        severity: RuleSeverity.ERROR,
        category: 'BUSINESS',
        tags: ['aggregation', 'hierarchy', 'parent-child'],
        priority: 25,
        field: 'parentID',
        ruleExpression:
            'action == "ADD" ? (parentID != null && childEPCs.length > 0) : true',
        errorMessage:
            'ADD aggregation events must have a parent ID and child EPCs',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'TXN_001',
        name: 'Transaction Partner GLN',
        description: 'Transaction events must have valid trading partner GLNs',
        eventType: EventType.TransactionEvent,
        severity: RuleSeverity.ERROR,
        category: 'BUSINESS',
        tags: ['transaction', 'partner', 'GLN'],
        priority: 20,
        field: 'bizTransactionList[*].value',
        ruleExpression:
            'bizTransactionList.every(txn => txn.type == "po" ? isValidGLN(txn.value) : true)',
        errorMessage: 'Purchase order transactions must reference valid GLN',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'SEC_001',
        name: 'Secure Commissioning',
        description: 'Commissioning events must include security features',
        eventType: EventType.ObjectEvent,
        severity: RuleSeverity.WARNING,
        category: 'SECURITY',
        tags: ['commissioning', 'security', 'anti-counterfeiting'],
        priority: 40,
        field: 'action',
        ruleExpression:
            'action == "ADD" && businessStep.includes("commissioning") ? hasSecurityFeatures(ilmd) : true',
        errorMessage:
            'Commissioning events should include security features in ILMD',
        enabled: true,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'ENV_001',
        name: 'Temperature Monitoring',
        description: 'Cold chain products must have temperature data',
        eventType: null,
        severity: RuleSeverity.INFO,
        category: 'ENVIRONMENTAL',
        tags: ['temperature', 'cold-chain', 'monitoring'],
        priority: 60,
        field: 'sensorElementList[*]',
        ruleExpression:
            'isColdChainProduct(epcList) ? hasSensorData(sensorElementList, "temperature") : true',
        errorMessage:
            'Cold chain products should include temperature sensor data',
        enabled: false,
        isCustom: false,
      ),

      ValidationRule(
        ruleId: 'CUSTOM_001',
        name: 'Manufacturing Facility Check',
        description: 'Manufacturing events must occur at certified facilities',
        eventType: EventType.ObjectEvent,
        severity: RuleSeverity.ERROR,
        category: 'CUSTOM',
        tags: ['manufacturing', 'certification', 'facility'],
        priority: 35,
        field: 'readPoint.id',
        ruleExpression:
            'businessStep.includes("manufacturing") ? isCertifiedFacility(readPoint.id) : true',
        errorMessage: 'Manufacturing must occur at certified facilities only',
        enabled: true,
        isCustom: true,
      ),
    ];
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _emitState();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      _emitState();
    }
  }

  void _emitState() {
    emit(
      ValidationRuleState(
        validationRules: List.unmodifiable(_validationRules),
        isLoading: _isLoading,
        error: _error,
      ),
    );
  }
}
