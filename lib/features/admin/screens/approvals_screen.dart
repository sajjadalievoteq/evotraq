// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/admin/cubit/admin_cubit.dart';
import 'package:traqtrace_app/features/admin/cubit/admin_state.dart';
import 'package:traqtrace_app/features/admin/models/admin_models.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    // Load pending approvals when screen initializes
    context.read<AdminCubit>().loadApprovals();
  }

  void _refreshApprovalsList() {
    context.read<AdminCubit>().loadApprovals();
  }

  void _approveUser(UserResponse user) {
    context.read<AdminCubit>().approveUser(user.id);
  }

  void _showRejectDialog(BuildContext context, UserResponse user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Registration?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject ${user.firstName} ${user.lastName}\'s registration?'),
            const SizedBox(height: 16),
            const Text('This action will:'),
            const SizedBox(height: 8),
            const Text('• Mark the registration as rejected'),
            const Text('• Send a rejection notification email'),
            const Text('• Remove the user from the pending list'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminCubit>().rejectUser(user.id);
            },
            child: const Text('REJECT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state.status == AdminStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == AdminStatus.success) {
            // This can be used to show success messages after approving/rejecting
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Registration Approvals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have ${state.pendingApprovals.length} pending user registrations that require your approval.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _refreshApprovalsList,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Loading indicator
              if (state.status == AdminStatus.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              
              // Pending approvals list
              if (state.status != AdminStatus.loading)
                Expanded(
                  child: state.pendingApprovals.isEmpty
                      ? const Center(
                          child: Text(
                            'No pending approvals',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.pendingApprovals.length,
                          itemBuilder: (context, index) {
                            final user = state.pendingApprovals[index];
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppTheme.accentColor,
                                          child: Text(
                                            user.firstName.isNotEmpty ? user.firstName[0] : 'U',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${user.firstName} ${user.lastName}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Username: ${user.username}',
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Email: ${user.email}',
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Registered on: ${user.createdAt.split('T')[0]}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () => _showRejectDialog(context, user),
                                              icon: const Icon(Icons.cancel, color: Colors.red),
                                              label: const Text(
                                                'Reject',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Colors.red),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton.icon(
                                              onPressed: () => _approveUser(user),
                                              icon: const Icon(Icons.check_circle, color: Colors.white),
                                              label: const Text(
                                                'Approve',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}