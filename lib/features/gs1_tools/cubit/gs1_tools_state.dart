import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

typedef Gs1ToolSlice = WorkbenchSlice;
typedef Gs1ToolActionStatus = WorkbenchActionStatus;

class Gs1ToolsState extends Equatable {
  const Gs1ToolsState({
    this.selectedTool = Gs1ToolKind.checkDigit,
    this.checkDigit = const WorkbenchSlice(),
    this.epc = const WorkbenchSlice(),
    this.digitalLink = const WorkbenchSlice(),
    this.aiParser = const WorkbenchSlice(),
    this.barcode = const WorkbenchSlice(),
    this.validator = const WorkbenchSlice(),
    this.identifier = const WorkbenchSlice(),
    this.batch = const WorkbenchSlice(),
    this.serializeConvert = const WorkbenchSlice(),
    this.serializeValidate = const WorkbenchSlice(),
    this.serializeExport = const WorkbenchSlice(),
    this.serializeImport = const WorkbenchSlice(),
  });

  final Gs1ToolKind selectedTool;
  final WorkbenchSlice checkDigit;
  final WorkbenchSlice epc;
  final WorkbenchSlice digitalLink;
  final WorkbenchSlice aiParser;
  final WorkbenchSlice barcode;
  final WorkbenchSlice validator;
  final WorkbenchSlice identifier;
  final WorkbenchSlice batch;
  final WorkbenchSlice serializeConvert;
  final WorkbenchSlice serializeValidate;
  final WorkbenchSlice serializeExport;
  final WorkbenchSlice serializeImport;

  WorkbenchSlice sliceFor(Gs1ToolKind kind) => switch (kind) {
        Gs1ToolKind.checkDigit => checkDigit,
        Gs1ToolKind.epcConversion => epc,
        Gs1ToolKind.digitalLink => digitalLink,
        Gs1ToolKind.aiParser => aiParser,
        Gs1ToolKind.barcode => barcode,
        Gs1ToolKind.validator => validator,
        Gs1ToolKind.identifier => identifier,
        Gs1ToolKind.batch => batch,
        Gs1ToolKind.serializeConvert => serializeConvert,
        Gs1ToolKind.serializeValidate => serializeValidate,
        Gs1ToolKind.serializeExport => serializeExport,
        Gs1ToolKind.serializeImport => serializeImport,
      };

  Gs1ToolsState copyWith({
    Gs1ToolKind? selectedTool,
    WorkbenchSlice? checkDigit,
    WorkbenchSlice? epc,
    WorkbenchSlice? digitalLink,
    WorkbenchSlice? aiParser,
    WorkbenchSlice? barcode,
    WorkbenchSlice? validator,
    WorkbenchSlice? identifier,
    WorkbenchSlice? batch,
    WorkbenchSlice? serializeConvert,
    WorkbenchSlice? serializeValidate,
    WorkbenchSlice? serializeExport,
    WorkbenchSlice? serializeImport,
  }) {
    return Gs1ToolsState(
      selectedTool: selectedTool ?? this.selectedTool,
      checkDigit: checkDigit ?? this.checkDigit,
      epc: epc ?? this.epc,
      digitalLink: digitalLink ?? this.digitalLink,
      aiParser: aiParser ?? this.aiParser,
      barcode: barcode ?? this.barcode,
      validator: validator ?? this.validator,
      identifier: identifier ?? this.identifier,
      batch: batch ?? this.batch,
      serializeConvert: serializeConvert ?? this.serializeConvert,
      serializeValidate: serializeValidate ?? this.serializeValidate,
      serializeExport: serializeExport ?? this.serializeExport,
      serializeImport: serializeImport ?? this.serializeImport,
    );
  }

  Gs1ToolsState withSlice(Gs1ToolKind kind, WorkbenchSlice slice) {
    return switch (kind) {
      Gs1ToolKind.checkDigit => copyWith(checkDigit: slice),
      Gs1ToolKind.epcConversion => copyWith(epc: slice),
      Gs1ToolKind.digitalLink => copyWith(digitalLink: slice),
      Gs1ToolKind.aiParser => copyWith(aiParser: slice),
      Gs1ToolKind.barcode => copyWith(barcode: slice),
      Gs1ToolKind.validator => copyWith(validator: slice),
      Gs1ToolKind.identifier => copyWith(identifier: slice),
      Gs1ToolKind.batch => copyWith(batch: slice),
      Gs1ToolKind.serializeConvert => copyWith(serializeConvert: slice),
      Gs1ToolKind.serializeValidate => copyWith(serializeValidate: slice),
      Gs1ToolKind.serializeExport => copyWith(serializeExport: slice),
      Gs1ToolKind.serializeImport => copyWith(serializeImport: slice),
    };
  }

  @override
  List<Object?> get props => [
        selectedTool,
        checkDigit,
        epc,
        digitalLink,
        aiParser,
        barcode,
        validator,
        identifier,
        batch,
        serializeConvert,
        serializeValidate,
        serializeExport,
        serializeImport,
      ];
}
