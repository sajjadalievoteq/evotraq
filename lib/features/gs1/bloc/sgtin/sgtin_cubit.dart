import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/gs1/services/sgtin_service.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';

enum SGTINStatus { initial, loading, success, error }

class SGTINState extends Equatable {
  final SGTINStatus status;
  final List<SGTIN>? sgtins;
  final SGTIN? sgtin;
  final String? error;
  final bool? isValidSGTIN;
  final String? generatedSerialNumber;
  final int currentPage;
  final int totalElements;
  final int totalPages;
  final bool hasMoreData;
  final bool creationSuccessful;

  const SGTINState({
    this.status = SGTINStatus.initial,
    this.sgtins,
    this.sgtin,
    this.error,
    this.isValidSGTIN,
    this.generatedSerialNumber,
    this.currentPage = 0,
    this.totalElements = 0,
    this.totalPages = 0,
    this.hasMoreData = false,
    this.creationSuccessful = false,
  });

  SGTINState copyWith({
    SGTINStatus? status,
    List<SGTIN>? sgtins,
    SGTIN? sgtin,
    String? error,
    bool? isValidSGTIN,
    String? generatedSerialNumber,
    int? currentPage,
    int? totalElements,
    int? totalPages,
    bool? hasMoreData,
    bool? creationSuccessful,
  }) {
    return SGTINState(
      status: status ?? this.status,
      sgtins: sgtins ?? this.sgtins,
      sgtin: sgtin ?? this.sgtin,
      error: error ?? this.error,
      isValidSGTIN: isValidSGTIN ?? this.isValidSGTIN,
      generatedSerialNumber: generatedSerialNumber ?? this.generatedSerialNumber,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      creationSuccessful: creationSuccessful ?? this.creationSuccessful,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sgtins,
        sgtin,
        error,
        isValidSGTIN,
        generatedSerialNumber,
        currentPage,
        totalElements,
        totalPages,
        hasMoreData,
        creationSuccessful,
      ];
}

class SGTINCubit extends Cubit<SGTINState> {
  final SGTINService _sgtinService;

  // Default size for pagination
  static const int _defaultPageSize = 20;

  SGTINCubit({required SGTINService sgtinService})
      : _sgtinService = sgtinService,
        super(const SGTINState());

