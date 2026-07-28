import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum WorkbenchActionStatus { idle, loading, success, error }

class WorkbenchSlice extends Equatable {
  const WorkbenchSlice({
    this.status = WorkbenchActionStatus.idle,
    this.error,
    this.resultText,
    this.resultFields = const {},
    this.imageBytes,
    this.meta = const {},
  });

  final WorkbenchActionStatus status;
  final String? error;
  final String? resultText;
  final Map<String, String> resultFields;
  final Uint8List? imageBytes;
  final Map<String, Object?> meta;

  bool get isLoading => status == WorkbenchActionStatus.loading;
  bool get hasError => status == WorkbenchActionStatus.error;
  bool get hasResult =>
      status == WorkbenchActionStatus.success &&
      ((resultText != null && resultText!.trim().isNotEmpty) ||
          resultFields.isNotEmpty ||
          imageBytes != null);

  WorkbenchSlice copyWith({
    WorkbenchActionStatus? status,
    String? error,
    bool clearError = false,
    String? resultText,
    bool clearResultText = false,
    Map<String, String>? resultFields,
    Uint8List? imageBytes,
    bool clearImage = false,
    Map<String, Object?>? meta,
  }) {
    return WorkbenchSlice(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      resultText: clearResultText ? null : (resultText ?? this.resultText),
      resultFields: resultFields ?? this.resultFields,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props =>
      [status, error, resultText, resultFields, imageBytes, meta];
}
