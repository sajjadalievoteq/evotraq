import 'package:equatable/equatable.dart';
import '../models/api_collection.dart';

enum ApiCollectionStatus { initial, loading, success, error }

class ApiCollectionState extends Equatable {
  final ApiCollectionStatus status;
  final List<ApiCollection> collections;
  final ApiCollection? selectedCollection;
  final List<ApiDefinition> apis;
  final String? error;

  const ApiCollectionState({
    this.status = ApiCollectionStatus.initial,
    this.collections = const [],
    this.selectedCollection,
    this.apis = const [],
    this.error,
  });

  // Statistics getters (migrated from Provider)
  int get totalCollections => collections.length;
  int get activeCollections => collections.where((c) => c.isActive).length;
  int get publicCollections => collections.where((c) => c.isPublic).length;
  int get totalApis => collections.fold(0, (sum, c) => sum + c.apiCount);

  ApiCollectionState copyWith({
    ApiCollectionStatus? status,
    List<ApiCollection>? collections,
    ApiCollection? selectedCollection,
    List<ApiDefinition>? apis,
    String? error,
  }) {
    return ApiCollectionState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      selectedCollection: selectedCollection ?? this.selectedCollection,
      apis: apis ?? this.apis,
      error: error,
    );
  }

  // Helper methods for filtering (migrated from Provider)
  List<ApiCollection> filterByCategory(String category) {
    return collections.where((c) => c.category == category).toList();
  }

  List<ApiDefinition> filterApisByMethod(String method) {
    return apis.where((a) => a.httpMethod == method).toList();
  }

  List<String> get categories {
    return collections
        .map((c) => c.category)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  @override
  List<Object?> get props => [status, collections, selectedCollection, apis, error];
}