  Future<void> fetchSGTINById(String id) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtin = await _sgtinService.getSGTINById(id);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: sgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchSGTINBySerialNumber(String serialNumber) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtin = await _sgtinService.getSGTINBySerialNumber(serialNumber);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: sgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchSGTINList({
    String? gtinCode,
    String? serialNumber,
    String? batchLotNumber,
    String? status,
    String? locationName,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
    bool isLoadMore = false,
  }) async {
    // For first page or initial load, show loading state. For pagination, maintain current data
    if (page == 0 || !isLoadMore) {
      emit(state.copyWith(status: SGTINStatus.loading));
    } else {
      emit(state.copyWith(status: SGTINStatus.loading, hasMoreData: true));
    }

    try {
      final result = await _sgtinService.searchSGTINsAdvanced(
        gtinCode: gtinCode,
        serialNumber: serialNumber,
        batchLotNumber: batchLotNumber,
        status: status != null ? _parseItemStatus(status) : null,
        locationName: locationName,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      final List<SGTIN> sgtins = List<SGTIN>.from(result['content'] ?? []);
      final int totalElements = result['totalElements'] ?? 0;
      final int totalPages = result['totalPages'] ?? 0;
      final bool isLast = result['last'] ?? true;

      // If this is first page or not loading more, replace data. Otherwise append.
      if (page == 0 || !isLoadMore) {
        emit(state.copyWith(
          status: SGTINStatus.success,
          sgtins: sgtins,
          currentPage: page,
          totalElements: totalElements,
          totalPages: totalPages,
          hasMoreData: !isLast,
          error: null,
        ));
      } else {
        // For pagination, append the new data
        final List<SGTIN> updatedSgtins = List.from(state.sgtins ?? [])..addAll(sgtins);
        emit(state.copyWith(
          status: SGTINStatus.success,
          sgtins: updatedSgtins,
          currentPage: page,
          totalElements: totalElements,
          totalPages: totalPages,
          hasMoreData: !isLast,
          error: null,
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> searchSGTINs({
    String? gtinId,
    String? batchLotNumber,
    String? status,
    String? locationId,
    int? page,
    int? size,
  }) async {
    final int actualPage = page ?? 0;
    final int actualSize = size ?? _defaultPageSize;

    if (actualPage == 0) {
      emit(state.copyWith(status: SGTINStatus.loading));
    } else {
      emit(state.copyWith(status: SGTINStatus.loading, hasMoreData: true));
    }

    try {
      final sgtins = await _sgtinService.searchSGTINs(
        gtinId: gtinId != null ? int.tryParse(gtinId) : null,
        batchLotNumber: batchLotNumber,
        status: status != null ? _parseItemStatus(status) : null,
        locationId: locationId != null ? int.tryParse(locationId) : null,
        page: actualPage,
        size: actualSize,
      );

      if (actualPage == 0 || state.sgtins == null) {
        emit(state.copyWith(
          status: SGTINStatus.success,
          sgtins: sgtins,
          currentPage: actualPage,
          hasMoreData: sgtins.length >= actualSize,
          error: null,
        ));
      } else {
        final List<SGTIN> updatedSgtins = List.from(state.sgtins!)..addAll(sgtins);
        emit(state.copyWith(
          status: SGTINStatus.success,
          sgtins: updatedSgtins,
          currentPage: actualPage,
          hasMoreData: sgtins.length >= actualSize,
          error: null,
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> createSGTIN(SGTIN sgtin) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtinToCreate = sgtin.copyWith(id: null);
      final createdSgtin = await _sgtinService.createSGTIN(sgtinToCreate);
      
      List<SGTIN>? updatedSgtins;
      if (state.sgtins != null) {
        updatedSgtins = List<SGTIN>.from(state.sgtins!);
        updatedSgtins.add(createdSgtin);
      }
      
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: createdSgtin,
        sgtins: updatedSgtins,
        error: null,
        creationSuccessful: true,
      ));
      
      // Reset the creation flag
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          emit(state.copyWith(creationSuccessful: false));
        }
      });
    } catch (e) {
      emit(state.copyWith(
        status: SGTINStatus.error,
        error: "Failed to create SGTIN: ${e.toString()}",
        creationSuccessful: false,
      ));
    }
  }

  Future<void> updateSGTIN(String id, SGTIN sgtin) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final updatedSgtin = await _sgtinService.updateSGTIN(id, sgtin);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: updatedSgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteSGTIN(String id) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      await _sgtinService.deleteSGTIN(id);
      
      if (state.sgtins != null) {
        final updatedSgtins = state.sgtins!
            .where((sgtin) => sgtin.id != id)
            .toList();
        
        emit(state.copyWith(
          status: SGTINStatus.success,
          sgtins: updatedSgtins,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          status: SGTINStatus.success,
          error: null,
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateSGTINStatus(String id, ItemStatus status, {String? reason}) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final currentSgtin = await _sgtinService.getSGTINById(id);
      
      final updatedSgtin = currentSgtin.copyWith(
        status: status,
        decommissionedReason: status == ItemStatus.DECOMMISSIONED ? reason : null,
        decommissionedDate: status == ItemStatus.DECOMMISSIONED ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      
      final result = await _sgtinService.updateSGTIN(id, updatedSgtin);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: result,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateSGTINStatusBySerial(String serialNumber, String newStatus) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final statusEnum = _parseItemStatus(newStatus) ?? ItemStatus.COMMISSIONED;
      final sgtin = await _sgtinService.updateSGTINStatus(serialNumber, statusEnum);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: sgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> assignLocation(String serialNumber, String glnCode) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtin = await _sgtinService.assignSGTINToLocation(serialNumber, glnCode);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: sgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> packIntoSSCC(String serialNumber, String ssccCode) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtin = await _sgtinService.packSGTINIntoSSCC(serialNumber, ssccCode);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: sgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> generateSerialNumber(String gtinCode, {bool randomized = true}) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final serialNumber = await _sgtinService.generateSerialNumber(gtinCode, randomized: randomized);
      emit(state.copyWith(
        status: SGTINStatus.success,
        generatedSerialNumber: serialNumber,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> validateSGTIN(String gtinCode, String serialNumber) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final isValid = await _sgtinService.validateSGTIN(gtinCode, serialNumber);
      emit(state.copyWith(
        status: SGTINStatus.success,
        isValidSGTIN: isValid,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> commissionMultiple({
    required String gtinCode,
    required int quantity,
    String? batchLotNumber,
    DateTime? expiryDate,
    String? currentLocation,
  }) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtins = await _sgtinService.commissionMultipleSGTINs(
        gtinCode: gtinCode,
        quantity: quantity,
        batchLotNumber: batchLotNumber ?? '',
        expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
        currentLocation: currentLocation,
      );
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtins: sgtins,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> decommission(String serialNumber, String reason) async {
    emit(state.copyWith(status: SGTINStatus.loading));
    try {
      final sgtin = await _sgtinService.decommissionSGTIN(serialNumber, reason);
      emit(state.copyWith(
        status: SGTINStatus.success,
        sgtin: sgtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  void reset() {
    emit(const SGTINState());
  }

  ItemStatus? _parseItemStatus(String? value) {
    if (value == null) return null;
    try {
      return ItemStatus.values.firstWhere(
        (status) => status.name.toUpperCase() == value.toUpperCase(),
        orElse: () => ItemStatus.COMMISSIONED,
      );
    } catch (_) {
      return ItemStatus.COMMISSIONED;
    }
  }

  void _handleError(Object e) {
    emit(state.copyWith(
      status: SGTINStatus.error,
      error: e.toString(),
    ));
  }
}
