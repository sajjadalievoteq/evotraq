import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class OperationalGlnPreferenceCard extends StatefulWidget {
  const OperationalGlnPreferenceCard({super.key});

  @override
  State<OperationalGlnPreferenceCard> createState() =>
      _OperationalGlnPreferenceCardState();
}

class _OperationalGlnPreferenceCardState
    extends State<OperationalGlnPreferenceCard> {
  GLN? _selectedGln;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final code = await OperationalGlnStore.getGln(userId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (code != null) _selectedGln = GLN.fromCode(code);
    });
  }

  Future<void> _save() async {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) return;
    setState(() => _saving = true);
    await OperationalGlnStore.setGln(userId, _selectedGln?.glnCode);
    if (!mounted) return;
    setState(() => _saving = false);
    context.showSuccess('Operational GLN saved.');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supply Chain Identity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your operational GLN is used to authorize pharma return '
              'shipping and return receiving actions.',
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              GLNSelector(
                label: 'Operational GLN',
                hintText: 'Select your location GLN',
                initialValue: _selectedGln,
                onChanged: (gln) => setState(() => _selectedGln = gln),
              ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              label: 'Save Operational GLN',
              onPressed: _selectedGln == null || _saving ? () {} : _save,
              isLoading: _saving,
              isEnabled: _selectedGln != null && !_saving,
            ),
          ],
        ),
      ),
    );
  }
}
