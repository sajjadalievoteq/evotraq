import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_ai_table.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/mode_selector.dart';
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
    for (final match
        in RegExp(r'\((\d{2,4})\)([^(]*)').allMatches(elementString)) {
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

  Widget _buildParseFields(bool loading) {
    return TextField(
      controller: _parseController,
      decoration: const InputDecoration(
        labelText: 'GS1 element string',
        hintText: 'Paste barcode data or human-readable AIs',
      ),
      maxLines: 6,
      enabled: !loading,
    );
  }

  Widget _buildBuildFields(bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ValidatedTextFieldWrapper(
                controller: _aiController,
                fieldName: 'ai',
                decoration: const InputDecoration(labelText: 'AI'),
                keyboardType: TextInputType.number,
                readOnly: loading,
              ),
            ),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              flex: 5,
              child: ValidatedTextFieldWrapper(
                controller: _valueController,
                fieldName: 'ai_value',
                decoration: const InputDecoration(labelText: 'Value'),
                readOnly: loading,
              ),
            ),
            const SizedBox(width: TraqSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomOutlinedButtonWidget(
                title: 'Add',
                onTap: () {
                  if (!loading) _addPair();
                },
              ),
            ),
          ],
        ),
        if (_ais.isNotEmpty) ...[
          const SizedBox(height: TraqSpacing.md),
          Wrap(
            spacing: TraqSpacing.sm,
            runSpacing: TraqSpacing.sm,
            children: [
              for (final entry in _ais.entries)
                Chip(
                  label: Text('(${entry.key}) ${entry.value}'),
                  onDeleted: loading ? null : () => _removePair(entry.key),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTableFields() {
    final rows = Gs1AiTable.search(_searchController.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search AI code, title, or format',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: TraqIcon(AppAssets.iconSearch, size: 20),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TraqSpacing.md),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.lg),
            child: Text(
              'No matching Application Identifiers.',
              style: context.text.bodySm.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: rows.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.colors.border),
              itemBuilder: (context, index) {
                final row = rows[index];
                return ListTile(
                  dense: true,
                  title: Text('(${row.code}) ${row.title}'),
                  subtitle: Text(row.format),
                  trailing: row.fnc1
                      ? Tooltip(
                          message: 'Variable length (FNC1 separated)',
                          child: TraqIcon(AppAssets.iconArrowR, size: 16),
                        )
                      : null,
                );
              },
            ),
          ),
      ],
    );
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
                'build' => _buildBuildFields(loading),
                'table' => _buildTableFields(),
                _ => _buildParseFields(loading),
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
