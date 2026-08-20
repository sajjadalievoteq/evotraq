import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_scaffold.dart';

class SgtinDetailScreenContent extends StatelessWidget {
  const SgtinDetailScreenContent({
    super.key,
    required this.embedded,
    required this.formBody,
    required this.appBarTitle,
    required this.isCreating,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onCloseEdit,
    required this.onSave,
  });

  final bool embedded;
  final Widget formBody;
  final String appBarTitle;
  final bool isCreating;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onCloseEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    if (embedded) return formBody;
    return SgtinDetailScaffold(
      appBarTitle: appBarTitle,
      showEditAction: !isCreating && !isEditing,
      showCloseEditAction: !isCreating && isEditing,
      onEdit: onEdit,
      onCloseEdit: onCloseEdit,
      body: formBody,
      showSaveFab: isEditing || isCreating,
      isSaving: isSaving,
      onSave: onSave,
    );
  }
}
