import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';

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
  final List<String> availableTransitions;

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
    this.availableTransitions = const [],
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
    List<String>? availableTransitions,
  }) {
    return SGTINState(
      status: status ?? this.status,
      sgtins: sgtins ?? this.sgtins,
      sgtin: sgtin ?? this.sgtin,
      error: error ?? this.error,
      isValidSGTIN: isValidSGTIN ?? this.isValidSGTIN,
      generatedSerialNumber:
          generatedSerialNumber ?? this.generatedSerialNumber,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      creationSuccessful: creationSuccessful ?? this.creationSuccessful,
      availableTransitions: availableTransitions ?? this.availableTransitions,
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
    availableTransitions,
  ];
}
