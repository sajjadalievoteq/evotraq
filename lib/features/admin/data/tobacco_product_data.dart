/// Real tobacco product data for UAE market
/// Based on actual brands and specifications available in the region
class TobaccoProductData {
  /// Calculate GS1 check digit using standard modulo 10 algorithm
  /// This matches the backend calculation exactly
  static int _calculateCheckDigit(String digits) {
    int sum = 0;
    bool multiplyBy3 = true;
    
    // Process from right to left (same as backend)
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      if (multiplyBy3) {
        sum += digit * 3;
      } else {
        sum += digit;
      }
      multiplyBy3 = !multiplyBy3;
    }
    
    return (10 - (sum % 10)) % 10;
  }
  
  /// Generate a valid GTIN-14 with correct check digit
  static String _gtin(String baseCode) {
    // baseCode should be 13 digits, we calculate and append check digit
    final checkDigit = _calculateCheckDigit(baseCode);
    return '$baseCode$checkDigit';
  }
  
  /// Generate a valid GLN-13 with correct check digit
  static String _gln(String baseCode) {
    // baseCode should be 12 digits, we calculate and append check digit
    final checkDigit = _calculateCheckDigit(baseCode);
    return '$baseCode$checkDigit';
  }
  
  /// Generate a valid SSCC-18 with correct check digit
  /// SSCC = Extension Digit (1) + GS1 Company Prefix (7-10) + Serial Reference (6-9) + Check Digit (1)
  static String generateSSCC(String extensionDigit, String companyPrefix, String serialRef) {
    // Ensure we have exactly 17 digits before check digit
    final base = '$extensionDigit$companyPrefix$serialRef';
    if (base.length != 17) {
      throw ArgumentError('SSCC base must be 17 digits, got ${base.length}');
    }
    final checkDigit = _calculateCheckDigit(base);
    return '$base$checkDigit';
  }
  
  /// Generate batch number in realistic format
  static String generateBatchNumber(int manufacturerIndex, int year, int month, int batchSeq) {
    final monthStr = month.toString().padLeft(2, '0');
    final seqStr = batchSeq.toString().padLeft(4, '0');
    return 'UAE-${manufacturerIndex.toString().padLeft(2, '0')}-$year$monthStr-$seqStr';
  }
  
  /// Get available GS1 company prefixes for UAE tobacco manufacturers
  static List<Map<String, String>> getManufacturerPrefixes() {
    return [
      {'name': 'Philip Morris UAE', 'prefix': '6291000', 'glnCode': '6291000000013'},
      {'name': 'BAT Middle East', 'prefix': '6291001', 'glnCode': '6291000000020'},
      {'name': 'JTI UAE', 'prefix': '6291002', 'glnCode': '6291000000037'},
      {'name': 'Imperial Tobacco', 'prefix': '6291003', 'glnCode': '6291000000044'},
      {'name': 'KT&G Middle East', 'prefix': '6291004', 'glnCode': '6291000000051'},
    ];
  }
  
  /// Get 50 real tobacco products for UAE market
  static List<Map<String, dynamic>> getUAETobaccoProducts() {
    return [
      // Marlboro Family (Philip Morris) - Using UAE GS1 prefix 629
      _product(_gtin('0629000010001'), 'Marlboro Red', 'Philip Morris', 'Marlboro', 'Red', 10.0, 1.0, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'CHE', 21.0, 'FLUE_CURED'),
      _product(_gtin('0629000010002'), 'Marlboro Gold', 'Philip Morris', 'Marlboro', 'Gold', 6.0, 0.5, 7.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'CHE', 21.0, 'FLUE_CURED'),
      _product(_gtin('0629000010003'), 'Marlboro Silver', 'Philip Morris', 'Marlboro', 'Silver', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'CHE', 21.0, 'FLUE_CURED'),
      _product(_gtin('0629000010004'), 'Marlboro Ice Blast', 'Philip Morris', 'Marlboro', 'Ice Blast', 6.0, 0.5, 7.0, 20, 'HARD_PACK', true, false, true, 'CHARCOAL', 84, 'CHE', 23.0, 'FLUE_CURED'),
      _product(_gtin('0629000010005'), 'Marlboro Touch', 'Philip Morris', 'Marlboro', 'Touch', 3.0, 0.3, 4.0, 20, 'HARD_PACK', false, true, false, 'STANDARD', 83, 'CHE', 21.0, 'FLUE_CURED'),

      // Dunhill Family (BAT)
      _product(_gtin('0629000020001'), 'Dunhill International', 'British American Tobacco', 'Dunhill', 'International', 10.0, 0.9, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'GBR', 22.0, 'FLUE_CURED'),
      _product(_gtin('0629000020002'), 'Dunhill Fine Cut Blue', 'British American Tobacco', 'Dunhill', 'Fine Cut Blue', 6.0, 0.6, 7.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'GBR', 22.0, 'FLUE_CURED'),
      _product(_gtin('0629000020003'), 'Dunhill Fine Cut White', 'British American Tobacco', 'Dunhill', 'Fine Cut White', 1.0, 0.1, 2.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'GBR', 22.0, 'FLUE_CURED'),
      _product(_gtin('0629000020004'), 'Dunhill Switch', 'British American Tobacco', 'Dunhill', 'Switch', 6.0, 0.5, 6.0, 20, 'HARD_PACK', true, false, true, 'CHARCOAL', 84, 'GBR', 24.0, 'FLUE_CURED'),

      // Kent Family (BAT)
      _product(_gtin('0629000030001'), 'Kent HD Blue', 'British American Tobacco', 'Kent', 'HD Blue', 6.0, 0.5, 6.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'ROU', 20.0, 'FLUE_CURED'),
      _product(_gtin('0629000030002'), 'Kent HD Silver', 'British American Tobacco', 'Kent', 'HD Silver', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'ROU', 20.0, 'FLUE_CURED'),
      _product(_gtin('0629000030003'), 'Kent HD White', 'British American Tobacco', 'Kent', 'HD White', 1.0, 0.1, 2.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'ROU', 20.0, 'FLUE_CURED'),
      _product(_gtin('0629000030004'), 'Kent Nanotek', 'British American Tobacco', 'Kent', 'Nanotek', 4.0, 0.3, 4.0, 20, 'HARD_PACK', false, true, false, 'CHARCOAL', 72, 'ROU', 19.0, 'FLUE_CURED'),

      // Winston Family (JTI)
      _product(_gtin('0629000040001'), 'Winston Classic', 'Japan Tobacco International', 'Winston', 'Classic', 10.0, 0.8, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'RUS', 18.0, 'FLUE_CURED'),
      _product(_gtin('0629000040002'), 'Winston Blue', 'Japan Tobacco International', 'Winston', 'Blue', 6.0, 0.5, 7.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'RUS', 18.0, 'FLUE_CURED'),
      _product(_gtin('0629000040003'), 'Winston Silver', 'Japan Tobacco International', 'Winston', 'Silver', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'RUS', 18.0, 'FLUE_CURED'),
      _product(_gtin('0629000040004'), 'Winston XS Blue', 'Japan Tobacco International', 'Winston', 'XS Blue', 5.0, 0.4, 5.0, 20, 'HARD_PACK', false, true, false, 'STANDARD', 83, 'RUS', 17.0, 'FLUE_CURED'),

      // Davidoff Family (Imperial)
      _product(_gtin('0629000050001'), 'Davidoff Classic', 'Imperial Brands', 'Davidoff', 'Classic', 10.0, 0.8, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'DEU', 25.0, 'FLUE_CURED'),
      _product(_gtin('0629000050002'), 'Davidoff Gold', 'Imperial Brands', 'Davidoff', 'Gold', 6.0, 0.5, 6.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'DEU', 25.0, 'FLUE_CURED'),
      _product(_gtin('0629000050003'), 'Davidoff White', 'Imperial Brands', 'Davidoff', 'White', 1.0, 0.1, 2.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'DEU', 25.0, 'FLUE_CURED'),
      _product(_gtin('0629000050004'), 'Davidoff Slims', 'Imperial Brands', 'Davidoff', 'Slims', 5.0, 0.4, 5.0, 20, 'HARD_PACK', false, true, false, 'STANDARD', 100, 'DEU', 26.0, 'FLUE_CURED'),

      // Parliament Family (Philip Morris)
      _product(_gtin('0629000060001'), 'Parliament Reserve', 'Philip Morris', 'Parliament', 'Reserve', 6.0, 0.5, 6.0, 20, 'HARD_PACK', false, false, true, 'RECESSED', 84, 'CHE', 24.0, 'FLUE_CURED'),
      _product(_gtin('0629000060002'), 'Parliament Platinum', 'Philip Morris', 'Parliament', 'Platinum', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'RECESSED', 84, 'CHE', 24.0, 'FLUE_CURED'),
      _product(_gtin('0629000060003'), 'Parliament Silver', 'Philip Morris', 'Parliament', 'Silver', 1.0, 0.1, 2.0, 20, 'HARD_PACK', false, false, true, 'RECESSED', 84, 'CHE', 24.0, 'FLUE_CURED'),

      // Camel Family (JTI)
      _product(_gtin('0629000070001'), 'Camel Blue', 'Japan Tobacco International', 'Camel', 'Blue', 6.0, 0.5, 7.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'TUR', 17.0, 'FLUE_CURED'),
      _product(_gtin('0629000070002'), 'Camel Yellow', 'Japan Tobacco International', 'Camel', 'Yellow', 10.0, 0.8, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'TUR', 17.0, 'FLUE_CURED'),
      _product(_gtin('0629000070003'), 'Camel White', 'Japan Tobacco International', 'Camel', 'White', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'TUR', 17.0, 'FLUE_CURED'),

      // L&M Family (Philip Morris)
      _product(_gtin('0629000080001'), 'L&M Red', 'Philip Morris', 'L&M', 'Red Label', 10.0, 0.8, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'POL', 16.0, 'FLUE_CURED'),
      _product(_gtin('0629000080002'), 'L&M Blue', 'Philip Morris', 'L&M', 'Blue Label', 6.0, 0.5, 7.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'POL', 16.0, 'FLUE_CURED'),
      _product(_gtin('0629000080003'), 'L&M Silver', 'Philip Morris', 'L&M', 'Silver Label', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'POL', 16.0, 'FLUE_CURED'),

      // Rothmans Family (BAT)
      _product(_gtin('0629000090001'), 'Rothmans Blue', 'British American Tobacco', 'Rothmans', 'Blue', 6.0, 0.6, 7.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'GBR', 19.0, 'FLUE_CURED'),
      _product(_gtin('0629000090002'), 'Rothmans Red', 'British American Tobacco', 'Rothmans', 'Red', 10.0, 0.9, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'GBR', 19.0, 'FLUE_CURED'),
      _product(_gtin('0629000090003'), 'Rothmans Silver', 'British American Tobacco', 'Rothmans', 'Silver', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'GBR', 19.0, 'FLUE_CURED'),

      // Pall Mall Family (BAT)
      _product(_gtin('0629000100001'), 'Pall Mall Red', 'British American Tobacco', 'Pall Mall', 'Red', 10.0, 0.8, 10.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'DEU', 15.0, 'FLUE_CURED'),
      _product(_gtin('0629000100002'), 'Pall Mall Blue', 'British American Tobacco', 'Pall Mall', 'Blue', 6.0, 0.5, 6.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'DEU', 15.0, 'FLUE_CURED'),
      _product(_gtin('0629000100003'), 'Pall Mall Silver', 'British American Tobacco', 'Pall Mall', 'Silver', 4.0, 0.4, 4.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'DEU', 15.0, 'FLUE_CURED'),

      // Lucky Strike Family (BAT)
      _product(_gtin('0629000110001'), 'Lucky Strike Original Red', 'British American Tobacco', 'Lucky Strike', 'Original Red', 10.0, 0.9, 10.0, 20, 'SOFT_PACK', false, false, true, 'STANDARD', 84, 'USA', 18.0, 'FLUE_CURED'),
      _product(_gtin('0629000110002'), 'Lucky Strike Blue', 'British American Tobacco', 'Lucky Strike', 'Blue', 6.0, 0.6, 7.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'DEU', 18.0, 'FLUE_CURED'),
      _product(_gtin('0629000110003'), 'Lucky Strike Click & Roll', 'British American Tobacco', 'Lucky Strike', 'Click & Roll', 6.0, 0.5, 6.0, 20, 'HARD_PACK', true, false, true, 'CHARCOAL', 84, 'DEU', 20.0, 'FLUE_CURED'),

      // Benson & Hedges Family
      _product(_gtin('0629000120001'), 'Benson & Hedges Gold', 'Philip Morris', 'Benson & Hedges', 'Gold', 6.0, 0.5, 6.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'GBR', 22.0, 'FLUE_CURED'),
      _product(_gtin('0629000120002'), 'Benson & Hedges Silver', 'Philip Morris', 'Benson & Hedges', 'Silver', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, false, true, 'STANDARD', 84, 'GBR', 22.0, 'FLUE_CURED'),

      // Vogue Family (BAT)
      _product(_gtin('0629000130001'), 'Vogue Bleue', 'British American Tobacco', 'Vogue', 'Bleue', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, true, false, 'STANDARD', 100, 'FRA', 23.0, 'FLUE_CURED'),
      _product(_gtin('0629000130002'), 'Vogue Lilas', 'British American Tobacco', 'Vogue', 'Lilas', 1.0, 0.1, 2.0, 20, 'HARD_PACK', false, true, false, 'STANDARD', 100, 'FRA', 23.0, 'FLUE_CURED'),
      _product(_gtin('0629000130003'), 'Vogue Menthe', 'British American Tobacco', 'Vogue', 'Menthe', 4.0, 0.4, 5.0, 20, 'HARD_PACK', true, true, false, 'STANDARD', 100, 'FRA', 24.0, 'FLUE_CURED'),

      // Esse Family (KT&G)
      _product(_gtin('0629000140001'), 'Esse Classic', 'KT&G Corporation', 'Esse', 'Classic', 4.0, 0.4, 5.0, 20, 'HARD_PACK', false, true, false, 'CHARCOAL', 84, 'KOR', 19.0, 'FLUE_CURED'),
      _product(_gtin('0629000140002'), 'Esse Change', 'KT&G Corporation', 'Esse', 'Change', 4.0, 0.4, 5.0, 20, 'HARD_PACK', true, true, false, 'CHARCOAL', 84, 'KOR', 20.0, 'FLUE_CURED'),
      _product(_gtin('0629000140003'), 'Esse Golden Leaf', 'KT&G Corporation', 'Esse', 'Golden Leaf', 5.0, 0.5, 6.0, 20, 'HARD_PACK', false, true, false, 'CHARCOAL', 84, 'KOR', 20.0, 'FLUE_CURED'),

      // Mevius Family (JTI)
      _product(_gtin('0629000150001'), 'Mevius Original', 'Japan Tobacco International', 'Mevius', 'Original', 6.0, 0.5, 6.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'JPN', 21.0, 'FLUE_CURED'),
      _product(_gtin('0629000150002'), 'Mevius Sky Blue', 'Japan Tobacco International', 'Mevius', 'Sky Blue', 3.0, 0.3, 4.0, 20, 'HARD_PACK', false, false, true, 'CHARCOAL', 84, 'JPN', 21.0, 'FLUE_CURED'),
      _product(_gtin('0629000150003'), 'Mevius Option', 'Japan Tobacco International', 'Mevius', 'Option', 5.0, 0.4, 5.0, 20, 'HARD_PACK', true, false, true, 'CHARCOAL', 84, 'JPN', 22.0, 'FLUE_CURED'),
    ];
  }

  static Map<String, dynamic> _product(
    String gtin, String name, String manufacturer, String brandFamily, String variant,
    double tar, double nicotine, double co, int units, String packType,
    bool menthol, bool slim, bool kingSize, String filter, int length,
    String origin, double price, String curing,
  ) {
    return {
      'gtinCode': gtin,
      'productName': name,
      'manufacturer': manufacturer,
      'brandFamily': brandFamily,
      'brandVariant': variant,
      'tarContentMg': tar,
      'nicotineContentMg': nicotine,
      'carbonMonoxideMg': co,
      'unitsPerPack': units,
      'packType': packType,
      'isMenthol': menthol,
      'isSlim': slim,
      'isKingSize': kingSize,
      'filterType': filter,
      'cigaretteLengthMm': length,
      'countryOfOrigin': origin,
      'maxRetailPrice': price,
      'curingMethod': curing,
      'tobaccoCategory': 'CIGARETTE',
    };
  }

  /// Get 50 tobacco-related locations for UAE
  static List<Map<String, dynamic>> getUAETobaccoLocations() {
    return [
      // Manufacturers
      _location(_gln('629100000001'), 'Philip Morris UAE Distribution', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),
      _location(_gln('629100000002'), 'BAT Middle East FZE', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),
      _location(_gln('629100000003'), 'JTI UAE Operations', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),
      _location(_gln('629100000004'), 'Imperial Tobacco Gulf', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),
      _location(_gln('629100000005'), 'KT&G Middle East', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),

      // Distribution Centers
      _location(_gln('629100000006'), 'Al Habtoor Tobacco DC', 'DISTRIBUTION_CENTER', 'Al Quoz Industrial', 'Dubai'),
      _location(_gln('629100000007'), 'Emirates Tobacco Logistics', 'DISTRIBUTION_CENTER', 'Dubai Industrial City', 'Dubai'),
      _location(_gln('629100000008'), 'Gulf Tobacco Trading LLC', 'DISTRIBUTION_CENTER', 'Musaffah Industrial', 'Abu Dhabi'),
      _location(_gln('629100000009'), 'Sharjah Tobacco Warehouse', 'DISTRIBUTION_CENTER', 'Sharjah Industrial Area', 'Sharjah'),
      _location(_gln('629100000010'), 'Ajman Tobacco Distribution', 'DISTRIBUTION_CENTER', 'Ajman Free Zone', 'Ajman'),

      // Wholesalers
      _location(_gln('629100000011'), 'Al Futtaim Tobacco Trading', 'WHOLESALER', 'Deira', 'Dubai'),
      _location(_gln('629100000012'), 'Bin Shabib Group Tobacco', 'WHOLESALER', 'Karama', 'Dubai'),
      _location(_gln('629100000013'), 'Emirates Tobacco Wholesalers', 'WHOLESALER', 'Mussafah', 'Abu Dhabi'),
      _location(_gln('629100000014'), 'Al Majid Tobacco Trading', 'WHOLESALER', 'Al Nahda', 'Sharjah'),
      _location(_gln('629100000015'), 'RAK Tobacco Traders', 'WHOLESALER', 'Al Nakheel', 'Ras Al Khaimah'),

      // Retailers - Dubai
      _location(_gln('629100000016'), 'Dubai Duty Free T1', 'RETAILER', 'Dubai International Airport T1', 'Dubai'),
      _location(_gln('629100000017'), 'Dubai Duty Free T3', 'RETAILER', 'Dubai International Airport T3', 'Dubai'),
      _location(_gln('629100000018'), 'Mall of Emirates Tobacco Shop', 'RETAILER', 'Mall of Emirates', 'Dubai'),
      _location(_gln('629100000019'), 'Dubai Mall Tobacco Corner', 'RETAILER', 'Dubai Mall', 'Dubai'),
      _location(_gln('629100000020'), 'Ibn Battuta Tobacco Store', 'RETAILER', 'Ibn Battuta Mall', 'Dubai'),
      _location(_gln('629100000021'), 'Marina Tobacco & More', 'RETAILER', 'Dubai Marina Mall', 'Dubai'),
      _location(_gln('629100000022'), 'JBR Tobacco Shop', 'RETAILER', 'The Walk JBR', 'Dubai'),
      _location(_gln('629100000023'), 'City Centre Deira Tobacco', 'RETAILER', 'City Centre Deira', 'Dubai'),
      _location(_gln('629100000024'), 'Mirdif City Centre Tobacco', 'RETAILER', 'Mirdif City Centre', 'Dubai'),
      _location(_gln('629100000025'), 'Festival City Tobacco', 'RETAILER', 'Dubai Festival City', 'Dubai'),

      // Retailers - Abu Dhabi
      _location(_gln('629100000026'), 'Abu Dhabi Duty Free', 'RETAILER', 'Abu Dhabi International Airport', 'Abu Dhabi'),
      _location(_gln('629100000027'), 'Yas Mall Tobacco Shop', 'RETAILER', 'Yas Mall', 'Abu Dhabi'),
      _location(_gln('629100000028'), 'Marina Mall Tobacco', 'RETAILER', 'Marina Mall', 'Abu Dhabi'),
      _location(_gln('629100000029'), 'Al Wahda Mall Tobacco', 'RETAILER', 'Al Wahda Mall', 'Abu Dhabi'),
      _location(_gln('629100000030'), 'Galleria Tobacco Corner', 'RETAILER', 'The Galleria Al Maryah', 'Abu Dhabi'),
      _location(_gln('629100000031'), 'Khalidiyah Tobacco Shop', 'RETAILER', 'Khalidiyah Mall', 'Abu Dhabi'),
      _location(_gln('629100000032'), 'Dalma Mall Tobacco', 'RETAILER', 'Dalma Mall', 'Abu Dhabi'),
      _location(_gln('629100000033'), 'Mushrif Mall Tobacco', 'RETAILER', 'Mushrif Mall', 'Abu Dhabi'),

      // Retailers - Other Emirates
      _location(_gln('629100000034'), 'Sharjah City Centre Tobacco', 'RETAILER', 'Sharjah City Centre', 'Sharjah'),
      _location(_gln('629100000035'), 'Sahara Centre Tobacco', 'RETAILER', 'Sahara Centre', 'Sharjah'),
      _location(_gln('629100000036'), 'Zero 6 Mall Tobacco', 'RETAILER', 'Zero 6 Mall', 'Sharjah'),
      _location(_gln('629100000037'), 'Ajman City Centre Tobacco', 'RETAILER', 'Ajman City Centre', 'Ajman'),
      _location(_gln('629100000038'), 'RAK Mall Tobacco Shop', 'RETAILER', 'RAK Mall', 'Ras Al Khaimah'),
      _location(_gln('629100000039'), 'Al Hamra Mall Tobacco', 'RETAILER', 'Al Hamra Mall', 'Ras Al Khaimah'),
      _location(_gln('629100000040'), 'Fujairah City Centre Tobacco', 'RETAILER', 'Fujairah City Centre', 'Fujairah'),
      _location(_gln('629100000041'), 'Fujairah Mall Tobacco', 'RETAILER', 'Fujairah Mall', 'Fujairah'),
      _location(_gln('629100000042'), 'UAQ Mall Tobacco', 'RETAILER', 'UAQ Mall', 'Umm Al Quwain'),

      // Convenience Stores
      _location(_gln('629100000043'), 'ENOC Tobacco Shop Al Quoz', 'CONVENIENCE_STORE', 'Al Quoz', 'Dubai'),
      _location(_gln('629100000044'), 'ADNOC Tobacco Corner Marina', 'CONVENIENCE_STORE', 'Marina', 'Abu Dhabi'),
      _location(_gln('629100000045'), 'Zoom Tobacco JLT', 'CONVENIENCE_STORE', 'JLT', 'Dubai'),
      _location(_gln('629100000046'), 'Zoom Tobacco Downtown', 'CONVENIENCE_STORE', 'Downtown', 'Dubai'),
      _location(_gln('629100000047'), 'EMARAT Tobacco Sharjah', 'CONVENIENCE_STORE', 'Al Majaz', 'Sharjah'),
      _location(_gln('629100000048'), 'Al Manara Tobacco Jumeirah', 'CONVENIENCE_STORE', 'Jumeirah', 'Dubai'),
      _location(_gln('629100000049'), 'Spinneys Tobacco Motor City', 'CONVENIENCE_STORE', 'Motor City', 'Dubai'),
      _location(_gln('629100000050'), 'Carrefour Tobacco City Centre', 'CONVENIENCE_STORE', 'City Centre', 'Dubai'),
    ];
  }

  static Map<String, dynamic> _location(
    String gln, String name, String type, String address, String city,
  ) {
    // UAE postal codes by emirate
    final postalCodes = {
      'Dubai': '00000',
      'Abu Dhabi': '00000',
      'Sharjah': '00000',
      'Ajman': '00000',
      'Ras Al Khaimah': '00000',
      'Fujairah': '00000',
      'Umm Al Quwain': '00000',
    };
    
    // FTA Registration prefixes by location type
    // Real FTA TRN format: 100XXXXXXXXX (15 digits starting with 100)
    final ftaPrefix = {
      'MANUFACTURER': '100',
      'DISTRIBUTION_CENTER': '100',
      'WHOLESALER': '100',
      'RETAILER': '100',
      'CONVENIENCE_STORE': '100',
    };
    
    // Extract last 4 digits of GLN for unique ID generation
    final glnSuffix = gln.substring(gln.length - 4);
    final prefix = ftaPrefix[type] ?? '100';
    
    // Generate realistic FTA Tax Registration Number (TRN)
    // Real UAE TRN format: 100XXXXXXXXX (15 digits)
    final ftaTrn = '${prefix}00000${glnSuffix}001';
    
    // Generate Digital Tax Stamp System ID
    // Format: DTS-UAE-YYYY-XXXXXX (for manufacturers/importers who apply stamps)
    final digitalTaxStampId = 'DTS-UAE-2024-$glnSuffix';
    
    // Generate Customs Registration for importers/manufacturers
    final customsRegNumber = 'UAE-CUST-2024-$glnSuffix';
    
    // License type prefixes
    final licensePrefix = {
      'MANUFACTURER': 'UAE-MFG',
      'DISTRIBUTION_CENTER': 'UAE-DST',
      'WHOLESALER': 'UAE-WHL',
      'RETAILER': 'UAE-RTL',
      'CONVENIENCE_STORE': 'UAE-CNV',
    };
    final licPrefix = licensePrefix[type] ?? 'UAE-OTH';
    
    // Storage capacity based on location type (in pallets)
    final storageCapacity = {
      'MANUFACTURER': 5000,
      'DISTRIBUTION_CENTER': 2000,
      'WHOLESALER': 500,
      'RETAILER': 50,
      'CONVENIENCE_STORE': 20,
    };
    
    return {
      'glnCode': gln,
      'locationName': name,
      'locationType': type,
      'address': address,
      'city': city,
      'postalCode': postalCodes[city] ?? '00000',
      
      // UAE FTA (Federal Tax Authority) Registration
      // All tobacco businesses must register with FTA for excise tax (100% on tobacco)
      'ftaRegistrationNumber': ftaTrn,
      
      // UAE Digital Tax Stamp ID
      // Required since August 2019 - all tobacco products must have digital tax stamps
      // Manufacturers/importers register with FTA to obtain stamp application authorization
      'digitalTaxStampId': type == 'MANUFACTURER' ? digitalTaxStampId : null,
      
      // Customs registration for import/export
      'customsRegistrationNumber': type == 'MANUFACTURER' || type == 'DISTRIBUTION_CENTER'
          ? customsRegNumber
          : null,
      
      // Tobacco-specific license numbers
      'tobaccoLicenseNumber': '$licPrefix-2024-$glnSuffix',
      'wholesaleLicenseNumber': type == 'WHOLESALER' || type == 'DISTRIBUTION_CENTER' 
          ? 'UAE-WHSL-2024-$glnSuffix' 
          : null,
      'salesPermitNumber': type == 'RETAILER' || type == 'CONVENIENCE_STORE'
          ? 'UAE-SALE-2024-$glnSuffix'
          : null,
      'storageCapacity': storageCapacity[type] ?? 100,
    };
  }
}
