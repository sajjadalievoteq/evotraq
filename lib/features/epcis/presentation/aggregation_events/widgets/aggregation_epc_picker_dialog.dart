import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/gs1_utils.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';

/// Pick commissioned SSCC / SGTIN records from master data (no demo generation).
class AggregationEpcPickerDialog {
  AggregationEpcPickerDialog._();

  static String _ssccToEpcUri(SSCC sscc) {
    if (sscc.ssccUri != null && sscc.ssccUri!.isNotEmpty) {
      return sscc.ssccUri!;
    }
    return GS1Utils.convertToSSCCEPC(sscc.ssccCode);
  }

  static String _sgtinToEpcUri(SGTIN sgtin) {
    if (sgtin.epcUri != null && sgtin.epcUri!.isNotEmpty) {
      return sgtin.epcUri!;
    }
    throw StateError(
      'SGTIN ${sgtin.serialNumber} has no EPC URI — commission it first.',
    );
  }

  static bool _isPackableSgtin(SGTIN sgtin) {
    if (sgtin.commissionedAt == null) return false;
    if (sgtin.decommissionedDate != null) return false;
    if (sgtin.epcUri == null || sgtin.epcUri!.isEmpty) return false;
    return switch (sgtin.status) {
      ItemStatus.DESTROYED ||
      ItemStatus.RECALLED ||
      ItemStatus.STOLEN ||
      ItemStatus.EXPIRED =>
        false,
      _ => true,
    };
  }

  static Future<String?> pickSscc(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => const _SsccPickerDialog(),
    );
  }

  static Future<List<String>> pickSgtins(BuildContext context) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => const _SgtinPickerDialog(),
    );
    return result ?? const [];
  }
}

class _SsccPickerDialog extends StatefulWidget {
  const _SsccPickerDialog();

  @override
  State<_SsccPickerDialog> createState() => _SsccPickerDialogState();
}

class _SsccPickerDialogState extends State<_SsccPickerDialog> {
  final _searchController = TextEditingController();
  List<SSCC> _ssccs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = getIt<SSCCService>();
      final result = await service.fetchSSCCListPage(page: 0, size: 200);
      final raw = result['content'] as List<SSCC>;
      final list = raw
          .where(
            (s) =>
                s.commissionedAt != null &&
                s.status != LogisticUnitStatus.DRAFT &&
                s.status != LogisticUnitStatus.DECOMMISSIONED &&
                s.status != LogisticUnitStatus.VOIDED,
          )
          .toList()
        ..sort((a, b) => a.ssccCode.compareTo(b.ssccCode));
      if (!mounted) return;
      setState(() {
        _ssccs = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<SSCC> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _ssccs;
    return _ssccs
        .where(
          (s) =>
              s.ssccCode.toLowerCase().contains(q) ||
              (s.ssccUri?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return AlertDialog(
      title: const Text('Select parent SSCC'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search SSCC',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (items.isEmpty)
              const Text('No commissioned or active SSCCs found.')
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final sscc = items[index];
                    return ListTile(
                      title: Text(sscc.ssccCode, style: const TextStyle(fontFamily: 'monospace')),
                      subtitle: Text(
                        '${sscc.status.name} · ${sscc.unitType.name}',
                      ),
                      onTap: () => Navigator.pop(
                        context,
                        AggregationEpcPickerDialog._ssccToEpcUri(sscc),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _SgtinPickerDialog extends StatefulWidget {
  const _SgtinPickerDialog();

  @override
  State<_SgtinPickerDialog> createState() => _SgtinPickerDialogState();
}

class _SgtinPickerDialogState extends State<_SgtinPickerDialog> {
  final _searchController = TextEditingController();
  final Set<String> _selectedUris = {};
  List<SGTIN> _sgtins = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = getIt<SGTINService>();
      final page = await service.getAllSGTINs(page: 0, size: 200);
      final list = page
          .where(AggregationEpcPickerDialog._isPackableSgtin)
          .toList()
        ..sort((a, b) => a.serialNumber.compareTo(b.serialNumber));
      if (!mounted) return;
      setState(() {
        _sgtins = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<SGTIN> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _sgtins;
    return _sgtins
        .where(
          (s) =>
              s.serialNumber.toLowerCase().contains(q) ||
              s.gtinCode.toLowerCase().contains(q) ||
              (s.epcUri?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return AlertDialog(
      title: const Text('Select child SGTINs'),
      content: SizedBox(
        width: 520,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search GTIN or serial',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            else if (items.isEmpty)
              const Expanded(
                child: Center(child: Text('No commissioned SGTINs found.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final sgtin = items[index];
                    final uri = AggregationEpcPickerDialog._sgtinToEpcUri(sgtin);
                    final selected = _selectedUris.contains(uri);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedUris.add(uri);
                          } else {
                            _selectedUris.remove(uri);
                          }
                        });
                      },
                      title: Text(
                        sgtin.serialNumber,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      subtitle: Text('GTIN ${sgtin.gtinCode}'),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedUris.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedUris.toList()),
          child: Text('Add (${_selectedUris.length})'),
        ),
      ],
    );
  }
}
