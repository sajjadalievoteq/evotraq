import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class GtinSelector extends StatelessWidget {
  final String label;
  final String? hintText;
  final GTIN? initialValue;
  final String? initialGtinCode;
  final List<GTIN>? initialGtins;
  final Function(GTIN?) onChanged;
  final bool isRequired;
  final String? errorText;
  final bool readOnly;

  const GtinSelector({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.initialGtinCode,
    this.initialGtins,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      final code = initialValue?.gtinCode ?? initialGtinCode ?? '';
      final productName = initialValue?.productName ?? '';
      final displayText = code.isNotEmpty
          ? (productName.isNotEmpty ? '$code — $productName' : code)
          : '';
      return TextFormField(
        initialValue: displayText,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          prefixIcon: TraqIcon(AppAssets.iconQr),
        ),
      );
    }

    return BlocProvider(
      create: (_) => GTINCubit(gtinService: getIt<GTINService>()),
      child: _GtinSelectorBody(
        label: label,
        hintText: hintText,
        initialValue: initialValue,
        initialGtins: initialGtins,
        onChanged: onChanged,
        isRequired: isRequired,
        errorText: errorText,
      ),
    );
  }
}

class _GtinSelectorBody extends StatefulWidget {
  final String label;
  final String? hintText;
  final GTIN? initialValue;
  final List<GTIN>? initialGtins;
  final Function(GTIN?) onChanged;
  final bool isRequired;
  final String? errorText;

  const _GtinSelectorBody({
    required this.label,
    this.hintText,
    this.initialValue,
    this.initialGtins,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
  });

  @override
  State<_GtinSelectorBody> createState() => _GtinSelectorBodyState();
}

class _GtinSelectorBodyState extends State<_GtinSelectorBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  bool _isLoadingGTINs = false;
  List<GTIN> _filteredGTINs = [];
  List<GTIN> _allGTINs = [];
  GTIN? _selectedGTIN;

  @override
  void initState() {
    super.initState();
    _selectedGTIN = widget.initialValue;
    if (_selectedGTIN != null) {
      _searchController.text = _getDisplayText(_selectedGTIN!);
    }
    if (widget.initialGtins != null && widget.initialGtins!.isNotEmpty) {
      _allGTINs = widget.initialGtins!;
      _filteredGTINs = widget.initialGtins!;
    } else {
      _loadGTINs();
    }
  }

  @override
  void didUpdateWidget(_GtinSelectorBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialGtins != null &&
        widget.initialGtins != oldWidget.initialGtins) {
      setState(() {
        _allGTINs = widget.initialGtins!;
        final q = _searchController.text.toLowerCase();
        _filteredGTINs = q.isEmpty
            ? _allGTINs
            : _allGTINs
                .where((g) =>
                    g.gtinCode.toLowerCase().contains(q) ||
                    g.productName.toLowerCase().contains(q) ||
                    (g.manufacturer?.toLowerCase().contains(q) ?? false))
                .toList();
      });
    }

    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedGTIN = widget.initialValue;
        if (_selectedGTIN != null) {
          _searchController.text = _getDisplayText(_selectedGTIN!);
          _isDropdownOpen = false;
        } else {
          _searchController.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadGTINs() {
    setState(() => _isLoadingGTINs = true);
    context.read<GTINCubit>().fetchGtinsForPicker().then((gtins) {
      if (mounted) {
        setState(() {
          _allGTINs = gtins;
          _filteredGTINs = gtins;
          _isLoadingGTINs = false;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() => _isLoadingGTINs = false);
    });
  }

  String _getDisplayText(GTIN gtin) => '${gtin.gtinCode} — ${gtin.productName}';

  void _filterGTINs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGTINs = _allGTINs;
      } else {
        final q = query.toLowerCase();
        _filteredGTINs = _allGTINs.where((gtin) {
          return gtin.gtinCode.toLowerCase().contains(q) ||
              gtin.productName.toLowerCase().contains(q) ||
              (gtin.manufacturer?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    });
  }

  void _selectGTIN(GTIN gtin) {
    setState(() {
      _selectedGTIN = gtin;
      _searchController.text = _getDisplayText(gtin);
      _isDropdownOpen = false;
    });
    _focusNode.unfocus();
    widget.onChanged(gtin);
  }

  void _clearSelection() {
    setState(() {
      _selectedGTIN = null;
      _searchController.clear();
      _filteredGTINs = _allGTINs;
      _isDropdownOpen = _allGTINs.isNotEmpty;
    });
    widget.onChanged(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label + (widget.isRequired ? ' *' : ''),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),

        TextFormField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search GTIN code or product name…',
            prefixIcon: TraqIcon(AppAssets.iconQr),
            suffixIcon: _selectedGTIN != null
                ? IconButton(
                    icon: TraqIcon(AppAssets.iconX),
                    onPressed: _clearSelection,
                  )
                : IconButton(
                    icon: TraqIcon(_isDropdownOpen
                        ? AppAssets.iconChevronU
                        : AppAssets.iconChevronD),
                    onPressed: () {
                      setState(() => _isDropdownOpen = !_isDropdownOpen);
                      if (_isDropdownOpen) {
                        _focusNode.requestFocus();
                      } else {
                        _focusNode.unfocus();
                      }
                    },
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: widget.errorText,
          ),
          onChanged: (value) {
            if (_selectedGTIN != null) return;
            setState(() => _isDropdownOpen = true);
            _filterGTINs(value);
          },
          onTap: () {
            if (_selectedGTIN != null) return;
            setState(() => _isDropdownOpen = true);
          },
          readOnly: _selectedGTIN != null,
        ),

        if (_isLoadingGTINs)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: AppShimmer(
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (!_isLoadingGTINs && _isDropdownOpen && _filteredGTINs.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredGTINs.length,
              itemBuilder: (context, index) {
                final gtin = _filteredGTINs[index];
                return ListTile(
                  dense: true,
                  leading: TraqIcon(AppAssets.iconQr, size: 20),
                  title: Text(
                    gtin.gtinCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gtin.productName,
                          style: const TextStyle(fontSize: 13)),
                      if (gtin.manufacturer != null)
                        Text(
                          gtin.manufacturer!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                  onTap: () => _selectGTIN(gtin),
                  selected: _selectedGTIN?.gtinCode == gtin.gtinCode,
                  selectedTileColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                );
              },
            ),
          ),

        if (!_isLoadingGTINs &&
            _isDropdownOpen &&
            _filteredGTINs.isEmpty &&
            _allGTINs.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: const Text(
              'No GTINs found matching your search.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
