import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_state.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_filter_section.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_form_dialog.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_list_content.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_loading_view.dart';
import 'package:traqtrace_app/features/admin/user_management/utils/user_management_constants.dart';
import 'package:traqtrace_app/features/admin/user_management/utils/user_management_search_utils.dart';
import 'dart:async';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserManagementCubit>(),
      child: const _UserManagementView(),
    );
  }
}

class _UserManagementView extends StatefulWidget {
  const _UserManagementView();

  @override
  State<_UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<_UserManagementView> {
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
        setState(() {});
      }
      _searchDebounce = Timer(const Duration(milliseconds: 450), () {
        if (mounted) {
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
                  : state.users
                      .where((user) => userManagementMatchesSearch(user, query))
                      .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserManagementFilterSection(
                    searchController: _searchController,
                    selectedRole: _selectedRole,
                    selectedStatus: _selectedStatus,
                    totalItems: query.isEmpty
                        ? state.totalItems
                        : filteredUsers.length,
                    showResultsCount:
                        state.users.isNotEmpty || query.isNotEmpty,
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
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshUserList,
                      child: UserManagementListContent(
                        users: filteredUsers,
                        togglingUserId: state.togglingUserId,
                        onEditUser: _showEditUserDialog,
                        onToggleStatus: _toggleUserStatus,
                      ),
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
