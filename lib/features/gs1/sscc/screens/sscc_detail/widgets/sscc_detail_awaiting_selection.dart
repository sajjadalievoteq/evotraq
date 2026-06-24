import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';

class SsccDetailAwaitingSelection extends StatelessWidget {
  const SsccDetailAwaitingSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        SsccUiConstants.detailAwaitSelection,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
