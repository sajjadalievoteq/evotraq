abstract final class DisplayDateUtils {
  static String dmy(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String dmHm(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String dmyHm(DateTime dateTime) {
    return '${dmy(dateTime)} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String hms(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
