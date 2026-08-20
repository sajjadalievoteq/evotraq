abstract final class PharmaPaths {
  static String base(String sgtinId) => '/identifiers/sgtins/$sgtinId/pharma';
  static String regimes(String id) => '${base(id)}/regimes';
  static String regime(String id, String type) => '${base(id)}/regimes/$type';
  static String emvo(String id) => '${base(id)}/emvo';
  static String emvoLatest(String id) => '${base(id)}/emvo/latest';
  static String emvoInitiate(String id) => '${base(id)}/emvo/initiate';
  static String emvoCommission(String id) => '${base(id)}/emvo/commission';
  static String emvoDecommission(String id) => '${base(id)}/emvo/decommission';
  static String emvoAck(String id) =>
      '/identifiers/sgtins/pharma/emvo/$id/acknowledge';
  static String emvoFail(String id) =>
      '/identifiers/sgtins/pharma/emvo/$id/fail';
  static String emvoRetry(String id) =>
      '/identifiers/sgtins/pharma/emvo/$id/retry';
  static String tatmeen(String id) => '${base(id)}/tatmeen';
  static String tatmeenAccept(String id) =>
      '/identifiers/sgtins/pharma/tatmeen/$id/accept';
  static String tatmeenReject(String id) =>
      '/identifiers/sgtins/pharma/tatmeen/$id/reject';
  static String dscsa(String id) => '${base(id)}/dscsa';
  static String coldChain(String id) => '${base(id)}/cold-chain';
  static String coldChainReading(String id) => '${base(id)}/cold-chain/reading';
  static String duplicates(String id) => '${base(id)}/duplicates';
  static String duplicateResolve(String id) =>
      '/identifiers/sgtins/pharma/duplicates/$id/resolve';
  static String repackaging(String id) => '${base(id)}/repackaging';
  static const repackagingCreate = '/identifiers/sgtins/pharma/repackaging';
  static String alerts(String id) => '${base(id)}/alerts';
  static String alertsOpen(String id) => '${base(id)}/alerts/open';
  static String alertAck(String id) =>
      '/identifiers/sgtins/pharma/alerts/$id/acknowledge';
  static String alertResolve(String id) =>
      '/identifiers/sgtins/pharma/alerts/$id/resolve';
  static String dispatchCommission(String id) =>
      '${base(id)}/dispatch/commission';
  static String dispatchDecommission(String id) =>
      '${base(id)}/dispatch/decommission';
  static String dispatchOwnershipTransfer(String id) =>
      '${base(id)}/dispatch/ownership-transfer';
  static String batches(String id) => '/identifiers/gtins/$id/batches';
  static String batchByLot(String id, String lot) =>
      '/identifiers/gtins/$id/batches/${Uri.encodeComponent(lot)}';
  static String batchById(String id, String batchId) =>
      '/identifiers/gtins/$id/batches/$batchId';
}
