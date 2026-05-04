import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';

class GLNCubit extends Cubit<GLNState> {
  final GLNService _glnService;

  GLNCubit({required GLNService glnService})
      : _glnService = glnService,
        super(const GLNState());

  Future<void> fetchGLNs({int page = 0, int size = 20}) async {
    emit(state.copyWith(status: GLNStatus.loading, isFetchingMore: false));
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
    // Prevent overlapping "load more" requests (common source of scroll jank).
    if (page > 0 && state.isFetchingMore) {
      return;
    }

    if (page == 0) {
      emit(
        state.copyWith(
          isGlnListLoading: true,
          isFetchingMore: false,
          clearListFetchError: true,
        ),
      );
    } else {
      emit(state.copyWith(isFetchingMore: true));
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

      final bool detailLoading = state.status == GLNStatus.loading;
      final GLNStatus nextStatus =
          detailLoading ? GLNStatus.loading : GLNStatus.success;

      if (page == 0) {
        emit(state.copyWith(
          status: nextStatus,
          isGlnListLoading: false,
          glns: glns,
          totalItems: totalElements,
          currentPage: page,
          pageSize: size,
          hasMoreData: hasMore,
          isFetchingMore: false,
          clearListFetchError: true,
        ));
      } else {
        final List<GLN> updatedGlns = List.from(state.glns)..addAll(glns);
        emit(state.copyWith(
          status: nextStatus,
          isGlnListLoading: false,
          glns: updatedGlns,
          totalItems: totalElements,
          currentPage: page,
          pageSize: size,
          hasMoreData: hasMore,
          isFetchingMore: false,
          clearListFetchError: true,
        ));
      }
    } catch (e) {
      _handleListFetchError(e);
    }
  }

  void clearGlnListError() {
    if (state.listFetchError == null) return;
    emit(state.copyWith(clearListFetchError: true));
  }

  void _handleListFetchError(Object e) {
    String errorMessage = e.toString();
    if (e is ApiException) {
      errorMessage = e.getUserFriendlyMessage();
    }
    emit(state.copyWith(
      isGlnListLoading: false,
      isFetchingMore: false,
      listFetchError: errorMessage,
      listFetchErrorBody: e is ApiException ? e.responseBody : null,
      listFetchErrorStatusCode: e is ApiException ? e.statusCode : null,
    ));
  }

  Future<void> fetchGLNById(String id) async {
    emit(state.copyWith(
      status: GLNStatus.loading,
      isFetchingMore: false,
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
      isFetchingMore: false,
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
          error: GlnUiConstants.errorDeleteGlnFailed,
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
      isFetchingMore: false,
    ));
  }
}
