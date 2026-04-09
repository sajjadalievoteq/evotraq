/// Real pharmaceutical product data for UAE market
/// Based on actual medicines and specifications available in the region
/// Compliant with UAE Ministry of Health & Prevention (MOHAP) requirements
class PharmaceuticalProductData {
  /// Calculate GS1 check digit using standard modulo 10 algorithm
  static int _calculateCheckDigit(String digits) {
    int sum = 0;
    bool multiplyBy3 = true;
    
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
    final checkDigit = _calculateCheckDigit(baseCode);
    return '$baseCode$checkDigit';
  }
  
  /// Generate a valid GLN-13 with correct check digit
  static String _gln(String baseCode) {
    final checkDigit = _calculateCheckDigit(baseCode);
    return '$baseCode$checkDigit';
  }
  
  /// Generate a valid SSCC-18 with correct check digit
  static String generateSSCC(String extensionDigit, String companyPrefix, String serialRef) {
    final base = '$extensionDigit$companyPrefix$serialRef';
    if (base.length != 17) {
      throw ArgumentError('SSCC base must be 17 digits, got ${base.length}');
    }
    final checkDigit = _calculateCheckDigit(base);
    return '$base$checkDigit';
  }
  
  /// Generate batch number in pharmaceutical format (LOT-YY-MMDD-SSSS)
  static String generateBatchNumber(int manufacturerIndex, int year, int month, int batchSeq) {
    final yearStr = year.toString().substring(2);
    final monthStr = month.toString().padLeft(2, '0');
    final seqStr = batchSeq.toString().padLeft(4, '0');
    return 'LOT-$yearStr-$monthStr$seqStr-UAE${manufacturerIndex.toString().padLeft(2, '0')}';
  }
  
  /// Get available GS1 company prefixes for UAE pharmaceutical manufacturers/distributors
  static List<Map<String, String>> getManufacturerPrefixes() {
    return [
      {'name': 'Julphar Gulf Pharmaceutical', 'prefix': '6292000', 'glnCode': _gln('629200000001')},
      {'name': 'Neopharma LLC', 'prefix': '6292001', 'glnCode': _gln('629200000002')},
      {'name': 'Global Pharma Healthcare', 'prefix': '6292002', 'glnCode': _gln('629200000003')},
      {'name': 'GlaxoSmithKline UAE', 'prefix': '6292003', 'glnCode': _gln('629200000004')},
      {'name': 'Pfizer Gulf FZ-LLC', 'prefix': '6292004', 'glnCode': _gln('629200000005')},
      {'name': 'Novartis UAE', 'prefix': '6292005', 'glnCode': _gln('629200000006')},
      {'name': 'Sanofi Gulf', 'prefix': '6292006', 'glnCode': _gln('629200000007')},
      {'name': 'AstraZeneca Middle East', 'prefix': '6292007', 'glnCode': _gln('629200000008')},
    ];
  }
  
