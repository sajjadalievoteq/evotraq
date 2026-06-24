abstract final class CbvMasterDataApiConsts {
  static const String prefix = '/master-data/cbv';
  static const String vocabulary = '$prefix/vocabulary';
  static const String bizSteps = '$prefix/biz-steps';
  static const String dispositions = '$prefix/dispositions';

  static String bizStepPath(String code) => '$prefix/biz-steps/$code';
  static String dispositionPath(String code) => '$prefix/dispositions/$code';

  static String bizStepEnabledPath(String code) =>
      '$prefix/biz-steps/$code/enabled';
  static String dispositionEnabledPath(String code) =>
      '$prefix/dispositions/$code/enabled';

  static String validDispositionsPath(String bizStepCode) =>
      '$prefix/biz-steps/$bizStepCode/valid-dispositions';

  static String pairPath(String bizStepCode, String dispCode) =>
      '$prefix/biz-steps/$bizStepCode/dispositions/$dispCode';
}
