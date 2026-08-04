/// Maps human-readable priority labels to numeric queue priorities.
abstract final class JobQueuePriorityUtils {
  static int fromLabel(String label) {
    switch (label.toUpperCase()) {
      case 'HIGH':
        return 2;
      case 'LOW':
        return 8;
      case 'MEDIUM':
      default:
        return 5;
    }
  }
}