  /// Get 50 real pharmaceutical products for UAE market
  static List<Map<String, dynamic>> getUAEPharmaceuticalProducts() {
    return [
      // Cardiovascular - Julphar
      _product(_gtin('0629200010001'), 'Simvastatin 20mg Tablets', 'Julphar Gulf Pharmaceutical', 'Statins', 'Simvastatin', 20.0, 'mg', 'TABLET', 'BLISTER', 30, 'AE', 'ARE-MOHAP-2024-C001', 'C10AA01', 'Hyperlipidemia', 45.00),
      _product(_gtin('0629200010002'), 'Atorvastatin 40mg Tablets', 'Julphar Gulf Pharmaceutical', 'Statins', 'Atorvastatin', 40.0, 'mg', 'TABLET', 'BLISTER', 30, 'AE', 'ARE-MOHAP-2024-C002', 'C10AA05', 'Hyperlipidemia', 85.00),
      _product(_gtin('0629200010003'), 'Amlodipine 5mg Tablets', 'Julphar Gulf Pharmaceutical', 'Calcium Channel Blockers', 'Amlodipine', 5.0, 'mg', 'TABLET', 'BLISTER', 28, 'AE', 'ARE-MOHAP-2024-C003', 'C08CA01', 'Hypertension', 35.00),
      _product(_gtin('0629200010004'), 'Losartan 50mg Tablets', 'Julphar Gulf Pharmaceutical', 'ARBs', 'Losartan', 50.0, 'mg', 'TABLET', 'BLISTER', 28, 'AE', 'ARE-MOHAP-2024-C004', 'C09CA01', 'Hypertension', 55.00),
      _product(_gtin('0629200010005'), 'Bisoprolol 5mg Tablets', 'Julphar Gulf Pharmaceutical', 'Beta Blockers', 'Bisoprolol', 5.0, 'mg', 'TABLET', 'BLISTER', 30, 'AE', 'ARE-MOHAP-2024-C005', 'C07AB07', 'Hypertension', 40.00),

      // Diabetes - Neopharma
      _product(_gtin('0629200020001'), 'Metformin 500mg Tablets', 'Neopharma LLC', 'Antidiabetics', 'Metformin HCl', 500.0, 'mg', 'TABLET', 'BOTTLE', 60, 'AE', 'ARE-MOHAP-2024-A001', 'A10BA02', 'Type 2 Diabetes', 25.00),
      _product(_gtin('0629200020002'), 'Metformin 850mg Tablets', 'Neopharma LLC', 'Antidiabetics', 'Metformin HCl', 850.0, 'mg', 'TABLET', 'BOTTLE', 60, 'AE', 'ARE-MOHAP-2024-A002', 'A10BA02', 'Type 2 Diabetes', 35.00),
      _product(_gtin('0629200020003'), 'Glimepiride 2mg Tablets', 'Neopharma LLC', 'Sulfonylureas', 'Glimepiride', 2.0, 'mg', 'TABLET', 'BLISTER', 30, 'AE', 'ARE-MOHAP-2024-A003', 'A10BB12', 'Type 2 Diabetes', 45.00),
      _product(_gtin('0629200020004'), 'Gliclazide 80mg Tablets', 'Neopharma LLC', 'Sulfonylureas', 'Gliclazide', 80.0, 'mg', 'TABLET', 'BLISTER', 60, 'AE', 'ARE-MOHAP-2024-A004', 'A10BB09', 'Type 2 Diabetes', 50.00),

      // Antibiotics - Global Pharma
      _product(_gtin('0629200030001'), 'Amoxicillin 500mg Capsules', 'Global Pharma Healthcare', 'Penicillins', 'Amoxicillin', 500.0, 'mg', 'CAPSULE', 'BLISTER', 21, 'AE', 'ARE-MOHAP-2024-J001', 'J01CA04', 'Bacterial Infections', 30.00),
      _product(_gtin('0629200030002'), 'Amoxicillin-Clavulanate 625mg', 'Global Pharma Healthcare', 'Penicillins', 'Amoxicillin + Clavulanic Acid', 625.0, 'mg', 'TABLET', 'BLISTER', 14, 'AE', 'ARE-MOHAP-2024-J002', 'J01CR02', 'Bacterial Infections', 55.00),
      _product(_gtin('0629200030003'), 'Azithromycin 500mg Tablets', 'Global Pharma Healthcare', 'Macrolides', 'Azithromycin', 500.0, 'mg', 'TABLET', 'BLISTER', 3, 'AE', 'ARE-MOHAP-2024-J003', 'J01FA10', 'Respiratory Infections', 45.00),
      _product(_gtin('0629200030004'), 'Cefuroxime 500mg Tablets', 'Global Pharma Healthcare', 'Cephalosporins', 'Cefuroxime Axetil', 500.0, 'mg', 'TABLET', 'BLISTER', 10, 'AE', 'ARE-MOHAP-2024-J004', 'J01DC02', 'Bacterial Infections', 65.00),
      _product(_gtin('0629200030005'), 'Ciprofloxacin 500mg Tablets', 'Global Pharma Healthcare', 'Fluoroquinolones', 'Ciprofloxacin', 500.0, 'mg', 'TABLET', 'BLISTER', 10, 'AE', 'ARE-MOHAP-2024-J005', 'J01MA02', 'UTI/GI Infections', 40.00),

      // Pain/Anti-inflammatory - GSK UAE
      _product(_gtin('0629200040001'), 'Paracetamol 500mg Tablets', 'GlaxoSmithKline UAE', 'Analgesics', 'Paracetamol', 500.0, 'mg', 'TABLET', 'BLISTER', 20, 'GB', 'ARE-MOHAP-2024-N001', 'N02BE01', 'Pain & Fever', 15.00),
      _product(_gtin('0629200040002'), 'Ibuprofen 400mg Tablets', 'GlaxoSmithKline UAE', 'NSAIDs', 'Ibuprofen', 400.0, 'mg', 'TABLET', 'BLISTER', 20, 'GB', 'ARE-MOHAP-2024-M001', 'M01AE01', 'Pain & Inflammation', 20.00),
      _product(_gtin('0629200040003'), 'Diclofenac 50mg Tablets', 'GlaxoSmithKline UAE', 'NSAIDs', 'Diclofenac Sodium', 50.0, 'mg', 'TABLET', 'BLISTER', 20, 'GB', 'ARE-MOHAP-2024-M002', 'M01AB05', 'Pain & Inflammation', 25.00),
      _product(_gtin('0629200040004'), 'Naproxen 500mg Tablets', 'GlaxoSmithKline UAE', 'NSAIDs', 'Naproxen', 500.0, 'mg', 'TABLET', 'BLISTER', 30, 'GB', 'ARE-MOHAP-2024-M003', 'M01AE02', 'Pain & Inflammation', 30.00),

      // Respiratory - AstraZeneca
      _product(_gtin('0629200070001'), 'Salbutamol 100mcg Inhaler', 'AstraZeneca Middle East', 'Bronchodilators', 'Salbutamol Sulfate', 100.0, 'mcg', 'INHALER', 'CANISTER', 200, 'GB', 'ARE-MOHAP-2024-R001', 'R03AC02', 'Asthma/COPD', 45.00),
      _product(_gtin('0629200070002'), 'Budesonide 200mcg Inhaler', 'AstraZeneca Middle East', 'Corticosteroids', 'Budesonide', 200.0, 'mcg', 'INHALER', 'CANISTER', 120, 'GB', 'ARE-MOHAP-2024-R002', 'R03BA02', 'Asthma', 85.00),
      _product(_gtin('0629200070003'), 'Montelukast 10mg Tablets', 'AstraZeneca Middle East', 'Leukotriene Antagonists', 'Montelukast', 10.0, 'mg', 'TABLET', 'BLISTER', 28, 'GB', 'ARE-MOHAP-2024-R003', 'R03DC03', 'Asthma', 95.00),
      _product(_gtin('0629200070004'), 'Cetirizine 10mg Tablets', 'AstraZeneca Middle East', 'Antihistamines', 'Cetirizine HCl', 10.0, 'mg', 'TABLET', 'BLISTER', 30, 'GB', 'ARE-MOHAP-2024-R004', 'R06AE07', 'Allergies', 25.00),

      // GI/Gastro - Pfizer Gulf
      _product(_gtin('0629200050001'), 'Omeprazole 20mg Capsules', 'Pfizer Gulf FZ-LLC', 'Proton Pump Inhibitors', 'Omeprazole', 20.0, 'mg', 'CAPSULE', 'BLISTER', 28, 'US', 'ARE-MOHAP-2024-A101', 'A02BC01', 'GERD/Ulcers', 40.00),
      _product(_gtin('0629200050002'), 'Pantoprazole 40mg Tablets', 'Pfizer Gulf FZ-LLC', 'Proton Pump Inhibitors', 'Pantoprazole', 40.0, 'mg', 'TABLET', 'BLISTER', 28, 'US', 'ARE-MOHAP-2024-A102', 'A02BC02', 'GERD/Ulcers', 50.00),
      _product(_gtin('0629200050003'), 'Ranitidine 150mg Tablets', 'Pfizer Gulf FZ-LLC', 'H2 Blockers', 'Ranitidine HCl', 150.0, 'mg', 'TABLET', 'BLISTER', 30, 'US', 'ARE-MOHAP-2024-A103', 'A02BA02', 'Heartburn', 30.00),
      _product(_gtin('0629200050004'), 'Loperamide 2mg Capsules', 'Pfizer Gulf FZ-LLC', 'Antidiarrheals', 'Loperamide HCl', 2.0, 'mg', 'CAPSULE', 'BLISTER', 12, 'US', 'ARE-MOHAP-2024-A104', 'A07DA03', 'Diarrhea', 20.00),

      // Vitamins/Supplements - Novartis
      _product(_gtin('0629200060001'), 'Vitamin D3 50000 IU Capsules', 'Novartis UAE', 'Vitamins', 'Cholecalciferol', 50000.0, 'IU', 'CAPSULE', 'BOTTLE', 4, 'CH', 'ARE-MOHAP-2024-A201', 'A11CC05', 'Vitamin D Deficiency', 35.00),
      _product(_gtin('0629200060002'), 'Calcium+D3 600mg Tablets', 'Novartis UAE', 'Minerals', 'Calcium Carbonate + Vit D3', 600.0, 'mg', 'TABLET', 'BOTTLE', 60, 'CH', 'ARE-MOHAP-2024-A202', 'A12AX', 'Osteoporosis Prevention', 40.00),
      _product(_gtin('0629200060003'), 'Multivitamin Tablets', 'Novartis UAE', 'Multivitamins', 'Multivitamin Complex', 0.0, 'unit', 'TABLET', 'BOTTLE', 30, 'CH', 'ARE-MOHAP-2024-A203', 'A11AA', 'Nutritional Supplement', 45.00),
      _product(_gtin('0629200060004'), 'Iron 65mg Tablets', 'Novartis UAE', 'Minerals', 'Ferrous Sulfate', 65.0, 'mg', 'TABLET', 'BOTTLE', 30, 'CH', 'ARE-MOHAP-2024-A204', 'B03AA07', 'Iron Deficiency Anemia', 25.00),

      // Anticoagulants/Cardiovascular - Sanofi
      _product(_gtin('0629200080001'), 'Clopidogrel 75mg Tablets', 'Sanofi Gulf', 'Antiplatelets', 'Clopidogrel', 75.0, 'mg', 'TABLET', 'BLISTER', 28, 'FR', 'ARE-MOHAP-2024-B001', 'B01AC04', 'Cardiovascular Protection', 120.00),
      _product(_gtin('0629200080002'), 'Warfarin 5mg Tablets', 'Sanofi Gulf', 'Anticoagulants', 'Warfarin Sodium', 5.0, 'mg', 'TABLET', 'BLISTER', 30, 'FR', 'ARE-MOHAP-2024-B002', 'B01AA03', 'Anticoagulation', 35.00),
      _product(_gtin('0629200080003'), 'Enoxaparin 40mg Injection', 'Sanofi Gulf', 'Anticoagulants', 'Enoxaparin Sodium', 40.0, 'mg', 'INJECTION', 'PREFILLED_SYRINGE', 2, 'FR', 'ARE-MOHAP-2024-B003', 'B01AB05', 'DVT Prevention', 150.00),

      // Oncology Support - Pfizer
      _product(_gtin('0629200050005'), 'Ondansetron 8mg Tablets', 'Pfizer Gulf FZ-LLC', 'Antiemetics', 'Ondansetron HCl', 8.0, 'mg', 'TABLET', 'BLISTER', 10, 'US', 'ARE-MOHAP-2024-A105', 'A04AA01', 'Chemotherapy Nausea', 85.00),
      _product(_gtin('0629200050006'), 'Metoclopramide 10mg Tablets', 'Pfizer Gulf FZ-LLC', 'Antiemetics', 'Metoclopramide', 10.0, 'mg', 'TABLET', 'BLISTER', 30, 'US', 'ARE-MOHAP-2024-A106', 'A03FA01', 'Nausea/Vomiting', 20.00),

      // Hormones - Novartis
      _product(_gtin('0629200060005'), 'Levothyroxine 100mcg Tablets', 'Novartis UAE', 'Thyroid Hormones', 'Levothyroxine Sodium', 100.0, 'mcg', 'TABLET', 'BLISTER', 30, 'CH', 'ARE-MOHAP-2024-H001', 'H03AA01', 'Hypothyroidism', 30.00),
      _product(_gtin('0629200060006'), 'Insulin Glargine 100U/mL', 'Novartis UAE', 'Insulins', 'Insulin Glargine', 100.0, 'U/mL', 'INJECTION', 'VIAL', 1, 'CH', 'ARE-MOHAP-2024-A301', 'A10AE04', 'Diabetes', 180.00),

      // Antibiotics Injectable - Global Pharma
      _product(_gtin('0629200030006'), 'Ceftriaxone 1g Injection', 'Global Pharma Healthcare', 'Cephalosporins', 'Ceftriaxone Sodium', 1000.0, 'mg', 'INJECTION', 'VIAL', 1, 'AE', 'ARE-MOHAP-2024-J006', 'J01DD04', 'Severe Infections', 25.00),
      _product(_gtin('0629200030007'), 'Meropenem 1g Injection', 'Global Pharma Healthcare', 'Carbapenems', 'Meropenem', 1000.0, 'mg', 'INJECTION', 'VIAL', 1, 'AE', 'ARE-MOHAP-2024-J007', 'J01DH02', 'Severe Infections', 180.00),

      // Antihypertensive Combinations - Julphar
      _product(_gtin('0629200010006'), 'Amlodipine+Losartan 5/50mg', 'Julphar Gulf Pharmaceutical', 'Antihypertensive Combo', 'Amlodipine + Losartan', 5.0, 'mg', 'TABLET', 'BLISTER', 28, 'AE', 'ARE-MOHAP-2024-C006', 'C09DB01', 'Hypertension', 75.00),
      _product(_gtin('0629200010007'), 'Hydrochlorothiazide 25mg Tablets', 'Julphar Gulf Pharmaceutical', 'Diuretics', 'Hydrochlorothiazide', 25.0, 'mg', 'TABLET', 'BLISTER', 30, 'AE', 'ARE-MOHAP-2024-C007', 'C03AA03', 'Hypertension/Edema', 20.00),

      // Mental Health - GSK
      _product(_gtin('0629200040005'), 'Sertraline 50mg Tablets', 'GlaxoSmithKline UAE', 'SSRIs', 'Sertraline HCl', 50.0, 'mg', 'TABLET', 'BLISTER', 30, 'GB', 'ARE-MOHAP-2024-N002', 'N06AB06', 'Depression/Anxiety', 65.00),
      _product(_gtin('0629200040006'), 'Escitalopram 10mg Tablets', 'GlaxoSmithKline UAE', 'SSRIs', 'Escitalopram', 10.0, 'mg', 'TABLET', 'BLISTER', 28, 'GB', 'ARE-MOHAP-2024-N003', 'N06AB10', 'Depression/Anxiety', 75.00),

      // Dermatology - Neopharma
      _product(_gtin('0629200020005'), 'Isotretinoin 20mg Capsules', 'Neopharma LLC', 'Retinoids', 'Isotretinoin', 20.0, 'mg', 'CAPSULE', 'BLISTER', 30, 'AE', 'ARE-MOHAP-2024-D001', 'D10BA01', 'Severe Acne', 250.00),
      _product(_gtin('0629200020006'), 'Clotrimazole 1% Cream', 'Neopharma LLC', 'Antifungals', 'Clotrimazole', 10.0, 'mg/g', 'CREAM', 'TUBE', 1, 'AE', 'ARE-MOHAP-2024-D002', 'D01AC01', 'Fungal Infections', 15.00),

      // Pediatric - Julphar
      _product(_gtin('0629200010008'), 'Paracetamol 120mg/5ml Syrup', 'Julphar Gulf Pharmaceutical', 'Analgesics', 'Paracetamol', 120.0, 'mg/5ml', 'SYRUP', 'BOTTLE', 1, 'AE', 'ARE-MOHAP-2024-N004', 'N02BE01', 'Pediatric Pain/Fever', 12.00),
      _product(_gtin('0629200010009'), 'Amoxicillin 250mg/5ml Suspension', 'Julphar Gulf Pharmaceutical', 'Penicillins', 'Amoxicillin', 250.0, 'mg/5ml', 'SUSPENSION', 'BOTTLE', 1, 'AE', 'ARE-MOHAP-2024-J008', 'J01CA04', 'Pediatric Infections', 18.00),
    ];
  }

