import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';

import '../../../../../../core/consts/app_consts.dart';
import 'user_management_constants.dart';

class UserManagementFilterSection extends StatelessWidget {
  const UserManagementFilterSection({
    super.key,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.totalItems,
    required this.showResultsCount,
    required this.onApplyFilters,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onRefresh,
    required this.onAddUser,
  });

  final TextEditingController searchController;
  final String selectedRole;
  final String selectedStatus;
  final int totalItems;
  final bool showResultsCount;
  final VoidCallback onApplyFilters;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onRefresh;
  final VoidCallback onAddUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.cardRadius),
      ),
      child: Padding(
        padding: Constants.sectionPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final widths = _FieldWidths.fromWidth(maxWidth);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserManagementConstants.usersTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: Constants.spacing),
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  children: [
                    SizedBox(
                      width: widths.searchWidth,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: UserManagementConstants.searchHint,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: SvgPicture.asset(
                              AppAssets.iconSearch,
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).iconTheme.color ??
                                    Theme.of(context).colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (_) => onApplyFilters(),
                      ),
                    ),
                    SizedBox(
                      width: widths.filterWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: UserManagementConstants.roleLabel,
                          border: OutlineInputBorder(),
                        ),
                        items: UserManagementConstants.filterRoles
                            .map(
                              (role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onRoleChanged(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: widths.filterWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: UserManagementConstants.statusLabel,
                          border: OutlineInputBorder(),
                        ),
                        items: UserManagementConstants.filterStatuses
                            .map(
                              (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onStatusChanged(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Constants.spacing),
                Wrap(
                  runSpacing: Constants.spacing,
                  spacing: Constants.spacing,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    if (showResultsCount)
                      Text(
                        '$totalItems users found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    Wrap(
                      spacing: Constants.spacing,
                      runSpacing: Constants.spacing,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onRefresh,
                          icon: SvgPicture.asset(
                            AppAssets.iconRefresh,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: const Text(UserManagementConstants.refreshLabel),
                        ),
                        ElevatedButton.icon(
                          onPressed: onAddUser,
                          icon: SvgPicture.asset(
                            AppAssets.iconPlus,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: const Text(UserManagementConstants.addUserLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FieldWidths {
  const _FieldWidths({
    required this.searchWidth,
    required this.filterWidth,
  });

  final double searchWidth;
  final double filterWidth;

  factory _FieldWidths.fromWidth(double maxWidth) {
    if (maxWidth < 700) {
      return _FieldWidths(
        searchWidth: maxWidth,
        filterWidth: maxWidth,
      );
    }

    if (maxWidth < 1080) {
      return _FieldWidths(
        searchWidth: maxWidth,
        filterWidth: (maxWidth - Constants.spacing) / 2,
      );
    }

    final filterWidth =
        ((maxWidth * 0.42) - Constants.spacing) / 2;

    return _FieldWidths(
      searchWidth: maxWidth * 0.58 - Constants.spacing,
      filterWidth: filterWidth,
    );
  }
}
