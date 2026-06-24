import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/login/screens/widgets/login_username_input_field.dart';

class LoginUsernameAutocompleteField extends StatelessWidget {
  const LoginUsernameAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.recentUsernames,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final List<String> recentUsernames;
  final VoidCallback onChanged;

  Iterable<String> _usernameSuggestions(String query) {
    if (recentUsernames.isEmpty) return const Iterable<String>.empty();

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return recentUsernames;

    return recentUsernames.where(
      (username) => username.toLowerCase().contains(normalizedQuery),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (option) => option,
      optionsBuilder: (value) => _usernameSuggestions(value.text),
      onSelected: (selection) {
        controller
          ..text = selection
          ..selection = TextSelection.collapsed(offset: selection.length);
        onChanged();
      },
      fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
        return LoginUsernameInputField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          isLoading: isLoading,
          onChanged: onChanged,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: c.border),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, minWidth: 280),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: c.border),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: TextStyle(color: c.textPrimary),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
