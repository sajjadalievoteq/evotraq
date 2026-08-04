import 'package:flutter/foundation.dart';

class DataConsistencyPersistenceService {
  static final DataConsistencyPersistenceService _instance = 
      DataConsistencyPersistenceService._internal();
  
  factory DataConsistencyPersistenceService() => _instance;
  
  DataConsistencyPersistenceService._internal();
  
  List<dynamic> _integrityJobs = [];
  List<Map<String, dynamic>> _correctionWorkflows = [];
  
  List<dynamic> get integrityJobs => List.from(_integrityJobs);
  List<Map<String, dynamic>> get correctionWorkflows => List.from(_correctionWorkflows);
  
  List<Map<String, dynamic>> getCorrectionWorkflows() => List.from(_correctionWorkflows);
  
  void addIntegrityJob(Map<String, dynamic> job) {
    _integrityJobs.insert(0, job);
    _notifyListeners();
  }
  
  void updateIntegrityJob(String jobId, Map<String, dynamic> updatedJob) {
    final index = _integrityJobs.indexWhere((job) => job['job_id'] == jobId);
    if (index >= 0) {
      _integrityJobs[index] = updatedJob;
      _notifyListeners();
    }
  }
  
  void addCorrectionWorkflow(Map<String, dynamic> workflow) {
    final workflowId = workflow['workflow_id'];
    final existingIndex = _correctionWorkflows.indexWhere((w) => w['workflow_id'] == workflowId);
    
    if (existingIndex >= 0) {
      _correctionWorkflows[existingIndex] = workflow;
    } else {
      _correctionWorkflows.insert(0, workflow);
    }
    _notifyListeners();
  }
  
  void updateCorrectionWorkflow(String workflowId, Map<String, dynamic> updatedWorkflow) {
    final index = _correctionWorkflows.indexWhere((w) => w['workflow_id'] == workflowId);
    if (index >= 0) {
      _correctionWorkflows[index] = updatedWorkflow;
      _notifyListeners();
    }
  }
  
  void clearAll() {
    _integrityJobs.clear();
    _correctionWorkflows.clear();
    _notifyListeners();
  }
  
  void clearCorrectionWorkflows() {
    _correctionWorkflows.clear();
    _notifyListeners();
  }
  
  final List<VoidCallback> _listeners = [];
  
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
