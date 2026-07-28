import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/identifier_validation_tool.dart';

/// Thin alias for the Tools → Validator rail item.
class ValidatorTool extends StatelessWidget {
  const ValidatorTool({super.key});

  @override
  Widget build(BuildContext context) {
    return const IdentifierValidationTool(target: Gs1ToolKind.validator);
  }
}