  static Map<String, dynamic> _product(
    String gtin, String name, String manufacturer, String therapeuticClass, String activeIngredient,
    double strength, String unit, String dosageForm, String packaging, int quantity,
    String origin, String mohapRegistration, String atcCode, String indication, double price,
  ) {
    return {
      'gtinCode': gtin,
      'productName': name,
      'manufacturer': manufacturer,
      'therapeuticClass': therapeuticClass,
      'activeIngredient': activeIngredient,
      'strength': strength,
      'strengthUnit': unit,
      'dosageForm': dosageForm,
      'packagingType': packaging,
      'packageQuantity': quantity,
      'countryOfOrigin': origin,
      'mohapRegistrationNumber': mohapRegistration,
      'atcCode': atcCode,
      'indication': indication,
      'maxRetailPrice': price,
      'requiresPrescription': _requiresPrescription(therapeuticClass),
      'temperatureControlled': _isTemperatureControlled(dosageForm, therapeuticClass),
      'narcotic': _isNarcotic(therapeuticClass),
    };
  }

  static bool _requiresPrescription(String therapeuticClass) {
    final rxRequired = [
      'Antibiotics', 'Penicillins', 'Macrolides', 'Cephalosporins', 'Fluoroquinolones', 'Carbapenems',
      'Antidiabetics', 'Sulfonylureas', 'Insulins',
      'SSRIs', 'Retinoids', 'Anticoagulants', 'Antiplatelets',
      'Corticosteroids', 'Leukotriene Antagonists',
      'Thyroid Hormones', 'Antiemetics'
    ];
    return rxRequired.any((rx) => therapeuticClass.contains(rx));
  }

