import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';

typedef TatmeenCredentialsSaveCallback =
    Future<bool> Function(UpdateTatmeenIntegrationSettingsRequest request);

class TatmeenCredentialsForm extends StatefulWidget {
  const TatmeenCredentialsForm({
    super.key,
    required this.settings,
    required this.canUpdate,
    required this.busy,
    required this.onSave,
    required this.onRemovePassword,
    required this.onRemoveApiKey,
    this.isLoading = false,
  });

  final TatmeenIntegrationSettings? settings;
  final bool canUpdate;
  final bool busy;
  final bool isLoading;
  final TatmeenCredentialsSaveCallback onSave;
  final Future<void> Function() onRemovePassword;
  final Future<void> Function() onRemoveApiKey;

  @override
  State<TatmeenCredentialsForm> createState() => _TatmeenCredentialsFormState();
}

class _TatmeenCredentialsFormState extends State<TatmeenCredentialsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _apiKeyController;

  bool _obscurePassword = true;
  bool _obscureApiKey = true;
  bool _editingPassword = false;
  bool _editingApiKey = false;
  String? _initialUsername;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.settings?.username,
    );
    _passwordController = TextEditingController();
    _apiKeyController = TextEditingController();
    _initialUsername = widget.settings?.username;
    _syncSecretEditingFlags();
  }

  @override
  void didUpdateWidget(covariant TatmeenCredentialsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextUsername = widget.settings?.username;
    if (nextUsername != _initialUsername && !_usernameDirty) {
      _usernameController.text = nextUsername ?? '';
      _initialUsername = nextUsername;
    }
    if (oldWidget.settings?.passwordConfigured !=
            widget.settings?.passwordConfigured ||
        oldWidget.settings?.apiKeyConfigured !=
            widget.settings?.apiKeyConfigured) {
      _passwordController.clear();
      _apiKeyController.clear();
      _syncSecretEditingFlags();
    }
  }

  bool get _usernameDirty =>
      _usernameController.text.trim() != (_initialUsername ?? '').trim();

  bool get _passwordConfigured => widget.settings?.passwordConfigured ?? false;

  bool get _apiKeyConfigured => widget.settings?.apiKeyConfigured ?? false;

  void _syncSecretEditingFlags() {
    _editingPassword = !_passwordConfigured;
    _editingApiKey = !_apiKeyConfigured;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return const _CredentialsSkeleton();
    if (!widget.canUpdate) {
      return _readOnlySummary(context);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Credentials', style: context.text.h3.copyWith(fontSize: 16)),
          const SizedBox(height: TraqSpacing.sm),
          Text(
            'Username, password, and API key are required before Tatmeen can be enabled.',
            style: context.text.bodySm.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: TraqSpacing.md),
          TextFormField(
            controller: _usernameController,
            enabled: !widget.busy,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Username is required';
              }
              return null;
            },
          ),
          const SizedBox(height: TraqSpacing.md),
          _buildSecretField(
            label: 'Password',
            configured: _passwordConfigured,
            configuredLabel: 'Password configured',
            editing: _editingPassword,
            controller: _passwordController,
            obscure: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onChange: () => setState(() => _editingPassword = true),
            onCancelChange: () {
              _passwordController.clear();
              setState(() => _editingPassword = false);
            },
            onRemove: widget.onRemovePassword,
            validator: (value) {
              if (!_passwordConfigured && (value ?? '').isEmpty) {
                return 'Password is required';
              }
              if (_editingPassword &&
                  _passwordConfigured &&
                  (value ?? '').isEmpty) {
                return 'Enter a replacement password or cancel change';
              }
              return null;
            },
          ),
          const SizedBox(height: TraqSpacing.md),
          _buildSecretField(
            label: 'API key',
            configured: _apiKeyConfigured,
            configuredLabel:
                widget.settings?.apiKeyHint ?? 'API key configured',
            editing: _editingApiKey,
            controller: _apiKeyController,
            obscure: _obscureApiKey,
            onToggleObscure: () =>
                setState(() => _obscureApiKey = !_obscureApiKey),
            onChange: () => setState(() => _editingApiKey = true),
            onCancelChange: () {
              _apiKeyController.clear();
              setState(() => _editingApiKey = false);
            },
            onRemove: widget.onRemoveApiKey,
            validator: (value) {
              if (!_apiKeyConfigured && (value ?? '').isEmpty) {
                return 'API key is required';
              }
              if (_editingApiKey &&
                  _apiKeyConfigured &&
                  (value ?? '').isEmpty) {
                return 'Enter a replacement API key or cancel change';
              }
              return null;
            },
          ),
          const SizedBox(height: TraqSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: widget.busy ? null : _submit,
              child: widget.busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save credentials'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlySummary(BuildContext context) {
    final settings = widget.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Credentials', style: context.text.h3),
        const SizedBox(height: TraqSpacing.sm),
        Text(
          'Credential configuration is restricted to administrators.',
          style: context.text.bodySm.copyWith(color: context.colors.textMuted),
        ),
        if (settings != null) ...[
          const SizedBox(height: TraqSpacing.md),
          if (settings.username != null && settings.username!.isNotEmpty)
            Text('Username: ${settings.username}'),
          if (settings.passwordConfigured) const Text('Password configured'),
          if (settings.apiKeyConfigured)
            Text(settings.apiKeyHint ?? 'API key configured'),
        ],
      ],
    );
  }

  Widget _buildSecretField({
    required String label,
    required bool configured,
    required String configuredLabel,
    required bool editing,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required VoidCallback onChange,
    required VoidCallback onCancelChange,
    required Future<void> Function() onRemove,
    required String? Function(String?) validator,
  }) {
    if (configured && !editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            child: Text(configuredLabel),
          ),
          const SizedBox(height: TraqSpacing.xs),
          Wrap(
            spacing: TraqSpacing.sm,
            children: [
              TextButton(
                onPressed: widget.busy ? null : onChange,
                child: const Text('Change'),
              ),
              TextButton(
                onPressed: widget.busy ? null : () async => onRemove(),
                child: Text('Remove $label'),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          enabled: !widget.busy,
          obscureText: obscure,
          enableSuggestions: false,
          autocorrect: false,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              tooltip: obscure ? 'Show $label' : 'Hide $label',
              onPressed: onToggleObscure,
            ),
          ),
          validator: validator,
        ),
        if (configured && editing)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.busy ? null : onCancelChange,
              child: const Text('Cancel change'),
            ),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateTatmeenIntegrationSettingsRequest(
      username: _usernameDirty ? _usernameController.text.trim() : null,
      password: _shouldSendPassword ? _passwordController.text : null,
      apiKey: _shouldSendApiKey ? _apiKeyController.text : null,
    );

    final saved = await widget.onSave(request);

    if (!mounted || !saved) return;
    _passwordController.clear();
    _apiKeyController.clear();
    _initialUsername =
        widget.settings?.username ?? _usernameController.text.trim();
    setState(_syncSecretEditingFlags);
  }

  bool get _shouldSendPassword =>
      _editingPassword && _passwordController.text.isNotEmpty;

  bool get _shouldSendApiKey =>
      _editingApiKey && _apiKeyController.text.isNotEmpty;
}

class _CredentialsSkeleton extends StatelessWidget {
  const _CredentialsSkeleton();

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSkeletonBox(width: 120, height: 18, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          AppSkeletonBox(width: double.infinity, height: 12, color: muted),
          const SizedBox(height: TraqSpacing.md),
          const _FieldSkeleton(),
          const SizedBox(height: TraqSpacing.md),
          const _FieldSkeleton(),
          const SizedBox(height: TraqSpacing.md),
          const _FieldSkeleton(),
          const SizedBox(height: TraqSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: AppSkeletonBox(
              width: 150,
              height: 40,
              radius: 8,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldSkeleton extends StatelessWidget {
  const _FieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      height: 56,
      radius: 4,
      color: AppShimmer.defaultBaseColor(context),
    );
  }
}
