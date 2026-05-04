import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

enum GLNStatus { initial, loading, success, error }

class GLNState extends Equatable {
  final GLNStatus status;
  final List<GLN> glns;
  final List<GLN> childGLNs;
  final List<GLN> expiredLicenseGLNs;
  final GLN? selectedGLN;
  final String? error;
  final bool? isValidGLN;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool hasMoreData;
  final bool isFetchingMore;

  /// List reload (search, filters) without forcing [status] to loading (detail pane stays stable).
  final bool isGlnListLoading;

  /// Set when [searchGLNsAdvanced] fails; separate from [error] so detail errors are not overwritten.
  final String? listFetchError;

  /// Raw HTTP body for the last GLN list/search failure (debugging).
  final String? listFetchErrorBody;

  /// HTTP status code for the last GLN list/search failure (debugging).
  final int? listFetchErrorStatusCode;

  const GLNState({
    this.status = GLNStatus.initial,
    this.glns = const [],
    this.childGLNs = const [],
    this.expiredLicenseGLNs = const [],
    this.selectedGLN,
    this.error,
    this.isValidGLN,
    this.currentPage = 0,
    this.pageSize = 20,
    this.totalItems = 0,
    this.hasMoreData = false,
    this.isFetchingMore = false,
    this.isGlnListLoading = false,
    this.listFetchError,
    this.listFetchErrorBody,
    this.listFetchErrorStatusCode,
  });

  GLNState copyWith({
    GLNStatus? status,
    List<GLN>? glns,
    List<GLN>? childGLNs,
    List<GLN>? expiredLicenseGLNs,
    GLN? selectedGLN,
    String? error,
    bool? isValidGLN,
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? hasMoreData,
    bool? isFetchingMore,
    bool? isGlnListLoading,
    String? listFetchError,
    String? listFetchErrorBody,
    int? listFetchErrorStatusCode,
    bool clearSelectedGLN = false,
    bool clearError = false,
    bool clearListFetchError = false,
  }) {
    return GLNState(
      status: status ?? this.status,
      glns: glns ?? this.glns,
      childGLNs: childGLNs ?? this.childGLNs,
      expiredLicenseGLNs: expiredLicenseGLNs ?? this.expiredLicenseGLNs,
      selectedGLN: clearSelectedGLN ? null : (selectedGLN ?? this.selectedGLN),
      error: clearError ? null : (error ?? this.error),
      isValidGLN: isValidGLN ?? this.isValidGLN,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isGlnListLoading: isGlnListLoading ?? this.isGlnListLoading,
      listFetchError: clearListFetchError
          ? null
          : (listFetchError ?? this.listFetchError),
      listFetchErrorBody: clearListFetchError
          ? null
          : (listFetchErrorBody ?? this.listFetchErrorBody),
      listFetchErrorStatusCode: clearListFetchError
          ? null
          : (listFetchErrorStatusCode ?? this.listFetchErrorStatusCode),
    );
  }

  @override
  List<Object?> get props => [
        status,
        glns,
        childGLNs,
        expiredLicenseGLNs,
        selectedGLN,
        error,
        isValidGLN,
        currentPage,
        pageSize,
        totalItems,
        hasMoreData,
        isFetchingMore,
        isGlnListLoading,
        listFetchError,
        listFetchErrorBody,
        listFetchErrorStatusCode,
      ];
}
