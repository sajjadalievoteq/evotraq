import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/user_management/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user_management/cubit/profile_state.dart';

import 'package:traqtrace_app/core/consts/app_consts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go(Constants.homeRoute);
              },
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Security'),
                Tab(text: 'Preferences'),
              ],
            ),
          ),
          drawer: const AppDrawer(),
          body: TabBarView(
            controller: _tabController,
            children: [
              _ProfileInfoTab(user: user),
              _SecurityTab(),
              _PreferencesTab(),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileInfoTab extends StatefulWidget {
  final dynamic user;

  const _ProfileInfoTab({Key? key, required this.user}) : super(key: key);

  @override
  State<_ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<_ProfileInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values if cancelling edit
        _firstNameController.text = widget.user.firstName;
        _lastNameController.text = widget.user.lastName;
        _emailController.text = widget.user.email;
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == ProfileStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Profile picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    widget.user.firstName.isNotEmpty
                        ? widget.user.firstName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${widget.user.username}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 24),

                // Edit/Save button
                ElevatedButton.icon(
                  onPressed: state.status == ProfileStatus.loading
                      ? null
                      : _isEditing
                      ? _saveProfile
                      : _toggleEdit,
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  label: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
                ),

                const SizedBox(height: 24),

                // Form fields
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
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
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
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
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Username field (not editable)
                TextFormField(
                  initialValue: widget.user.username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    helperText: 'Username cannot be changed',
                  ),
                  enabled: false,
                ),

                const SizedBox(height: 16),

                // Role
                TextFormField(
                  initialValue: widget.user.role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    helperText: 'Assigned by administrator',
                  ),
                  enabled: false,
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  // Cancel button when in edit mode
                  OutlinedButton(
                    onPressed: _toggleEdit,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SecurityTab extends StatefulWidget {
  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      // Clear fields after submission
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == ProfileStatus.passwordChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your password must be at least 8 characters long and include a mix of letters, numbers, and symbols.',
                style: TextStyle(color: AppTheme.textSecondaryLight),
              ),

              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Current Password
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                      enabled: state.status != ProfileStatus.loading,
                    ),

                    const SizedBox(height: 16),

                    // New Password
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      enabled: state.status != ProfileStatus.loading,
                    ),

                    const SizedBox(height: 16),

                    // Confirm New Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      enabled: state.status != ProfileStatus.loading,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.status == ProfileStatus.loading
                            ? null
                            : _changePassword,
                        child: state.status == ProfileStatus.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Change Password'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Divider(),

              const SizedBox(height: 16),

              // Session Management
              const Text(
                'Sessions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Manage your active sessions across devices.',
                style: TextStyle(color: AppTheme.textSecondaryLight),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.computer, color: Colors.white),
                ),
                title: const Text('Current Session'),
                subtitle: const Text('This device • Active now'),
                trailing: TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                    context.go(Constants.loginRoute);
                  },
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreferencesTab extends StatefulWidget {
  @override
  State<_PreferencesTab> createState() => _PreferencesTabState();
}

class _PreferencesTabState extends State<_PreferencesTab> {
  bool _emailNotifications = true;
  bool _appNotifications = true;
  String _language = 'English';

  final List<String> _availableLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
  ];

  @override
  void initState() {
    super.initState();

    // Load values from the profile state
    final profileState = context.read<ProfileCubit>().state;
    _language = profileState.language;
  }

  void _saveNotificationPreferences() {
    context.read<ProfileCubit>().updateNotificationPreferences(
      emailNotifications: _emailNotifications,
      appNotifications: _appNotifications,
    );
  }

  void _saveAppPreferences() {
    // The dark mode is already managed by the ThemeProvider
    // So we only need to save the language preference
    final themeCubit = context.read<ThemeCubit>();

    context.read<ProfileCubit>().updateAppPreferences(
      darkMode: themeCubit.isDarkMode,
      language: _language,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.preferencesUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences updated successfully')),
          );

          // Refresh theme provider from profile state when preferences are updated
          context.read<ThemeCubit>().refreshFromProfile();
        } else if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive updates via email'),
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('App Notifications'),
                        subtitle: const Text('Receive in-app notifications'),
                        value: _appNotifications,
                        onChanged: (value) {
                          setState(() {
                            _appNotifications = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state.status == ProfileStatus.loading
                            ? null
                            : _saveNotificationPreferences,
                        child: state.status == ProfileStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Notification Preferences'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      BlocBuilder<ThemeCubit, ThemeState>(
                        buildWhen: (previous, current) =>
                            previous.isDarkMode != current.isDarkMode,
                        builder: (context, themeState) {
                          return SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text('Use dark theme for the app'),
                            secondary: Icon(
                              themeState.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: themeState.isDarkMode
                                  ? AppTheme.accentColorDark
                                  : AppTheme.primaryColor,
                            ),
                            value: themeState.isDarkMode,
                            activeColor: AppTheme.primaryColorDark,
                            onChanged: (value) async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? "Switching to dark theme..."
                                        : "Switching to light theme...",
                                  ),
                                  duration: const Duration(milliseconds: 800),
                                  backgroundColor: value
                                      ? AppTheme.backgroundColorDark
                                      : AppTheme.backgroundColor,
                                  action: SnackBarAction(
                                    label: 'OK',
                                    textColor: value
                                        ? AppTheme.accentColorDark
                                        : AppTheme.primaryColor,
                                    onPressed: () {},
                                  ),
                                ),
                              );

                              await context
                                  .read<ThemeCubit>()
                                  .setDarkMode(value);
                            },
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Language'),
                        subtitle: Text('Current: $_language'),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        value: _language,
                        items: _availableLanguages
                            .map(
                              (lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _language = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state.status == ProfileStatus.loading
                            ? null
                            : _saveAppPreferences,
                        child: state.status == ProfileStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save App Preferences'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
