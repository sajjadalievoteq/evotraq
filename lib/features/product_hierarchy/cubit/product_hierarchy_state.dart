import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
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
    this.isClimbing = false,
    this.hierarchyError,
    this.detailsError,
    this.treeVersion = 0,
    this.focusEpc,
    this.searchedEpc,
    this.scrollToEpc,
    this.flashFocusEpc,
    this.parentHasParent = false,
    this.climbToast,
    this.recentParents = const [],
    this.recentParentsLoading = false,
  });

  final HierarchyTreeNodeState? root;
  final String? selectedEpc;
  final ProductJourney? selectedJourney;
  final List<ProductSearchResult> searchResults;
  final bool isSearching;
  final bool isResolvingRoot;
  final bool isLoadingDetails;
  final bool isClimbing;
  final String? hierarchyError;
  final String? detailsError;

  final int treeVersion;

  final String? focusEpc;

  final String? searchedEpc;

  final String? scrollToEpc;

  final String? flashFocusEpc;

  final bool parentHasParent;

  final String? climbToast;

  final List<PackingResponse> recentParents;
  final bool recentParentsLoading;

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
    bool? isClimbing,
    String? hierarchyError,
    String? detailsError,
    int? treeVersion,
    String? focusEpc,
    String? searchedEpc,
    String? scrollToEpc,
    String? flashFocusEpc,
    bool? parentHasParent,
    String? climbToast,
    List<PackingResponse>? recentParents,
    bool? recentParentsLoading,
    bool clearHierarchyError = false,
    bool clearDetailsError = false,
    bool clearJourney = false,
    bool clearFocusEpc = false,
    bool clearSearchedEpc = false,
    bool clearScrollToEpc = false,
    bool clearFlashFocusEpc = false,
    bool clearClimbToast = false,
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
      isClimbing: isClimbing ?? this.isClimbing,
      hierarchyError: clearHierarchyError
          ? null
          : (hierarchyError ?? this.hierarchyError),
      detailsError: clearDetailsError
          ? null
          : (detailsError ?? this.detailsError),
      treeVersion: treeVersion ?? this.treeVersion,
      focusEpc: clearFocusEpc ? null : (focusEpc ?? this.focusEpc),
      searchedEpc: clearSearchedEpc ? null : (searchedEpc ?? this.searchedEpc),
      scrollToEpc: clearScrollToEpc ? null : (scrollToEpc ?? this.scrollToEpc),
      flashFocusEpc: clearFlashFocusEpc
          ? null
          : (flashFocusEpc ?? this.flashFocusEpc),
      parentHasParent: parentHasParent ?? this.parentHasParent,
      climbToast: clearClimbToast ? null : (climbToast ?? this.climbToast),
      recentParents: recentParents ?? this.recentParents,
      recentParentsLoading: recentParentsLoading ?? this.recentParentsLoading,
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
    isClimbing,
    hierarchyError,
    detailsError,
    treeVersion,
    focusEpc,
    searchedEpc,
    scrollToEpc,
    flashFocusEpc,
    parentHasParent,
    climbToast,
    recentParents,
    recentParentsLoading,
  ];
}