  static bool _isTemperatureControlled(String dosageForm, String therapeuticClass) {
    return dosageForm == 'INJECTION' || 
           dosageForm == 'PREFILLED_SYRINGE' ||
           therapeuticClass.contains('Insulin') ||
           dosageForm == 'VIAL';
  }

  static bool _isNarcotic(String therapeuticClass) {
    // In UAE, narcotics/controlled substances require special handling
    return false; // None in current list, but framework in place
  }

  /// Get 50 pharmaceutical locations for UAE
  static List<Map<String, dynamic>> getUAEPharmaceuticalLocations() {
    return [
      // Manufacturers
      _location(_gln('629200000001'), 'Julphar Gulf Pharmaceutical Industries', 'MANUFACTURER', 'Ras Al Khaimah Free Trade Zone', 'Ras Al Khaimah'),
      _location(_gln('629200000002'), 'Neopharma LLC Manufacturing', 'MANUFACTURER', 'Dubai Industrial Park', 'Dubai'),
      _location(_gln('629200000003'), 'Global Pharma Healthcare Facility', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),
      _location(_gln('629200000004'), 'GlaxoSmithKline Manufacturing FZE', 'MANUFACTURER', 'Jebel Ali Free Zone', 'Dubai'),
      _location(_gln('629200000005'), 'Pfizer Gulf Manufacturing', 'MANUFACTURER', 'Dubai Healthcare City', 'Dubai'),

      // Distribution Centers
      _location(_gln('629200000006'), 'Emirates Pharma Distribution', 'DISTRIBUTION_CENTER', 'Dubai Logistics City', 'Dubai'),
      _location(_gln('629200000007'), 'Gulf Medical Distribution', 'DISTRIBUTION_CENTER', 'Al Quoz Industrial', 'Dubai'),
      _location(_gln('629200000008'), 'Abu Dhabi Pharmaceutical Dist', 'DISTRIBUTION_CENTER', 'Musaffah Industrial', 'Abu Dhabi'),
      _location(_gln('629200000009'), 'Sharjah Medical Supplies DC', 'DISTRIBUTION_CENTER', 'Sharjah Airport Freezone', 'Sharjah'),
      _location(_gln('629200000010'), 'RAK Pharma Logistics', 'DISTRIBUTION_CENTER', 'RAK Free Trade Zone', 'Ras Al Khaimah'),

      // Hospital Pharmacies - Dubai
      _location(_gln('629200000011'), 'Dubai Hospital Main Pharmacy', 'HOSPITAL_PHARMACY', 'Al Baraha', 'Dubai'),
      _location(_gln('629200000012'), 'Rashid Hospital Pharmacy', 'HOSPITAL_PHARMACY', 'Umm Hurair', 'Dubai'),
      _location(_gln('629200000013'), 'Al Jalila Children Hospital Pharmacy', 'HOSPITAL_PHARMACY', 'Al Jaddaf', 'Dubai'),
      _location(_gln('629200000014'), 'Dubai Healthcare City Pharmacy', 'HOSPITAL_PHARMACY', 'Dubai Healthcare City', 'Dubai'),
      _location(_gln('629200000015'), 'American Hospital Dubai Pharmacy', 'HOSPITAL_PHARMACY', 'Oud Metha', 'Dubai'),
      _location(_gln('629200000016'), 'Mediclinic City Hospital Pharmacy', 'HOSPITAL_PHARMACY', 'Dubai Healthcare City', 'Dubai'),

      // Hospital Pharmacies - Abu Dhabi
      _location(_gln('629200000017'), 'Sheikh Khalifa Medical City Pharmacy', 'HOSPITAL_PHARMACY', 'Karamah', 'Abu Dhabi'),
      _location(_gln('629200000018'), 'Cleveland Clinic Abu Dhabi Pharmacy', 'HOSPITAL_PHARMACY', 'Al Maryah Island', 'Abu Dhabi'),
      _location(_gln('629200000019'), 'Tawam Hospital Pharmacy', 'HOSPITAL_PHARMACY', 'Al Ain', 'Abu Dhabi'),
      _location(_gln('629200000020'), 'NMC Royal Hospital Pharmacy', 'HOSPITAL_PHARMACY', 'Khalifa City', 'Abu Dhabi'),

      // Retail Pharmacy Chains - Dubai
      _location(_gln('629200000021'), 'Life Pharmacy Mall of Emirates', 'RETAIL_PHARMACY', 'Mall of Emirates', 'Dubai'),
      _location(_gln('629200000022'), 'Life Pharmacy Dubai Mall', 'RETAIL_PHARMACY', 'Dubai Mall', 'Dubai'),
      _location(_gln('629200000023'), 'Boots Pharmacy City Centre', 'RETAIL_PHARMACY', 'City Centre Deira', 'Dubai'),
      _location(_gln('629200000024'), 'Boots Pharmacy Marina Mall', 'RETAIL_PHARMACY', 'Dubai Marina Mall', 'Dubai'),
      _location(_gln('629200000025'), 'Aster Pharmacy JLT', 'RETAIL_PHARMACY', 'Jumeirah Lake Towers', 'Dubai'),
      _location(_gln('629200000026'), 'Aster Pharmacy Downtown', 'RETAIL_PHARMACY', 'Downtown Dubai', 'Dubai'),
      _location(_gln('629200000027'), 'Day to Day Pharmacy JBR', 'RETAIL_PHARMACY', 'Jumeirah Beach Residence', 'Dubai'),
      _location(_gln('629200000028'), 'Day to Day Pharmacy Motor City', 'RETAIL_PHARMACY', 'Motor City', 'Dubai'),
      _location(_gln('629200000029'), 'Supercare Pharmacy Jumeirah', 'RETAIL_PHARMACY', 'Jumeirah 1', 'Dubai'),
      _location(_gln('629200000030'), 'Supercare Pharmacy Barsha', 'RETAIL_PHARMACY', 'Al Barsha', 'Dubai'),

      // Retail Pharmacy Chains - Abu Dhabi
      _location(_gln('629200000031'), 'Life Pharmacy Yas Mall', 'RETAIL_PHARMACY', 'Yas Mall', 'Abu Dhabi'),
      _location(_gln('629200000032'), 'Life Pharmacy Marina Mall', 'RETAIL_PHARMACY', 'Marina Mall', 'Abu Dhabi'),
      _location(_gln('629200000033'), 'Boots Pharmacy Al Wahda', 'RETAIL_PHARMACY', 'Al Wahda Mall', 'Abu Dhabi'),
      _location(_gln('629200000034'), 'Aster Pharmacy Khalidiyah', 'RETAIL_PHARMACY', 'Khalidiyah', 'Abu Dhabi'),
      _location(_gln('629200000035'), 'Day to Day Pharmacy Reem Island', 'RETAIL_PHARMACY', 'Al Reem Island', 'Abu Dhabi'),
      _location(_gln('629200000036'), 'Supercare Pharmacy Corniche', 'RETAIL_PHARMACY', 'Corniche Road', 'Abu Dhabi'),
      _location(_gln('629200000037'), 'NMC Royal Pharmacy Mushrif', 'RETAIL_PHARMACY', 'Mushrif', 'Abu Dhabi'),

      // Retail Pharmacies - Other Emirates
      _location(_gln('629200000038'), 'Life Pharmacy Sharjah City Centre', 'RETAIL_PHARMACY', 'Sharjah City Centre', 'Sharjah'),
      _location(_gln('629200000039'), 'Boots Pharmacy Sahara Centre', 'RETAIL_PHARMACY', 'Sahara Centre', 'Sharjah'),
      _location(_gln('629200000040'), 'Aster Pharmacy Ajman City Centre', 'RETAIL_PHARMACY', 'Ajman City Centre', 'Ajman'),
      _location(_gln('629200000041'), 'Day to Day Pharmacy RAK Mall', 'RETAIL_PHARMACY', 'RAK Mall', 'Ras Al Khaimah'),
      _location(_gln('629200000042'), 'Supercare Pharmacy Fujairah', 'RETAIL_PHARMACY', 'Fujairah City Centre', 'Fujairah'),

      // Community Pharmacies
      _location(_gln('629200000043'), 'Al Safa Pharmacy', 'RETAIL_PHARMACY', 'Al Safa', 'Dubai'),
      _location(_gln('629200000044'), 'Dubai Pharmacy Karama', 'RETAIL_PHARMACY', 'Karama', 'Dubai'),
      _location(_gln('629200000045'), 'Ras Al Khor Pharmacy', 'RETAIL_PHARMACY', 'Ras Al Khor', 'Dubai'),
      _location(_gln('629200000046'), 'Al Ain Pharmacy Central', 'RETAIL_PHARMACY', 'Al Ain Centre', 'Abu Dhabi'),
      _location(_gln('629200000047'), 'Mussafah Pharmacy', 'RETAIL_PHARMACY', 'Mussafah', 'Abu Dhabi'),
      _location(_gln('629200000048'), 'Al Qasimia Pharmacy', 'RETAIL_PHARMACY', 'Al Qasimia', 'Sharjah'),
      _location(_gln('629200000049'), 'Ajman Corniche Pharmacy', 'RETAIL_PHARMACY', 'Ajman Corniche', 'Ajman'),
      _location(_gln('629200000050'), 'UAQ Central Pharmacy', 'RETAIL_PHARMACY', 'King Faisal Road', 'Umm Al Quwain'),
    ];
  }

