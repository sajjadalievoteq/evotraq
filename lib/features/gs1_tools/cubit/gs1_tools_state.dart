import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

typedef Gs1ToolSlice = WorkbenchSlice;
typedef Gs1ToolActionStatus = WorkbenchActionStatus;

class Gs1ToolsState extends Equatable {
  const Gs1ToolsState({
    this.selectedTool = Gs1ToolKind.convert,
    this.initialMode,
    this.convert = const WorkbenchSlice(),
    this.validate = const WorkbenchSlice(),
    this.build = const WorkbenchSlice(),
    this.barcode = const WorkbenchSlice(),
    this.aiElement = const WorkbenchSlice(),
    this.ndc = const WorkbenchSlice(),
    this.lookup = const WorkbenchSlice(),
    this.serializeConvert = const WorkbenchSlice(),
    this.serializeExport = const WorkbenchSlice(),
    this.serializeImport = const WorkbenchSlice(),
  });

  final Gs1ToolKind selectedTool;

  /// Optional deep-link mode for the selected tool (consumed once by the panel).
  final String? initialMode;

  final WorkbenchSlice convert;
  final WorkbenchSlice validate;
  final WorkbenchSlice build;
  final WorkbenchSlice barcode;
  final WorkbenchSlice aiElement;
  final WorkbenchSlice ndc;
  final WorkbenchSlice lookup;
  final WorkbenchSlice serializeConvert;
  final WorkbenchSlice serializeExport;
  final WorkbenchSlice serializeImport;

  WorkbenchSlice sliceFor(Gs1ToolKind kind) => switch (kind) {
    Gs1ToolKind.convert => convert,
    Gs1ToolKind.validate => validate,
    Gs1ToolKind.build => build,
    Gs1ToolKind.barcode => barcode,
    Gs1ToolKind.aiElement => aiElement,
    Gs1ToolKind.ndc => ndc,
    Gs1ToolKind.lookup => lookup,
    Gs1ToolKind.serializeConvert => serializeConvert,
    Gs1ToolKind.serializeExport => serializeExport,
    Gs1ToolKind.serializeImport => serializeImport,
  };

  Gs1ToolsState copyWith({
    Gs1ToolKind? selectedTool,
    String? initialMode,
    bool clearInitialMode = false,
    WorkbenchSlice? convert,
    WorkbenchSlice? validate,
    WorkbenchSlice? build,
    WorkbenchSlice? barcode,
    WorkbenchSlice? aiElement,
    WorkbenchSlice? ndc,
    WorkbenchSlice? lookup,
    WorkbenchSlice? serializeConvert,
    WorkbenchSlice? serializeExport,
    WorkbenchSlice? serializeImport,
  }) {
    return Gs1ToolsState(
      selectedTool: selectedTool ?? this.selectedTool,
      initialMode: clearInitialMode ? null : (initialMode ?? this.initialMode),
      convert: convert ?? this.convert,
      validate: validate ?? this.validate,
      build: build ?? this.build,
      barcode: barcode ?? this.barcode,
      aiElement: aiElement ?? this.aiElement,
      ndc: ndc ?? this.ndc,
      lookup: lookup ?? this.lookup,
      serializeConvert: serializeConvert ?? this.serializeConvert,
      serializeExport: serializeExport ?? this.serializeExport,
      serializeImport: serializeImport ?? this.serializeImport,
    );
  }

  Gs1ToolsState withSlice(Gs1ToolKind kind, WorkbenchSlice slice) {
    return switch (kind) {
      Gs1ToolKind.convert => copyWith(convert: slice),
      Gs1ToolKind.validate => copyWith(validate: slice),
      Gs1ToolKind.build => copyWith(build: slice),
      Gs1ToolKind.barcode => copyWith(barcode: slice),
      Gs1ToolKind.aiElement => copyWith(aiElement: slice),
      Gs1ToolKind.ndc => copyWith(ndc: slice),
      Gs1ToolKind.lookup => copyWith(lookup: slice),
      Gs1ToolKind.serializeConvert => copyWith(serializeConvert: slice),
      Gs1ToolKind.serializeExport => copyWith(serializeExport: slice),
      Gs1ToolKind.serializeImport => copyWith(serializeImport: slice),
    };
  }

  @override
  List<Object?> get props => [
    selectedTool,
    initialMode,
    convert,
    validate,
    build,
    barcode,
    aiElement,
    ndc,
    lookup,
    serializeConvert,
    serializeExport,
    serializeImport,
  ];
}
