import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyState extends Equatable {
  const ProductHierarchyState({
    this.root,
    this.selectedEpc,
    this.selectedJourney,
    this.searchResults = const [],
    this.isSearching = false,
    this.isResolvingRoot = false,
    this.isLoadingDetails = false,
    this.hierarchyError,
    this.detailsError,
    this.treeVersion = 0,
  });

  final HierarchyTreeNodeState? root;
  final String? selectedEpc;
  final ProductJourney? selectedJourney;
  final List<ProductSearchResult> searchResults;
  final bool isSearching;
  final bool isResolvingRoot;
  final bool isLoadingDetails;
  final String? hierarchyError;
  final String? detailsError;

  
  final int treeVersion;

  bool get hasHierarchy => root != null;
  bool get hasDetails => selectedJourney != null;

  ProductHierarchyState copyWith({
    HierarchyTreeNodeState? root,
    String? selectedEpc,
    ProductJourney? selectedJourney,
    List<ProductSearchResult>? searchResults,
    bool? isSearching,
    bool? isResolvingRoot,
    bool? isLoadingDetails,
    String? hierarchyError,
    String? detailsError,
    int? treeVersion,
    bool clearHierarchyError = false,
    bool clearDetailsError = false,
    bool clearJourney = false,
  }) {
    return ProductHierarchyState(
      root: root ?? this.root,
      selectedEpc: selectedEpc ?? this.selectedEpc,
      selectedJourney: clearJourney
          ? null
          : (selectedJourney ?? this.selectedJourney),
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isResolvingRoot: isResolvingRoot ?? this.isResolvingRoot,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      hierarchyError: clearHierarchyError
          ? null
          : (hierarchyError ?? this.hierarchyError),
      detailsError: clearDetailsError
          ? null
          : (detailsError ?? this.detailsError),
      treeVersion: treeVersion ?? this.treeVersion,
    );
  }

  @override
  List<Object?> get props => [
    root,
    selectedEpc,
    selectedJourney,
    searchResults,
    isSearching,
    isResolvingRoot,
    isLoadingDetails,
    hierarchyError,
    detailsError,
    treeVersion,
  ];
}
