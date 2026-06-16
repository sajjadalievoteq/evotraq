/// Converts GS1 CBV business-step / disposition values between EPCIS 1.3 (URN)
/// and EPCIS 2.0 (HTTPS URI) forms.
class CbvVocabularyFormatter {
  CbvVocabularyFormatter._();

  static const String cbvUrlPrefix = 'https://ref.gs1.org/cbv/';
  static const String bizStepUrnPrefix = 'urn:epcglobal:cbv:bizstep:';
  static const String dispUrnPrefix = 'urn:epcglobal:cbv:disp:';
  static const String bizStepUrlPrefix = '${cbvUrlPrefix}BizStep-';
  static const String dispUrlPrefix = '${cbvUrlPrefix}Disp-';

  static bool isEpcis20Version(String? version) =>
      version == null || version == '2.0';

  static String shortName(String value) {
    if (value.startsWith(cbvUrlPrefix)) {
      final tail = value.substring(cbvUrlPrefix.length);
      final hyphen = tail.indexOf('-');
      if (hyphen != -1 && hyphen < tail.length - 1) {
        return tail.substring(hyphen + 1);
      }
      return tail;
    }
    if (value.startsWith(bizStepUrnPrefix)) {
      return value.substring(bizStepUrnPrefix.length);
    }
    if (value.startsWith(dispUrnPrefix)) {
      return value.substring(dispUrnPrefix.length);
    }
    return value;
  }

  static String canonicalBizStepUrn(String value) =>
      '$bizStepUrnPrefix${shortName(value)}';

  static String canonicalDispUrn(String value) =>
      '$dispUrnPrefix${shortName(value)}';

  static String formatBizStep(String epcisVersion, String value) {
    final name = shortName(value);
    if (isEpcis20Version(epcisVersion)) {
      return '$bizStepUrlPrefix$name';
    }
    return '$bizStepUrnPrefix$name';
  }

  static String formatDisposition(String epcisVersion, String value) {
    final name = shortName(value);
    if (isEpcis20Version(epcisVersion)) {
      return '$dispUrlPrefix$name';
    }
    return '$dispUrnPrefix$name';
  }

  static List<String> formatBizStepList(
    String epcisVersion,
    List<String> values,
  ) => values.map((v) => formatBizStep(epcisVersion, v)).toList();

  static List<String> formatDispList(
    String epcisVersion,
    List<String> values,
  ) => values.map((v) => formatDisposition(epcisVersion, v)).toList();

  static bool isBizStepCommissioning(String? value) =>
      value != null && shortName(value) == 'commissioning';

  static bool isBizStepName(String? value, String name) =>
      value != null && shortName(value) == name;

  static bool isDispName(String? value, String name) =>
      value != null && shortName(value) == name;

  static bool isValidBizStepFormat(String epcisVersion, String value) {
    if (isEpcis20Version(epcisVersion)) {
      return value.startsWith(bizStepUrlPrefix);
    }
    return value.startsWith(bizStepUrnPrefix);
  }

  static bool isValidDispFormat(String epcisVersion, String value) {
    if (isEpcis20Version(epcisVersion)) {
      return value.startsWith(dispUrlPrefix);
    }
    return value.startsWith(dispUrnPrefix);
  }

  static String bizStepCbvPrefix(String epcisVersion) =>
      isEpcis20Version(epcisVersion) ? bizStepUrlPrefix : bizStepUrnPrefix;

  static String dispCbvPrefix(String epcisVersion) =>
      isEpcis20Version(epcisVersion) ? dispUrlPrefix : dispUrnPrefix;
}
