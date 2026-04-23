import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../users/widgets/user_management_constants.dart';

class UserApprovalsHeaderSection extends StatelessWidget {
  const UserApprovalsHeaderSection({
    super.key,
    required this.pendingCount,
    required this.searchController,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  final int pendingCount;
  final TextEditingController searchController;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UserManagementConstants.approvalsTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'You have $pendingCount pending user registrations that require your approval.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );

    final searchField = TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: UserManagementConstants.searchHint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        isDense: true,
      ),
    );

    final refreshButton = SizedBox(
      width: 50,
      height: 50,
      child: isRefreshing
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            )
          : CustomButtonWidget(
              onTap: onRefresh,
              icon: Icons.refresh,
              iconOnly: true,
              tooltip: UserManagementConstants.refreshLabel,
            ),
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.cardRadius),
      ),
      child: Padding(
        padding: Constants.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock,
            const SizedBox(height: Constants.spacing),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchField,
                      const SizedBox(height: Constants.spacing),
                      Align(
                        alignment: Alignment.centerRight,
                        child: refreshButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width:Constants.spacing),
                    refreshButton,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
