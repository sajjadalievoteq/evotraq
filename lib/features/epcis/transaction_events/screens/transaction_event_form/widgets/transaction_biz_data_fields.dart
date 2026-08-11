import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TransactionBizDataFields extends StatelessWidget {
  const TransactionBizDataFields({
    super.key,
    required this.controllers,
    required this.onRemove,
  });

  final List<MapEntry<TextEditingController, TextEditingController>>
  controllers;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        controllers.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers[index].key,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Key is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controllers[index].value,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Value is required';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const TraqIcon(AppAssets.iconTrash),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
