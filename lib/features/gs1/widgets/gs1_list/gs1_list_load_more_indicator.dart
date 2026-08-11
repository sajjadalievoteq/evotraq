import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class Gs1ListLoadMoreIndicator extends StatelessWidget {
  const Gs1ListLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: Constants.spacing),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
