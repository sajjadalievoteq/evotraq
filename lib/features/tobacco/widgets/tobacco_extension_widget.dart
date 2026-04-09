import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/tobacco/models/gtin_tobacco_extension_model.dart';
import 'package:traqtrace_app/features/tobacco/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';

/// Widget that displays/edits tobacco extension data for a GTIN
/// Can be embedded in GTIN detail screens or used standalone
class TobaccoExtensionWidget extends StatefulWidget {
  final int? gtinId;
  final String? gtinCode;
  final bool isEditing;
  final Function(GTINTobaccoExtension?)? onSaved;

  const TobaccoExtensionWidget({
    Key? key,
    this.gtinId,
    this.gtinCode,
    this.isEditing = false,
    this.onSaved,
  }) : super(key: key);

  @override
  State<TobaccoExtensionWidget> createState() => TobaccoExtensionWidgetState();
}

/// State class for TobaccoExtensionWidget - made public to allow GlobalKey access
class TobaccoExtensionWidgetState extends State<TobaccoExtensionWidget> {
  GTINTobaccoExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  // Country options (ISO 3166-1 alpha-3) - common tobacco-related countries
  static const Map<String, String> _countryOptions = {
    'USA': 'United States',
    'CHN': 'China',
    'IND': 'India',
    'BRA': 'Brazil',
    'IDN': 'Indonesia',
    'JPN': 'Japan',
    'RUS': 'Russia',
    'TUR': 'Turkey',
    'DEU': 'Germany',
    'GBR': 'United Kingdom',
    'FRA': 'France',
    'ITA': 'Italy',
    'ESP': 'Spain',
    'POL': 'Poland',
    'MEX': 'Mexico',
    'ARG': 'Argentina',
    'CAN': 'Canada',
    'AUS': 'Australia',
    'ZAF': 'South Africa',
    'EGY': 'Egypt',
    'PHL': 'Philippines',
    'VNM': 'Vietnam',
    'PAK': 'Pakistan',
    'BGD': 'Bangladesh',
    'NGA': 'Nigeria',
    'UKR': 'Ukraine',
    'KOR': 'South Korea',
    'THA': 'Thailand',
    'MYS': 'Malaysia',
    'SAU': 'Saudi Arabia',
    'ARE': 'United Arab Emirates',
    'CHE': 'Switzerland',
    'NLD': 'Netherlands',
    'BEL': 'Belgium',
    'AUT': 'Austria',
    'SWE': 'Sweden',
    'NOR': 'Norway',
    'DNK': 'Denmark',
    'FIN': 'Finland',
    'IRL': 'Ireland',
    'PRT': 'Portugal',
    'GRC': 'Greece',
    'CZE': 'Czech Republic',
    'HUN': 'Hungary',
    'ROU': 'Romania',
    'BGR': 'Bulgaria',
    'CUB': 'Cuba',
    'DOM': 'Dominican Republic',
    'NIC': 'Nicaragua',
    'HND': 'Honduras',
    'ZWE': 'Zimbabwe',
    'MWI': 'Malawi',
  };

  // Form controllers
  final _brandFamilyController = TextEditingController();
  final _brandVariantController = TextEditingController();
  final _nicotineController = TextEditingController();
  final _tarController = TextEditingController();
  final _carbonMonoxideController = TextEditingController();
  final _unitsPerPackController = TextEditingController();
  final _filterTypeController = TextEditingController();
  final _lengthController = TextEditingController();
  final _maxRetailPriceController = TextEditingController();
  final _taxCategoryController = TextEditingController();
  final _exciseTaxRateController = TextEditingController();
  final _leafOriginCountriesController = TextEditingController();
  final _moistureContentController = TextEditingController();
  final _qualityGradeController = TextEditingController();

  // Country dropdowns (replacing text controllers)
  String? _countryOfOrigin;
  String? _intendedMarket;

  TobaccoProductCategory? _category;
  TobaccoCuringMethod? _curingMethod;
  String? _packType;
  bool _isMenthol = false;
  bool _isSlim = false;
  bool _isKingSize = false;

  final _packTypeOptions = ['SOFT_PACK', 'HARD_PACK', 'TIN', 'POUCH', 'BOX'];

