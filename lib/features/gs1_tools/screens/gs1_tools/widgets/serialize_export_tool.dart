import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_epcis_actions.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class SerializeExportTool extends StatefulWidget {
  const SerializeExportTool({super.key});

  @override
  State<SerializeExportTool> createState() => _SerializeExportToolState();
}

class _SerializeExportToolState extends State<SerializeExportTool> {
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _epcs = TextEditingController();
  final _steps = TextEditingController();
  final _locations = TextEditingController();
  final _limit = TextEditingController();

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _epcs.dispose();
    _steps.dispose();
    _locations.dispose();
    _limit.dispose();
    super.dispose();
  }

  void _export(Gs1ToolsCubit cubit, String format) {
    cubit.exportEpcisEvents(
      format: format,
      startDate: _start.text,
      endDate: _end.text,
      epcs: _epcs.text,
      businessSteps: _steps.text,
      businessLocations: _locations.text,
      limit: _limit.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.serializeExport != c.serializeExport,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.serializeExport;
        return WorkbenchPanelShell(
          title: 'Export',
          slice: slice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Export EPCIS events matching your filters (CSV, HTML, PDF, Excel).',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: _start,
                fieldName: 'start_date',
                readOnly: slice.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Start date (optional)',
                  hintText: '2025-01-01T00:00:00Z',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: _end,
                fieldName: 'end_date',
                readOnly: slice.isLoading,
                decoration: const InputDecoration(
                  labelText: 'End date (optional)',
                  hintText: '2025-12-31T23:59:59Z',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: _epcs,
                fieldName: 'epcs',
                readOnly: slice.isLoading,
                decoration: const InputDecoration(
                  labelText: 'EPCs (optional, comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: _steps,
                fieldName: 'business_steps',
                readOnly: slice.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Business steps (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: _locations,
                fieldName: 'business_locations',
                readOnly: slice.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Business locations (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: _limit,
                fieldName: 'limit',
                readOnly: slice.isLoading,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max results (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TraqSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final format in const [
                    'CSV',
                    'HTML',
                    'PDF',
                    'EXCEL',
                  ]) ...[
                    CustomElevatedButton(
                      label: 'Export $format',
                      isLoading: slice.isLoading,
                      isEnabled: !slice.isLoading,
                      onPressed: () => _export(cubit, format),
                    ),
                    if (format != 'EXCEL')
                      const SizedBox(height: TraqSpacing.sm),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
