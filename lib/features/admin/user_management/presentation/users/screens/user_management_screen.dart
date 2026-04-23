import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_state.dart';
import 'dart:async';

import 'package:traqtrace_app/features/auth/presentation/widgets/background_container_widget.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

import '../widgets/user_management_constants.dart';
import '../widgets/user_management_filter_section.dart';
import '../widgets/user_management_form_dialog.dart';
import '../widgets/user_management_loading_view.dart';
import '../widgets/user_management_section_width.dart';
import '../widgets/user_management_user_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  String _selectedRole = UserManagementConstants.allFilter;
  String _selectedStatus = UserManagementConstants.allFilter;

  @override
  void initState() {
    super.initState();
    context.read<UserManagementCubit>().loadUsers();

    _searchController.addListener(() {
      _searchDebounce?.cancel();
      if (mounted) {
        // Local search first (filter current in-memory list).
        setState(() {});
      }
      _searchDebounce = Timer(const Duration(milliseconds: 450), () {
        if (mounted) {
          // Then refresh results from API.
          _applyFilters();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    await context.read<UserManagementCubit>().loadUsers(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          role: _selectedRole != UserManagementConstants.allFilter
              ? _selectedRole
              : null,
          status: _selectedStatus != UserManagementConstants.allFilter
              ? _selectedStatus
              : null,
        );
  }

  Future<void> _refreshUserList() async {
    _searchController.clear();
    setState(() {
      _selectedRole = UserManagementConstants.allFilter;
      _selectedStatus = UserManagementConstants.allFilter;
    });
    await context.read<UserManagementCubit>().loadUsers();
  }

  Future<void> _toggleUserStatus(UserResponse user) async {
    final cubit = context.read<UserManagementCubit>();
    await cubit.changeUserStatus(user.id, !user.enabled);
    if (!mounted || cubit.state.status == UserManagementStatus.error) {
      return;
    }

    context.showSuccess(
      user.enabled
          ? UserManagementConstants.deactivateUserSuccess
          : UserManagementConstants.activateUserSuccess,
    );
  }

  Future<void> _showAddUserDialog() async {
    final result = await showDialog<UserManagementFormResult>(
      context: context,
      builder: (context) => const UserManagementFormDialog(),
    );

    if (!mounted || result?.createRequest == null) {
      return;
    }

    final cubit = context.read<UserManagementCubit>();
    await cubit.createUser(result!.createRequest!);
    if (!mounted || cubit.state.status == UserManagementStatus.error) {
      return;
    }

    context.showSuccess(UserManagementConstants.createUserSuccess);
  }

  Future<void> _showEditUserDialog(UserResponse user) async {
    final result = await showDialog<UserManagementFormResult>(
      context: context,
      builder: (context) => UserManagementFormDialog(user: user),
    );

    if (!mounted || result?.updateRequest == null) {
      return;
    }

    final cubit = context.read<UserManagementCubit>();
    if (result!.selectedRole != user.role) {
      await cubit.changeUserRole(user.id, result.selectedRole);
      if (!mounted || cubit.state.status == UserManagementStatus.error) {
        return;
      }
    }

    await cubit.updateUser(user.id, result.updateRequest!);
    if (!mounted || cubit.state.status == UserManagementStatus.error) {
      return;
    }

    context.showSuccess(UserManagementConstants.updateUserSuccess);
  }

  bool _matchesSearch(UserResponse user, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return user.username.toLowerCase().contains(q) ||
        user.email.toLowerCase().contains(q) ||
        user.firstName.toLowerCase().contains(q) ||
        user.lastName.toLowerCase().contains(q) ||
        ('${user.firstName} ${user.lastName}').toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      showAppBar: true,
      appBarTitle: UserManagementConstants.pageTitle,
      showDrawer: true,
      child: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) {
          if (state.status == UserManagementStatus.error) {
            context.showError(
              state.error ?? UserManagementConstants.genericErrorMessage,
            );
          }
        },
        builder: (context, state) {
          return AppResponsiveBody.builder(
            safeArea: false,
            scrollable: false,
            builder: (context, layout) {
              if (state.status == UserManagementStatus.loading &&
                  state.users.isEmpty) {
                return const UserManagementLoadingView();
              }

              final query = _searchController.text.trim();
              final filteredUsers = query.isEmpty
                  ? state.users
                  : state.users.where((user) => _matchesSearch(user, query)).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserManagementSectionWidth(
                    child: UserManagementFilterSection(
                      searchController: _searchController,
                      selectedRole: _selectedRole,
                      selectedStatus: _selectedStatus,
                      totalItems:
                          query.isEmpty ? state.totalItems : filteredUsers.length,
                      showResultsCount: state.users.isNotEmpty || query.isNotEmpty,
                      onApplyFilters: _applyFilters,
                      onRoleChanged: (value) {
                        setState(() => _selectedRole = value);
                        _applyFilters();
                      },
                      onStatusChanged: (value) {
                        setState(() => _selectedStatus = value);
                        _applyFilters();
                      },
                      onRefresh: _refreshUserList,
                      onAddUser: _showAddUserDialog,
                    ),
                  ),

                  Expanded(
                    child: _UserManagementContent(
                      users: filteredUsers,
                      togglingUserId: state.togglingUserId,
                      onEditUser: _showEditUserDialog,
                      onToggleStatus: _toggleUserStatus,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _UserManagementContent extends StatelessWidget {
  const _UserManagementContent({
    required this.users,
    required this.togglingUserId,
    required this.onEditUser,
    required this.onToggleStatus,
  });

  final List<UserResponse> users;
  final int? togglingUserId;
  final ValueChanged<UserResponse> onEditUser;
  final ValueChanged<UserResponse> onToggleStatus;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          UserManagementConstants.noUsersFound,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.all(0),


      itemBuilder: (context, index) {
        final user = users[index];
        return UserManagementSectionWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
               if(index==0) SizedBox(height: UserManagementConstants.spacing,),
                UserManagementUserCard(
                  user: user,
                  isToggleLoading: togglingUserId == user.id,
                  onEdit: onEditUser,
                  onToggleStatus: onToggleStatus,
                ),
                SizedBox(height:index==users.length-1?0: UserManagementConstants.spacing),

              ],
            ),
          ),
        );
      },
    );
  }
}
