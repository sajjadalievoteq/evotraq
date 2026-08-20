import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_ai_table.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_barcode_actions.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/ai_element_compose_fields.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/ai_element_parse_fields.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/ai_element_table_fields.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// Consolidated Application Identifier tool: parse an element string, build
/// one from AI/value pairs, or browse the bundled AI reference table.
class AiElementTool extends StatefulWidget {
  const AiElementTool({super.key});

  @override
  State<AiElementTool> createState() => _AiElementToolState();
}

class _AiElementToolState extends State<AiElementTool>
    with Gs1InitialModeMixin {
  static const _modes = [
    ('parse', 'Parse'),
    ('build', 'Build'),
    ('table', 'AI table'),
  ];

  static const _instructionsByMode = <String, WorkbenchInstructions>{
    'parse': WorkbenchInstructions(
      summary:
          'Decode a GS1 element string into each Application Identifier, its name, and its value.',
      useCase:
          'Use to troubleshoot a bad scan or to check how a supplier encoded a label.',
      audience: 'Advanced / Integrator',
      steps: [
        'Paste the element string — bracketed, FNC1-separated, or raw scanner output.',
        'Read each AI with its title and value; length and format problems are flagged.',
        'Copy the decoded values into whichever tool you need next.',
      ],
      exampleInput: '(01)10614141073464(17)250101(21)1234',
      exampleNote: '01=GTIN, 17=expiry 2025‑01‑01, 21=serial 1234',
    ),
    'build': WorkbenchInstructions(
      summary:
          'Assemble a GS1 element string from Application Identifier and value pairs.',
      useCase:
          'Use to hand-build a test payload for a barcode, or to check field lengths before printing a label.',
      audience: 'Advanced / Integrator',
      steps: [
        'Enter an AI (e.g. 01) with its value and press Add; repeat for every field.',
        'Remove a pair with the × on its chip.',
        'Build to get the element string, with separators after variable-length AIs.',
      ],
      exampleInput: '(01)10614141073464(21)1234',
      exampleNote: 'Loads GTIN + serial as AI pairs ready to build',
    ),
    'table': WorkbenchInstructions(
      summary: 'Browse the bundled GS1 Application Identifier reference table.',
      useCase:
          'Use to look up what an AI means and the format its value must follow.',
      audience: 'Everyday',
      steps: [
        'Search by AI code, title, or format — for example 17, expiry, or N6.',
        'The arrow marks variable-length AIs that need an FNC1 separator.',
        'This is a local reference; nothing is sent anywhere.',
      ],
      exampleInput: '17',
      exampleNote: 'AI 17 = expiration date, fixed 6 digits (YYMMDD)',
    ),
  };

  final _parseController = TextEditingController();
  final _aiController = TextEditingController();
  final _valueController = TextEditingController();
  final _searchController = TextEditingController();
  final Map<String, String> _ais = {};

  String _mode = 'parse';

  @override
  void initState() {
    super.initState();
    Gs1AiTable.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _parseController.dispose();
    _aiController.dispose();
    _valueController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addPair() {
    final ai = _aiController.text.trim();
    final value = _valueController.text.trim();
    if (ai.isEmpty || value.isEmpty) return;
    setState(() {
      _ais[ai] = value;
      _aiController.clear();
      _valueController.clear();
    });
  }

  void _removePair(String ai) {
    setState(() => _ais.remove(ai));
  }

  WorkbenchInstructions get _instructions =>
      _instructionsByMode[_mode] ?? _instructionsByMode['parse']!;

  void _loadExample(String example) {
    setState(() {
      switch (_mode) {
        case 'build':
          _ais
            ..clear()
            ..addAll(_pairsFrom(example));
        case 'table':
          _searchController.text = example;
        default:
          _parseController.text = example;
      }
    });
  }

  static Map<String, String> _pairsFrom(String elementString) {
    final pairs = <String, String>{};
    for (final match in RegExp(
      r'\((\d{2,4})\)([^(]*)',
    ).allMatches(elementString)) {
      pairs[match.group(1)!] = match.group(2)!.trim();
    }
    return pairs;
  }

  void _submit(Gs1ToolsCubit cubit) {
    switch (_mode) {
      case 'parse':
        if (_parseController.text.trim().isEmpty) return;
        cubit.aiTool(mode: 'parse', input: _parseController.text);
      case 'build':
        if (_ais.isEmpty) return;
        cubit.aiTool(mode: 'build', ais: Map<String, String>.from(_ais));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.aiElement != c.aiElement || p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const ['parse', 'build', 'table'],
          (m) => setState(() => _mode = m),
          clear: cubit.clearInitialMode,
        );
        final slice = state.aiElement;
        final loading = slice.isLoading;
        return WorkbenchPanelShell(
          title: 'Application Identifier Parser',
          slice: slice,
          instructions: _instructions,
          onLoadExample: _loadExample,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gs1ToolModeSelector(
                modes: _modes,
                value: _mode,
                enabled: !loading,
                onChanged: (v) => setState(() => _mode = v),
              ),
              const SizedBox(height: TraqSpacing.lg),
              switch (_mode) {
                'build' => AiElementComposeFields(
                  aiController: _aiController,
                  valueController: _valueController,
                  pairs: _ais,
                  loading: loading,
                  onAdd: _addPair,
                  onRemove: _removePair,
                ),
                'table' => AiElementTableFields(
                  searchController: _searchController,
                  onSearchChanged: (_) => setState(() {}),
                ),
                _ => AiElementParseFields(
                  controller: _parseController,
                  loading: loading,
                ),
              },
              if (_mode != 'table') ...[
                const SizedBox(height: TraqSpacing.lg),
                CustomElevatedButton(
                  label: _mode == 'parse' ? 'Parse' : 'Build',
                  isLoading: loading,
                  isEnabled: !loading,
                  onPressed: () => _submit(cubit),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
