import 'package:flutter/material.dart';

/// Standard scroll + [Form] column for GS1 master-data detail (e.g. GLN).
class Gs1MasterDataFormScroll extends StatelessWidget {
  const Gs1MasterDataFormScroll({
    super.key,
    required this.formKey,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
