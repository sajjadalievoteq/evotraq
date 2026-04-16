import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:universal_html/html.dart' as html;

import '../../../data/services/api_collection_service.dart';
import '../models/api_collection.dart';

import 'api_collection_state.dart';

class ApiCollectionCubit extends Cubit<ApiCollectionState> {
  final ApiCollectionService _service;

  ApiCollectionCubit({
    required DioService dioService,
    ApiCollectionService? service,
  })  : _service = service ??
            ApiCollectionService(
              dioService: dioService,
            ),
        super(const ApiCollectionState());

  // ==================== Collection Operations ====================

  Future<void> loadCollections({bool activeOnly = false}) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final collections = await _service.getCollections(activeOnly: activeOnly);
      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        collections: collections,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadCollectionWithApis(String collectionId) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final selectedCollection = await _service.getCollectionWithApis(collectionId);
      final apis = selectedCollection?.apiDefinitions ?? [];
      
      final updatedCollections = List<ApiCollection>.from(state.collections);
      if (selectedCollection != null) {
        final index = updatedCollections.indexWhere((c) => c.id == collectionId);
        if (index >= 0) {
          updatedCollections[index] = selectedCollection;
        }
      }

      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        selectedCollection: selectedCollection,
        apis: apis,
        collections: updatedCollections,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadApisInCollection(String collectionId) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final apis = await _service.getApisInCollection(collectionId);
      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        apis: apis,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
    }
  }

  void selectCollection(ApiCollection collection) {
    emit(state.copyWith(selectedCollection: collection));
    loadApisInCollection(collection.id);
  }

  void clearSelection() {
    emit(state.copyWith(
      selectedCollection: null,
      apis: [],
    ));
  }

  Future<ApiCollection?> createCollection({
    required String code,
    required String name,
    String? description,
    String version = '1.0',
    String? category,
    String? icon,
    bool isPublic = false,
    int? rateLimitPerMinute,
  }) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final collection = await _service.createCollection(
        code: code,
        name: name,
        description: description,
        version: version,
        category: category,
        icon: icon,
        isPublic: isPublic,
        rateLimitPerMinute: rateLimitPerMinute,
      );
      
      final updatedCollections = List<ApiCollection>.from(state.collections)..add(collection);
      
      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        collections: updatedCollections,
        error: null,
      ));
      return collection;
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
      return null;
    }
  }

  Future<bool> updateCollection(String id, {
    String? name,
    String? description,
    String? version,
    String? category,
    String? icon,
    bool? isPublic,
    int? rateLimitPerMinute,
  }) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final updated = await _service.updateCollection(
        id,
        name: name,
        description: description,
        version: version,
        category: category,
        icon: icon,
        isPublic: isPublic,
        rateLimitPerMinute: rateLimitPerMinute,
      );
      
      final updatedCollections = List<ApiCollection>.from(state.collections);
      final index = updatedCollections.indexWhere((c) => c.id == id);
      if (index >= 0) {
        updatedCollections[index] = updated;
      }
      
      ApiCollection? selected = state.selectedCollection;
      if (selected?.id == id) {
        selected = updated;
      }
      
      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        collections: updatedCollections,
        selectedCollection: selected,
        error: null,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> activateCollection(String id) async {
    try {
      await _service.activateCollection(id);
      await loadCollections();
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> deactivateCollection(String id) async {
    try {
      await _service.deactivateCollection(id);
      await loadCollections();
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteCollection(String id) async {
    try {
      await _service.deleteCollection(id);
      
      final updatedCollections = List<ApiCollection>.from(state.collections)..removeWhere((c) => c.id == id);
      
      ApiCollection? selected = state.selectedCollection;
      List<ApiDefinition> apis = state.apis;
      if (selected?.id == id) {
        selected = null;
        apis = [];
      }
      
      emit(state.copyWith(
        collections: updatedCollections,
        selectedCollection: selected,
        apis: apis,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ==================== API Operations ====================

  Future<ApiDefinition?> createApi(String collectionId, {
    required String code,
    required String name,
    String? description,
    required String httpMethod,
    required String pathPattern,
    String? requestContentType,
    String? responseContentType,
    int timeoutSeconds = 30,
    int? cacheTtlSeconds,
    int? rateLimitPerMinute,
    List<String>? tags,
  }) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final api = await _service.createApi(
        collectionId,
        code: code,
        name: name,
        description: description,
        httpMethod: httpMethod,
        pathPattern: pathPattern,
        requestContentType: requestContentType,
        responseContentType: responseContentType,
        timeoutSeconds: timeoutSeconds,
        cacheTtlSeconds: cacheTtlSeconds,
        rateLimitPerMinute: rateLimitPerMinute,
        tags: tags,
      );
      
      final updatedApis = List<ApiDefinition>.from(state.apis)..add(api);
      
      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        apis: updatedApis,
        error: null,
      ));
      return api;
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
      return null;
    }
  }

  Future<bool> updateApi(String collectionId, String apiId, {
    String? name,
    String? description,
    String? httpMethod,
    String? pathPattern,
    int? timeoutSeconds,
    int? cacheTtlSeconds,
    int? rateLimitPerMinute,
    List<String>? tags,
  }) async {
    emit(state.copyWith(status: ApiCollectionStatus.loading, error: null));

    try {
      final updated = await _service.updateApi(
        collectionId,
        apiId,
        name: name,
        description: description,
        httpMethod: httpMethod,
        pathPattern: pathPattern,
        timeoutSeconds: timeoutSeconds,
        cacheTtlSeconds: cacheTtlSeconds,
        rateLimitPerMinute: rateLimitPerMinute,
        tags: tags,
      );
      
      final updatedApis = List<ApiDefinition>.from(state.apis);
      final index = updatedApis.indexWhere((a) => a.id == apiId);
      if (index >= 0) {
        updatedApis[index] = updated;
      }
      
      emit(state.copyWith(
        status: ApiCollectionStatus.success,
        apis: updatedApis,
        error: null,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ApiCollectionStatus.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> activateApi(String collectionId, String apiId) async {
    try {
      await _service.activateApi(collectionId, apiId);
      await loadApisInCollection(collectionId);
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> deactivateApi(String collectionId, String apiId) async {
    try {
      await _service.deactivateApi(collectionId, apiId);
      await loadApisInCollection(collectionId);
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteApi(String collectionId, String apiId) async {
    try {
      await _service.deleteApi(collectionId, apiId);
      
      final updatedApis = List<ApiDefinition>.from(state.apis)..removeWhere((a) => a.id == apiId);
      
      emit(state.copyWith(apis: updatedApis));
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ==================== Utility ====================

  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Export a collection as a Postman collection and trigger file download
  Future<void> exportPostmanCollection(String collectionId) async {
    final jsonString = await _service.exportPostmanCollection(collectionId);
    
    // Parse to get collection name for filename
    final Map<String, dynamic> postmanData = json.decode(jsonString);
    final String collectionName = postmanData['info']?['name'] ?? 'collection';
    final String safeName = collectionName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final String filename = '${safeName}_postman_collection.json';
    
    // Trigger file download
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.AnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
