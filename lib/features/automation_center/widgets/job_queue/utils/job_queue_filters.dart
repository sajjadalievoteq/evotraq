class JobQueueFilters {
  const JobQueueFilters._();

  static List<Map<String, dynamic>> byStatus(
    List<Map<String, dynamic>> jobs,
    String status,
  ) {
    if (status == 'ALL') return jobs;
    return jobs.where((j) => '${j['status']}'.toUpperCase() == status).toList();
  }

  static List<Map<String, dynamic>> byJobType(
    List<Map<String, dynamic>> history,
    String jobType,
  ) {
    if (jobType == 'ALL') return history;
    return history.where((j) => '${j['jobType']}' == jobType).toList();
  }
}