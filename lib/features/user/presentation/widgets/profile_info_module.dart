import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:traqtrace_app/core/widgets/profile_avatar.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_input_field.dart';
import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';

class ProfileInfoModule extends StatefulWidget {
  const ProfileInfoModule({super.key, required this.user});

  final dynamic user;

  @override
  State<ProfileInfoModule> createState() => _ProfileInfoModuleState();
}

class _ProfileInfoModuleState extends State<ProfileInfoModule> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);

    // Load avatar bytes (if any)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileCubit>().loadProfilePicture();
      }
    });
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
        _firstNameController.text = widget.user.firstName;
        _lastNameController.text = widget.user.lastName;
        _emailController.text = widget.user.email;
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
    }
  }

  Future<void> _pickAndUploadProfilePicture() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    final file = result?.files.single;
    if (file == null || file.bytes == null) return;

    final name = (file.name.isNotEmpty) ? file.name : 'profile_picture.png';
    final ext = (file.extension ?? '').toLowerCase();
    final contentType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => 'image/png',
    };

    await context.read<ProfileCubit>().uploadProfilePicture(
          bytes: file.bytes!,
          filename: name,
          contentType: contentType,
        );
  }

  Future<void> _removeProfilePicture() async {
    await context.read<ProfileCubit>().deleteProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          context.showError(state.error ?? UserStrings.genericError);
        } else if (state.status == ProfileStatus.success) {
          context.showSuccess(UserStrings.profileUpdatedSuccessfully);
          if (mounted) {
            setState(() => _isEditing = false);
          }
        } else if (state.status == ProfileStatus.profilePictureUpdated) {
          context.showSuccess(UserStrings.profilePictureUpdatedSuccessfully);
        } else if (state.status == ProfileStatus.profilePictureRemoved) {
          context.showSuccess(UserStrings.profilePictureRemovedSuccessfully);
        }
      },
      builder: (context, state) {
        final isSaving = state.isSavingProfile;
        final isUploadingPicture = state.isUploadingProfilePicture;
        final isRemovingPicture = state.isRemovingProfilePicture;
        final avatarBytes = state.profilePictureBytes;
        final hasPicture =
            avatarBytes != null || (state.user?.hasProfilePicture ?? false);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              ProfileAvatar(
                radius: 50,
                bytes: avatarBytes,
                firstName: widget.user.firstName,
                backgroundColor: context.colors.textSecondary,
                initialTextStyle: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
                overlay: !_isEditing
                    ? null
                    : SizedBox(
                        height: 30,
                        width: 30,
                        child: Material(
                          color: context.colors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: isUploadingPicture
                                ? null
                                : _pickAndUploadProfilePicture,
                            child: isUploadingPicture
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
              ),
              if (_isEditing && hasPicture) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: isRemovingPicture ? null : _removeProfilePicture,
                    icon: isRemovingPicture
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove picture'),
                  ),
                ),
              ],
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
              SizedBox(
                height: 50,
                child: _isEditing
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(

                                onPressed: isSaving ? null : _toggleEdit,
                                icon: const Icon(Icons.close_rounded,size: 16,),
                                label: const Text(UserStrings.cancel,style: TextStyle(
                                  fontSize: 16
                                ),),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomElevatedButton(
                              label: UserStrings.saveChanges,
                              onPressed: _saveProfile,
                              isLoading: isSaving,
                              isEnabled: !isSaving,
                            ),
                          ),
                        ],
                      )
                    : CustomElevatedButton(
                        label: UserStrings.editProfile,
                        onPressed: _toggleEdit,
                        isEnabled: true,
                      ),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                controller: _firstNameController,
                labelText: UserStrings.firstNameLabel,
                type: AuthInputFieldType.text,
                enabled: _isEditing && !isSaving,
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: _lastNameController,
                labelText: UserStrings.lastNameLabel,
                type: AuthInputFieldType.text,
                enabled: _isEditing && !isSaving,
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: _emailController,
                labelText: UserStrings.emailLabel,
                type: AuthInputFieldType.email,
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.username,
                decoration: const InputDecoration(
                  labelText: UserStrings.usernameLabel,
                  border: OutlineInputBorder(),
                  helperText: UserStrings.usernameHelper,
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.role,
                decoration: const InputDecoration(
                  labelText: UserStrings.roleLabel,
                  border: OutlineInputBorder(),
                  helperText: UserStrings.roleHelper,
                ),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

