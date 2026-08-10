/// Client-side filters for the job-queue panel.
///
/// Before the WebSocket migration the backend filtered these lists server-side (via
/// `GET /jobs/queue?status=` and `GET /jobs/history?jobType=`). Now the full lists are pushed in
/// the live snapshot, so the panel filters them locally. These helpers preserve the previous
/// semantics: `'ALL'` returns everything; a specific value matches the job's own field.
class JobQueueFilters {
  const JobQueueFilters._();

  /// Filter the combined queue list (QUEUED + RUNNING) by the selected status. A status that the
  /// queue never contains (e.g. COMPLETED) yields an empty list, matching the old endpoint.
  static List<Map<String, dynamic>> byStatus(
    List<Map<String, dynamic>> jobs,
    String status,
  ) {
    if (status == 'ALL') return jobs;
    return jobs.where((j) => '${j['status']}'.toUpperCase() == status).toList();
  }

  /// Filter the history list by job type.
  static List<Map<String, dynamic>> byJobType(
    List<Map<String, dynamic>> history,
    String jobType,
  ) {
    if (jobType == 'ALL') return history;
    return history.where((j) => '${j['jobType']}' == jobType).toList();
  }
}
