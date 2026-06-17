import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';

enum AdminCbvVocabularyStatus { initial, loading, loaded, error }

class AdminCbvVocabularyState extends Equatable {
  const AdminCbvVocabularyState({
    this.status = AdminCbvVocabularyStatus.initial,
    this.bizSteps = const [],
    this.dispositions = const [],
    this.togglingCodes = const {},
    this.deletingCodes = const {},
    this.isCreating = false,
    this.error,
  });

  final AdminCbvVocabularyStatus status;
  final List<CbvVocabularyItem> bizSteps;
  final List<CbvVocabularyItem> dispositions;

  /// Codes currently being PATCH'd (toggle) — drives per-item spinner.
  final Set<String> togglingCodes;

  /// Codes currently being DELETE'd — drives per-item spinner.
  final Set<String> deletingCodes;

  /// True while a POST create call is in-flight.
  final bool isCreating;

  final String? error;

  bool get isInitial => status == AdminCbvVocabularyStatus.initial;
  bool get isLoading => status == AdminCbvVocabularyStatus.loading;
  bool get isLoaded => status == AdminCbvVocabularyStatus.loaded;
  bool get hasError => status == AdminCbvVocabularyStatus.error;

  int get totalBizSteps => bizSteps.length;
  int get enabledBizSteps => bizSteps.where((b) => b.enabled).length;
  int get disabledBizSteps => totalBizSteps - enabledBizSteps;

  int get totalDispositions => dispositions.length;
  int get enabledDispositions => dispositions.where((d) => d.enabled).length;
  int get disabledDispositions => totalDispositions - enabledDispositions;

  AdminCbvVocabularyState copyWith({
    AdminCbvVocabularyStatus? status,
    List<CbvVocabularyItem>? bizSteps,
    List<CbvVocabularyItem>? dispositions,
    Set<String>? togglingCodes,
    Set<String>? deletingCodes,
    bool? isCreating,
    String? error,
    bool clearError = false,
  }) {
    return AdminCbvVocabularyState(
      status: status ?? this.status,
      bizSteps: bizSteps ?? this.bizSteps,
      dispositions: dispositions ?? this.dispositions,
      togglingCodes: togglingCodes ?? this.togglingCodes,
      deletingCodes: deletingCodes ?? this.deletingCodes,
      isCreating: isCreating ?? this.isCreating,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bizSteps,
        dispositions,
        togglingCodes,
        deletingCodes,
        isCreating,
        error,
      ];
}
