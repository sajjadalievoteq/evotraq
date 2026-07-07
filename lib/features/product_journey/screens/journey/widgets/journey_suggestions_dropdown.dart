import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_step_style.dart';

class JourneySuggestionsDropdown extends StatelessWidget {
  const JourneySuggestionsDropdown({
    super.key,
    required this.results,
    required this.onTap,
  });

  final List<ProductSearchResult> results;
  final ValueChanged<ProductSearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            final color = JourneyStepStyle.typeColor(context, result.type);
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: Text(
                  result.type.isNotEmpty ? result.type[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(result.displayName),
              subtitle: Text(result.description ?? result.type),
              onTap: () => onTap(result),
            );
          },
        ),
      ),
    );
  }
}
