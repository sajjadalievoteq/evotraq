import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/features/gs1/services/gln_service.dart';

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
      ];
}

class GLNCubit extends Cubit<GLNState> {
  final GLNService _glnService;

  GLNCubit({required GLNService glnService})
      : _glnService = glnService,
        super(const GLNState());

  Future<void> fetchGLNs({int page = 0, int size = 20}) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final glns = await _glnService.getAllGLNs(page: page, size: size);
      emit(state.copyWith(
        status: GLNStatus.success,
        glns: glns,
        currentPage: page,
        pageSize: size,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> searchGLNsAdvanced({
    String? search,
    String? glnCode,
    String? locationName,
    String? address,
    String? licenseNumber,
    bool? active,
    String? contactEmail,
    String? contactName,
    String? locationType,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String direction = 'DESC',
  }) async {
    if (page == 0) {
      emit(state.copyWith(status: GLNStatus.loading));
    }

    try {
      final result = await _glnService.searchGLNsAdvanced(
        search: search,
        glnCode: glnCode,
        name: locationName,
        address: address,
        licenseNo: licenseNumber,
        active: active,
        contactEmail: contactEmail,
        contactName: contactName,
        locationType: locationType,
        page: page,
        size: size,
        sortBy: sortBy,
        direction: direction,
      );

      final List<dynamic> contentList = result['content'] ?? [];
      final List<GLN> glns = contentList.map((item) => GLN.fromJson(item)).toList();
      final int totalElements = result['totalElements'] ?? 0;
      final bool hasMore = (page + 1) * size < totalElements;

      if (page == 0) {
        emit(state.copyWith(
          status: GLNStatus.success,
          glns: glns,
          totalItems: totalElements,
          currentPage: page,
          pageSize: size,
          hasMoreData: hasMore,
        ));
      } else {
        final List<GLN> updatedGlns = List.from(state.glns)..addAll(glns);
        emit(state.copyWith(
          status: GLNStatus.success,
          glns: updatedGlns,
          totalItems: totalElements,
          currentPage: page,
          pageSize: size,
          hasMoreData: hasMore,
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchGLNById(String id) async {
    emit(state.copyWith(
      status: GLNStatus.loading,
      clearSelectedGLN: true,
      clearError: true,
    ));
    try {
      final gln = await _glnService.getGLNById(id);
      emit(state.copyWith(
        status: GLNStatus.success,
        selectedGLN: gln,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchGLNByCode(String glnCode) async {
    emit(state.copyWith(
      status: GLNStatus.loading,
      clearSelectedGLN: true,
      clearError: true,
    ));
    try {
      final gln = await _glnService.getGLNByCode(glnCode);
      emit(state.copyWith(
        status: GLNStatus.success,
        selectedGLN: gln,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> createGLN(GLN gln) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final createdGLN = await _glnService.createGLN(gln);
      final updatedGLNs = List<GLN>.from(state.glns)..add(createdGLN);
      emit(state.copyWith(
        status: GLNStatus.success,
        glns: updatedGLNs,
        selectedGLN: createdGLN,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateGLN(String id, GLN gln) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final updatedGLN = await _glnService.updateGLN(id, gln);
      final updatedGLNs = state.glns.map((item) {
        return item.glnCode == updatedGLN.glnCode ? updatedGLN : item;
      }).toList();
      emit(state.copyWith(
        status: GLNStatus.success,
        glns: updatedGLNs,
        selectedGLN: updatedGLN,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteGLN(String id) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final success = await _glnService.deleteGLN(id);
      if (success) {
        final updatedGLNs = state.glns.where((gln) => gln.glnCode != id).toList();
        emit(state.copyWith(
          status: GLNStatus.success,
          glns: updatedGLNs,
          clearSelectedGLN: state.selectedGLN?.glnCode == id,
        ));
      } else {
        emit(state.copyWith(
          status: GLNStatus.error,
          error: 'Failed to delete GLN',
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void clearSelection() {
    emit(state.copyWith(
      clearSelectedGLN: true,
      clearError: true,
    ));
  }

  Future<void> searchGLNs({
    String? searchTerm,
    String? locationType,
    bool? active,
    int page = 0,
    int size = 20,
  }) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final glns = await _glnService.searchGLNs(
        searchTerm: searchTerm,
        locationType: locationType,
        active: active,
        page: page,
        size: size,
      );
      emit(state.copyWith(
        status: GLNStatus.success,
        glns: glns,
        currentPage: page,
        pageSize: size,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchExpiredLicenseGLNs() async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final expiredGLNs = await _glnService.getExpiredLicenseGLNs();
      emit(state.copyWith(
        status: GLNStatus.success,
        expiredLicenseGLNs: expiredGLNs,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchChildGLNs(String parentGlnCode) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final childGLNs = await _glnService.getChildGLNs(parentGlnCode);
      emit(state.copyWith(
        status: GLNStatus.success,
        childGLNs: childGLNs,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> validateGLNCode(String glnCode) async {
    emit(state.copyWith(status: GLNStatus.loading));
    try {
      final isValid = await _glnService.validateGLNCode(glnCode);
      emit(state.copyWith(
        status: GLNStatus.success,
        isValidGLN: isValid,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    emit(state.copyWith(
      status: GLNStatus.error,
      error: e.toString(),
    ));
  }
}
