import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/automation_center/inbound_catalog.dart';

enum InboundCatalogStatus { initial, loading, success, error }

class InboundCatalogState extends Equatable {
  const InboundCatalogState({
    this.status = InboundCatalogStatus.initial,
    this.catalog,
    this.selectedCategoryId,
    this.error,
  });

  final InboundCatalogStatus status;
  final InboundCatalog? catalog;
  final String? selectedCategoryId;
  final String? error;

  InboundCatalogCategory? get selectedCategory {
    final categories = catalog?.categories;
    if (categories == null || categories.isEmpty) return null;
    final selectedId = selectedCategoryId;
    if (selectedId == null) return null;
    for (final category in categories) {
      if (category.id == selectedId) return category;
    }
    return null;
  }

  InboundCatalogState copyWith({
    InboundCatalogStatus? status,
    InboundCatalog? catalog,
    String? selectedCategoryId,
    String? error,
    bool clearSelectedCategory = false,
  }) {
    return InboundCatalogState(
      status: status ?? this.status,
      catalog: catalog ?? this.catalog,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      // Matches NotificationState / JobQueueState: error is not carried forward.
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, catalog, selectedCategoryId, error];
}
