import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';
import 'package:traqtrace_app/features/validation_workbench/cubit/validation_workbench_cubit.dart';
import 'package:traqtrace_app/features/validation_workbench/cubit/validation_workbench_state.dart';
import 'package:traqtrace_app/features/validation_workbench/models/validation_section.dart';
import 'package:traqtrace_app/features/validation_workbench/widgets/identifier_validation_section.dart';
import 'package:traqtrace_app/features/validation_workbench/widgets/validation_tests_section.dart';

/// Legacy Validation workbench — routes redirect to [Gs1ToolsScreen].
/// Kept for embedded/test use with grouped rail API.
class ValidationWorkbenchScreen extends StatelessWidget {
  const ValidationWorkbenchScreen({
    super.key,
    this.initialSection,
  });

  final ValidationSection? initialSection;

  static final _railGroups = [
    WorkbenchRailGroup(
      title: 'Validation',
      items: [
        WorkbenchRailItem(
          id: ValidationSection.identifier.id,
          iconAsset: NavIcons.gs1ValidationDemo,
          label: ValidationSection.identifier.label,
        ),
        WorkbenchRailItem(
          id: ValidationSection.batch.id,
          iconAsset: NavIcons.gs1ValidationTests,
          label: ValidationSection.batch.label,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final initial = initialSection ?? ValidationSection.identifier;

    return BlocProvider(
      create: (_) => ValidationWorkbenchCubit(initialSection: initial),
      child: const _ValidationWorkbenchView(),
    );
  }
}

class _ValidationWorkbenchView extends StatelessWidget {
  const _ValidationWorkbenchView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationWorkbenchCubit, ValidationWorkbenchState>(
      buildWhen: (p, c) => p.selected != c.selected,
      builder: (context, state) {
        return WorkbenchScaffold(
          title: 'Validation',
          groups: ValidationWorkbenchScreen._railGroups,
          selectedId: state.selected.id,
          onSelect: (id) {
            context
                .read<ValidationWorkbenchCubit>()
                .selectSection(ValidationSectionX.fromId(id));
          },
          panelBuilder: (_, id) =>
              _panelFor(ValidationSectionX.fromId(id)),
        );
      },
    );
  }

  Widget _panelFor(ValidationSection section) {
    return switch (section) {
      ValidationSection.identifier => const IdentifierValidationSection(),
      ValidationSection.batch => const ValidationTestsSection(),
    };
  }
}
