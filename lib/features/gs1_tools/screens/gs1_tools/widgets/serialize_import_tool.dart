import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_template.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class SerializeImportTool extends StatefulWidget {
  const SerializeImportTool({super.key});

  @override
  State<SerializeImportTool> createState() => _SerializeImportToolState();
}

class _SerializeImportToolState extends State<SerializeImportTool> {
  final _input = TextEditingController();
  String? _templateText;
  String? _templateError;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    try {
      final text = await rootBundle.loadString(EpcisImportTemplate.assetPath);
      if (!mounted) return;
      setState(() {
        _templateText = const JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(text));
        _templateError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _templateError = 'Could not load import template: $e');
    }
  }

  Future<void> _downloadTemplate() async {
    final raw =
        _templateText ??
        await rootBundle.loadString(EpcisImportTemplate.assetPath);
    web_download.downloadBytes(
      bytes: utf8.encode(raw),
      filename: EpcisImportTemplate.downloadFilename,
      mimeType: EpcisImportTemplate.mimeType,
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.serializeImport != c.serializeImport,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.serializeImport;
        final validated = slice.meta['importValidated'] == true;
        return WorkbenchPanelShell(
          title: 'Import',
          slice: slice,
          instructions: const WorkbenchInstructions(
            summary:
                'Import EPCIS events — only files matching the provided template are accepted',
            useCase:
                'Use when you need to load a validated EPCIS 2.0 JSON-LD document into the database. Writes to the DB only after full conformance.',
            audience: 'Advanced / Integrator',
            steps: [
              'Download the template and replace every REPLACE_WITH_* placeholder with real values.',
              'Paste or upload the filled JSON-LD document.',
              'Validate (format → schema → content). Fix any reported paths.',
              'Import only when validation passes — the batch is all-or-nothing.',
            ],
            exampleNote:
                'Template shape is EPCIS 2.0 JSON-LD (ObjectEvent + AggregationEvent). Unknown fields are rejected.',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Primary format: EPCIS 2.0 JSON-LD. Non-template input is rejected; nothing is written until all gates pass.',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              CustomOutlinedButtonWidget(
                title: 'Download template',
                onTap: _downloadTemplate,
              ),
              const SizedBox(height: TraqSpacing.md),
              Text(
                'Template reference',
                style: context.text.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: TraqSpacing.xs),
              if (_templateError != null)
                Text(
                  _templateError!,
                  style: context.text.bodySm.copyWith(
                    color: context.colors.error,
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(TraqSpacing.sm),
                    child: SelectableText(
                      _templateText ?? 'Loading template…',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: TraqSpacing.lg),
              TextField(
                controller: _input,
                minLines: 10,
                maxLines: 16,
                enabled: !slice.isLoading,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'EPCIS 2.0 JSON-LD document',
                  alignLabelWithHint: true,
                  hintText: 'Paste a filled template document…',
                ),
                onChanged: (_) => cubit.clearImportValidation(),
              ),
              const SizedBox(height: TraqSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomOutlinedButtonWidget(
                    title: 'Validate',
                    onTap: () {
                      if (!slice.isLoading) {
                        cubit.validateEpcisImport(input: _input.text);
                      }
                    },
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  CustomElevatedButton(
                    label: 'Import',
                    isLoading: slice.isLoading,
                    isEnabled: !slice.isLoading && validated,
                    onPressed: () =>
                        cubit.importEpcisEvents(input: _input.text),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