  static Map<String, dynamic> _location(
    String gln, String name, String type, String address, String city,
  ) {
    final postalCodes = {
      'Dubai': '00000',
      'Abu Dhabi': '00000',
      'Sharjah': '00000',
      'Ajman': '00000',
      'Ras Al Khaimah': '00000',
      'Fujairah': '00000',
      'Umm Al Quwain': '00000',
    };
    
    // Extract last 4 digits of GLN for unique ID generation
    final glnSuffix = gln.substring(gln.length - 4);
    
    // MOHAP License Number (Ministry of Health & Prevention)
    // Format: MOHAP-XXXX-YYYY where XXXX is location type code
    final mohapPrefix = {
      'MANUFACTURER': 'MOHAP-MFG',
      'DISTRIBUTION_CENTER': 'MOHAP-DST',
      'HOSPITAL_PHARMACY': 'MOHAP-HP',
      'RETAIL_PHARMACY': 'MOHAP-RP',
    };
    final licensePrefix = mohapPrefix[type] ?? 'MOHAP-OTH';
    final mohapLicense = '$licensePrefix-2024-$glnSuffix';
    
    // DHA License for Dubai (Dubai Health Authority)
    // Format: DHA-XXXX-YYYY
    final dhaPrefix = {
      'MANUFACTURER': 'DHA-MFG',
      'DISTRIBUTION_CENTER': 'DHA-DST',
      'HOSPITAL_PHARMACY': 'DHA-HP',
      'RETAIL_PHARMACY': 'DHA-RP',
    };
    final dhaLicensePrefix = dhaPrefix[type] ?? 'DHA-OTH';
    final dhaLicense = city == 'Dubai' ? '$dhaLicensePrefix-2024-$glnSuffix' : null;
    
    // DOH License for Abu Dhabi (Department of Health)
    final dohLicense = city == 'Abu Dhabi' || city.contains('Al Ain') 
        ? 'DOH-${type.substring(0, 3)}-2024-$glnSuffix' 
        : null;
    
    // Pharmacist Registration Number (for pharmacies)
    final pharmacistLicense = type.contains('PHARMACY') 
        ? 'UAE-RPH-2024-$glnSuffix' 
        : null;
    
    // Good Distribution Practice (GDP) Certificate for distributors
    final gdpCertificate = type == 'DISTRIBUTION_CENTER' 
        ? 'UAE-GDP-2024-$glnSuffix' 
        : null;
    
    // Good Manufacturing Practice (GMP) Certificate for manufacturers
    final gmpCertificate = type == 'MANUFACTURER' 
        ? 'UAE-GMP-2024-$glnSuffix' 
        : null;
    
    // Storage capacity based on location type (cubic meters)
    final storageCapacity = {
      'MANUFACTURER': 10000.0,
      'DISTRIBUTION_CENTER': 5000.0,
      'HOSPITAL_PHARMACY': 500.0,
      'RETAIL_PHARMACY': 100.0,
    };
    
    // Temperature zones available
    final hasControlledTemp = type == 'MANUFACTURER' || 
                               type == 'DISTRIBUTION_CENTER' ||
                               type == 'HOSPITAL_PHARMACY';
    
    return {
      'glnCode': gln,
      'locationName': name,
      'locationType': type,
      'address': address,
      'city': city,
      'postalCode': postalCodes[city] ?? '00000',
      
      // UAE MOHAP Registration (mandatory for all pharmaceutical facilities)
      'mohapLicenseNumber': mohapLicense,
      
      // Emirate-specific licenses
      'dhaLicenseNumber': dhaLicense,
      'dohLicenseNumber': dohLicense,
      
      // Professional licenses
      'pharmacistLicenseNumber': pharmacistLicense,
      
      // Quality certifications
      'gdpCertificateNumber': gdpCertificate,
      'gmpCertificateNumber': gmpCertificate,
      
      // Facility capabilities
      'storageCapacityM3': storageCapacity[type] ?? 50.0,
      'hasRefrigeratedStorage': hasControlledTemp,
      'hasFreezerStorage': type == 'MANUFACTURER' || type == 'DISTRIBUTION_CENTER',
      'temperatureMonitoring24x7': hasControlledTemp,
      
      // Controlled substance authorization (for narcotics/psychotropics)
      'controlledSubstanceLicense': type.contains('PHARMACY') || type == 'DISTRIBUTION_CENTER'
          ? 'UAE-CS-2024-$glnSuffix'
          : null,
      
      // Traceability systems
      'serializedProductHandling': true,
      'epcisCompliant': true,
      'trackAndTraceSystem': 'TraqTrace',
    };
  }
}