  @override
  void initState() {
    super.initState();
    _loadTobaccoExtension();
  }

  @override
  void dispose() {
    _brandFamilyController.dispose();
    _brandVariantController.dispose();
    _nicotineController.dispose();
    _tarController.dispose();
    _carbonMonoxideController.dispose();
    _unitsPerPackController.dispose();
    _filterTypeController.dispose();
    _lengthController.dispose();
    _maxRetailPriceController.dispose();
    _taxCategoryController.dispose();
    _exciseTaxRateController.dispose();
    _leafOriginCountriesController.dispose();
    _moistureContentController.dispose();
    _qualityGradeController.dispose();
    super.dispose();
  }

  Future<void> _loadTobaccoExtension() async {
    // Skip loading if no valid GTIN code or ID is provided (e.g., when creating a new GTIN)
    final hasValidGtinCode = widget.gtinCode != null && widget.gtinCode!.isNotEmpty;
    final hasValidGtinId = widget.gtinId != null;
    
    if (!hasValidGtinCode && !hasValidGtinId) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final service = getIt<GTINTobaccoExtensionService>();
      
      GTINTobaccoExtension? ext;
      if (hasValidGtinCode) {
        ext = await service.getByGtinCode(widget.gtinCode!);
      } else if (widget.gtinId != null) {
        ext = await service.getByGtinId(widget.gtinId!);
      }
      
      if (mounted) {
        setState(() {
          _extension = ext;
          _hasExtension = ext != null;
          _isLoading = false;
          if (ext != null) {
            _initializeForm(ext);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExtension = false;
          // Not an error if extension doesn't exist - it's optional
        });
      }
    }
  }

  void _initializeForm(GTINTobaccoExtension ext) {
    _category = ext.tobaccoCategory;
    _brandFamilyController.text = ext.brandFamily;
    _brandVariantController.text = ext.brandVariant ?? '';
    _nicotineController.text = ext.nicotineContentMg?.toString() ?? '';
    _tarController.text = ext.tarContentMg?.toString() ?? '';
    _carbonMonoxideController.text = ext.carbonMonoxideMg?.toString() ?? '';
    _unitsPerPackController.text = ext.unitsPerPack?.toString() ?? '20';
    _packType = ext.packType;
    _isMenthol = ext.isMenthol ?? false;
    _isSlim = ext.isSlim ?? false;
    _isKingSize = ext.isKingSize ?? false;
    _filterTypeController.text = ext.filterType ?? '';
    _lengthController.text = ext.cigaretteLengthMm?.toString() ?? '';
    _countryOfOrigin = ext.countryOfOrigin;
    _intendedMarket = ext.intendedMarket;
    _maxRetailPriceController.text = ext.maxRetailPrice?.toString() ?? '';
    _taxCategoryController.text = ext.taxCategory ?? '';
    _exciseTaxRateController.text = ext.exciseTaxRate?.toString() ?? '';
    _curingMethod = ext.curingMethod;
    _leafOriginCountriesController.text = ext.leafOriginCountries ?? '';
    _moistureContentController.text = ext.moistureContentPercent?.toString() ?? '';
    _qualityGradeController.text = ext.qualityGrade ?? '';
  }

  /// Check if user has entered any tobacco data
  bool get hasData => _category != null || _brandFamilyController.text.isNotEmpty;

  /// Validate the tobacco extension form
  /// Returns null if valid, error message if invalid
  String? validate() {
    if (!hasData) return null; // No data entered, nothing to validate
    if (_category == null) return 'Tobacco Category is required';
    if (_brandFamilyController.text.isEmpty) return 'Brand Family is required';
    return null;
  }

