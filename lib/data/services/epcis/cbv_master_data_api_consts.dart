abstract final class CbvMasterDataApiConsts {
  static const String prefix = '/master-data/cbv';
  static const String bizSteps = '$prefix/biz-steps';
  static const String dispositions = '$prefix/dispositions';

  static String validDispositionsPath(String bizStepCode) =>
      '$prefix/biz-steps/$bizStepCode/valid-dispositions';
}
