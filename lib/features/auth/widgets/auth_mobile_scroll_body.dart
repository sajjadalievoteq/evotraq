import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';

class AuthMobileScrollBody extends StatelessWidget {
  const AuthMobileScrollBody({
    super.key,
    required this.layout,
    required this.child,
    this.maxWidth,
  });

  final AppLayoutData layout;
  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final contentMaxWidth = maxWidth ?? layout.maxContentWidth;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final minHeight = (layout.height - viewPadding.vertical).clamp(
      0.0,
      double.infinity,
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: layout.horizontalPadding,
            vertical: layout.verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
