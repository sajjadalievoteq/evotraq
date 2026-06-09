import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class Gs1MasterListBody extends StatelessWidget {
  const Gs1MasterListBody({
    super.key,
    required this.toolbar,
    required this.results,
  });

  final Widget toolbar;
  final Widget results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Constants.sectionMaxWidth,
            ),
            child: toolbar,
          ),
        ),
        SizedBox(height: Constants.spacing),
        Expanded(child: results),
      ],
    );
  }
}
