import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_credentials_skeleton.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_credentials_read_only_summary.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_secret_field.dart';

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
    for (final controller in [
      _usernameController,
      _passwordController,
      _apiKeyController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
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

  bool get _canSave {
    if (widget.busy) return false;
    if (_usernameController.text.trim().isEmpty) return false;
    final passwordReady =
        _passwordConfigured && !_editingPassword ||
        _passwordController.text.isNotEmpty;
    final apiKeyReady =
        _apiKeyConfigured && !_editingApiKey || _apiKeyController.text.isNotEmpty;
    return passwordReady && apiKeyReady;
  }

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
    if (widget.isLoading) return const TatmeenCredentialsSkeleton();
    if (!widget.canUpdate) {
      return TatmeenCredentialsReadOnlySummary(settings: widget.settings);
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
          TatmeenSecretField(
            busy: widget.busy,
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
          TatmeenSecretField(
            busy: widget.busy,
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
              onPressed: _canSave ? _submit : null,
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