  /// Build the extension object from form data
  /// Returns null if no data has been entered
  GTINTobaccoExtension? buildExtension({int? gtinId, String? gtinCode}) {
    if (!hasData) return null;
    
    return GTINTobaccoExtension(
      id: _extension?.id,
      gtinId: gtinId ?? widget.gtinId ?? _extension?.gtinId ?? 0,
      gtinCode: gtinCode ?? widget.gtinCode,
      tobaccoCategory: _category!,
      brandFamily: _brandFamilyController.text,
      brandVariant: _brandVariantController.text.isEmpty ? null : _brandVariantController.text,
      nicotineContentMg: double.tryParse(_nicotineController.text),
      tarContentMg: double.tryParse(_tarController.text),
      carbonMonoxideMg: double.tryParse(_carbonMonoxideController.text),
      unitsPerPack: int.tryParse(_unitsPerPackController.text) ?? 20,
      packType: _packType,
      isMenthol: _isMenthol,
      isSlim: _isSlim,
      isKingSize: _isKingSize,
      filterType: _filterTypeController.text.isEmpty ? null : _filterTypeController.text,
      cigaretteLengthMm: int.tryParse(_lengthController.text),
      countryOfOrigin: _countryOfOrigin,
      intendedMarket: _intendedMarket,
      maxRetailPrice: double.tryParse(_maxRetailPriceController.text),
      taxCategory: _taxCategoryController.text.isEmpty ? null : _taxCategoryController.text,
      exciseTaxRate: double.tryParse(_exciseTaxRateController.text),
      curingMethod: _curingMethod,
      leafOriginCountries: _leafOriginCountriesController.text.isEmpty ? null : _leafOriginCountriesController.text,
      moistureContentPercent: double.tryParse(_moistureContentController.text),
      qualityGrade: _qualityGradeController.text.isEmpty ? null : _qualityGradeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if system is in tobacco mode OR user has license access
    // Use listen: false to avoid rebuilding when provider changes and to prevent
    // "Looking up a deactivated widget's ancestor" errors during navigation
    // Wrap in try-catch to handle case when widget is deactivated during mode change
    bool hasAccess = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      hasAccess = settings.isTobaccoMode;
    } catch (e) {
      // Widget is deactivated, return empty
      return const SizedBox.shrink();
    }
    
    if (!hasAccess) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.brown.shade700,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        leading: Icon(
          Icons.smoking_rooms,
          color: _hasExtension ? Colors.brown : Colors.grey,
        ),
        title: Text(
          'Tobacco Product Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _hasExtension ? Colors.brown : null,
          ),
        ),
        //subtitle: _hasExtension
        //    ? Text('${_extension?.tobaccoCategory.displayName ?? ''} - ${_brandFamilyController.text}')
        //    : const Text('No tobacco extension'),
        initiallyExpanded: _hasExtension,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form content
                widget.isEditing ? _buildEditForm() : _buildReadOnlyView(),
                // Note: Save button removed - tobacco extension is saved with the main GTIN form
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyView() {
    if (!_hasExtension) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.smoke_free, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No tobacco extension defined for this product',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final ext = _extension!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Category', ext.tobaccoCategory.displayName),
        _buildInfoRow('Brand Family', ext.brandFamily),
        if (ext.brandVariant != null) _buildInfoRow('Brand Variant', ext.brandVariant!),
        const Divider(),
        _buildSectionTitle('Chemical Content'),
        if (ext.nicotineContentMg != null) _buildInfoRow('Nicotine', '${ext.nicotineContentMg} mg'),
        if (ext.tarContentMg != null) _buildInfoRow('Tar', '${ext.tarContentMg} mg'),
        if (ext.carbonMonoxideMg != null) _buildInfoRow('Carbon Monoxide', '${ext.carbonMonoxideMg} mg'),
        const Divider(),
        _buildSectionTitle('Physical Properties'),
        if (ext.unitsPerPack != null) _buildInfoRow('Units Per Pack', ext.unitsPerPack.toString()),
        if (ext.packType != null) _buildInfoRow('Pack Type', ext.packType!),
        _buildInfoRow('Menthol', ext.isMenthol == true ? 'Yes' : 'No'),
        _buildInfoRow('Slim', ext.isSlim == true ? 'Yes' : 'No'),
        _buildInfoRow('King Size', ext.isKingSize == true ? 'Yes' : 'No'),
        if (ext.filterType != null) _buildInfoRow('Filter Type', ext.filterType!),
        if (ext.cigaretteLengthMm != null) _buildInfoRow('Length', '${ext.cigaretteLengthMm} mm'),
        const Divider(),
        _buildSectionTitle('Market & Tax Information'),
        if (ext.countryOfOrigin != null) _buildInfoRow('Country of Origin', ext.countryOfOrigin!),
        if (ext.intendedMarket != null) _buildInfoRow('Intended Market', ext.intendedMarket!),
        if (ext.maxRetailPrice != null) 
          _buildInfoRow('Max Retail Price', 
            '${ext.maxRetailPrice} ${ext.maxRetailPriceCurrency ?? 'USD'}'),
        if (ext.taxCategory != null) _buildInfoRow('Tax Category', ext.taxCategory!),
        if (ext.exciseTaxRate != null) _buildInfoRow('Excise Tax Rate', '${ext.exciseTaxRate}%'),
        const Divider(),
        _buildSectionTitle('Tobacco Information'),
        if (ext.curingMethod != null) _buildInfoRow('Curing Method', ext.curingMethod!.displayName),
        if (ext.leafOriginCountries != null) _buildInfoRow('Leaf Origin', ext.leafOriginCountries!),
        if (ext.moistureContentPercent != null) _buildInfoRow('Moisture Content', '${ext.moistureContentPercent}%'),
        if (ext.qualityGrade != null) _buildInfoRow('Quality Grade', ext.qualityGrade!),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.brown.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        DropdownButtonFormField<TobaccoProductCategory>(
          decoration: const InputDecoration(
            labelText: 'Product Category *',
            border: OutlineInputBorder(),
          ),
          value: _category,
          items: TobaccoProductCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat.displayName),
            );
          }).toList(),
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: 16),

        // Brand Family
        TextFormField(
          controller: _brandFamilyController,
          decoration: const InputDecoration(
            labelText: 'Brand Family *',
            border: OutlineInputBorder(),
            hintText: 'e.g., Marlboro, Camel',
          ),
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 16),

        // Brand Variant
        TextFormField(
          controller: _brandVariantController,
          decoration: const InputDecoration(
            labelText: 'Brand Variant',
            border: OutlineInputBorder(),
            hintText: 'e.g., Red, Gold, Light',
          ),
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Chemical Content'),

        // Nicotine, Tar, CO in a row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nicotineController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nicotine (mg)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _tarController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tar (mg)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _carbonMonoxideController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CO (mg)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Physical Properties'),

        // Units per pack and Pack type
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _unitsPerPackController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Units Per Pack',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pack Type',
                  border: OutlineInputBorder(),
                ),
                value: _packType,
                items: _packTypeOptions.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _packType = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Checkboxes
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Menthol'),
                value: _isMenthol,
                onChanged: (value) => setState(() => _isMenthol = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Slim'),
                value: _isSlim,
                onChanged: (value) => setState(() => _isSlim = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('King Size'),
                value: _isKingSize,
                onChanged: (value) => setState(() => _isKingSize = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter type and Length
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _filterTypeController,
                decoration: const InputDecoration(
                  labelText: 'Filter Type',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Length (mm)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Market & Tax Information'),

        // Country of origin and intended market
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Country of Origin',
                  border: OutlineInputBorder(),
                ),
                value: _countryOfOrigin,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ..._countryOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => _countryOfOrigin = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Intended Market',
                  border: OutlineInputBorder(),
                ),
                value: _intendedMarket,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ..._countryOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => _intendedMarket = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Max retail price and tax category
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maxRetailPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Retail Price',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _taxCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Tax Category',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _exciseTaxRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Excise Tax Rate (%)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Tobacco Information'),

        // Curing method
        DropdownButtonFormField<TobaccoCuringMethod>(
          decoration: const InputDecoration(
            labelText: 'Curing Method',
            border: OutlineInputBorder(),
          ),
          value: _curingMethod,
          items: TobaccoCuringMethod.values.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method.displayName),
            );
          }).toList(),
          onChanged: (value) => setState(() => _curingMethod = value),
        ),
        const SizedBox(height: 16),

        // Leaf origin countries
        TextFormField(
          controller: _leafOriginCountriesController,
          decoration: const InputDecoration(
            labelText: 'Leaf Origin Countries',
            border: OutlineInputBorder(),
            hintText: 'e.g., Brazil, Zimbabwe, USA',
          ),
        ),
        const SizedBox(height: 16),

        // Moisture and quality
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _moistureContentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Moisture Content (%)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _qualityGradeController,
                decoration: const InputDecoration(
                  labelText: 'Quality Grade',
                  border: OutlineInputBorder(),
                ),
                maxLength: 10,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
