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
    bool clearSelectedGLN = false,
    bool clearError = false,
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
      ];
}
