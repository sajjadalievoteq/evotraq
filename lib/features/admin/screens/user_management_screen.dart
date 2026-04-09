import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/admin/cubit/admin_cubit.dart';
import 'package:traqtrace_app/features/admin/cubit/admin_state.dart';
import 'package:traqtrace_app/features/admin/models/admin_models.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  
  final List<String> _roles = ['All', 'ADMIN', 'USER', 'VIEWER'];
  final List<String> _statuses = ['All', 'ACTIVE', 'INACTIVE', 'PENDING'];
  
  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    context.read<AdminCubit>().loadUsers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<AdminCubit>().loadUsers(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      role: _selectedRole != 'All' ? _selectedRole : null,
      status: _selectedStatus != 'All' ? _selectedStatus : null,
    );
  }

  void _refreshUserList() {
    context.read<AdminCubit>().loadUsers();
  }

  void _toggleUserStatus(UserResponse user) {
    context.read<AdminCubit>().changeUserStatus(
      user.id,
      !user.enabled,
    );
  }

  void _showEditUserDialog(BuildContext context, UserResponse user) {
    final _formKey = GlobalKey<FormState>();
    final _firstNameController = TextEditingController(text: user.firstName);
    final _lastNameController = TextEditingController(text: user.lastName);
    final _emailController = TextEditingController(text: user.email);
    final _passwordController = TextEditingController();
    String _selectedRole = user.role;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User: ${user.username}'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password (leave blank to keep unchanged)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: ['ADMIN', 'USER', 'VIEWER'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedRole = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Create update request
                  final UpdateUserRequest updateRequest = UpdateUserRequest(
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    email: _emailController.text,
                    password: _passwordController.text.isEmpty ? null : _passwordController.text,
                  );
                  
                  // Check if role changed
                  if (_selectedRole != user.role) {
                    context.read<AdminCubit>().changeUserRole(
                      user.id,
                      _selectedRole,
                    );
                  }
                  
                  // Dispatch update user method
                  context.read<AdminCubit>().updateUser(
                    user.id,
                    updateRequest,
                  );
                  
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User updated successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _usernameController = TextEditingController();
    final _firstNameController = TextEditingController();
    final _lastNameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    String _selectedRole = 'USER';
    bool _enabled = true;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      if (value.length < 4) {
                        return 'Username must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: ['ADMIN', 'USER', 'VIEWER'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedRole = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Account Active'),
                    value: _enabled,
                    onChanged: (value) {
                      _enabled = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Create user request
                  final CreateUserRequest createRequest = CreateUserRequest(
                    username: _usernameController.text,
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    role: _selectedRole,
                    enabled: _enabled,
                  );
                  
                  // Dispatch create user method
                  context.read<AdminCubit>().createUser(createRequest);
                  
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User created successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search and filter section
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search by name, email or username',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _applyFilters(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Role filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Status filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: _statuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.status == AdminStatus.success)
                          Text('${state.totalItems} users found', 
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _refreshUserList,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showAddUserDialog(context);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add User'),
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
                ),
              ),
              
              // Loading indicator
              if (state.status == AdminStatus.loading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                
              // User list
              if (state.status != AdminStatus.loading)
                Expanded(
                  child: state.users.isEmpty
                      ? const Center(
                          child: Text(
                            'No users found matching your criteria',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.accentColor,
                                  child: Text(
                                    user.firstName.isNotEmpty ? user.firstName[0] : 'U',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text('${user.firstName} ${user.lastName}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.email),
                                    Text('Username: ${user.username}', 
                                         style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(user.role),
                                          backgroundColor: user.role == 'ADMIN' 
                                              ? Colors.purple.withOpacity(0.2)
                                              : (user.role == 'VIEWER'
                                                  ? Colors.blue.withOpacity(0.2)
                                                  : Colors.green.withOpacity(0.2)),
                                          labelStyle: TextStyle(
                                            color: user.role == 'ADMIN'
                                                ? Colors.purple
                                                : (user.role == 'VIEWER'
                                                    ? Colors.blue
                                                    : Colors.green),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text(user.enabled ? 'ACTIVE' : 'INACTIVE'),
                                          backgroundColor: user.enabled
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                          labelStyle: TextStyle(
                                            color: user.enabled
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        if (user.approvalStatus == 'PENDING')
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Chip(
                                              label: const Text('PENDING'),
                                              backgroundColor: Colors.orange.withOpacity(0.2),
                                              labelStyle: const TextStyle(color: Colors.orange),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit User',
                                      onPressed: () {
                                        _showEditUserDialog(context, user);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        user.enabled ? Icons.lock : Icons.lock_open,
                                      ),
                                      tooltip: user.enabled ? 'Deactivate User' : 'Activate User',
                                      onPressed: () => _toggleUserStatus(user),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // TODO: Navigate to user details
                                },
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