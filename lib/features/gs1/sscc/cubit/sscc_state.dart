import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

import 'sscc_status.dart';

class SSCCState extends Equatable {
  final SSCCStatus status;
  final List<SSCC> ssccs;
  final SSCC? selectedSSCC;
  final List<SSCC> childSsccs;
  final String? parentSsccCode;
  final int page;
  final int totalPages;
  final int totalElements;
  final String? error;
  final bool? isValid;
  final String? validatedCode;
  final String? generatedCode;
  final bool hasMoreData;
  final bool isListLoading;

  const SSCCState({
    this.status = SSCCStatus.initial,
    this.ssccs = const [],
    this.selectedSSCC,
    this.childSsccs = const [],
    this.parentSsccCode,
    this.page = 0,
    this.totalPages = 1,
    this.totalElements = 0,
    this.error,
    this.isValid,
    this.validatedCode,
    this.generatedCode,
    this.hasMoreData = false,
    this.isListLoading = false,
  });

  SSCCState copyWith({
    SSCCStatus? status,
    List<SSCC>? ssccs,
    SSCC? selectedSSCC,
    List<SSCC>? childSsccs,
    String? parentSsccCode,
    int? page,
    int? totalPages,
    int? totalElements,
    String? error,
    bool? isValid,
    String? validatedCode,
    String? generatedCode,
    bool? hasMoreData,
    bool? isListLoading,
    bool clearSelectedSSCC = false,
  }) {
    return SSCCState(
      status: status ?? this.status,
      ssccs: ssccs ?? this.ssccs,
      selectedSSCC:
          clearSelectedSSCC ? null : (selectedSSCC ?? this.selectedSSCC),
      childSsccs: childSsccs ?? this.childSsccs,
      parentSsccCode: parentSsccCode ?? this.parentSsccCode,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      error: error,
      isValid: isValid ?? this.isValid,
      validatedCode: validatedCode ?? this.validatedCode,
      generatedCode: generatedCode ?? this.generatedCode,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isListLoading: isListLoading ?? this.isListLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ssccs,
        selectedSSCC,
        childSsccs,
        parentSsccCode,
        page,
        totalPages,
        totalElements,
        error,
        isValid,
        validatedCode,
        generatedCode,
        hasMoreData,
        isListLoading,
      ];
}
