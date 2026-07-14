/// Status of a single metric group's independent load lifecycle, so one
/// failing/empty metric doesn't have to blank an entire dashboard tab.
enum LoadStatus { loading, success, empty, error }

/// Small value holder pairing a [LoadStatus] with the data (on success) or
/// error message (on error) for one metric group.
class LoadState<T> {
  final LoadStatus status;
  final T? data;
  final String? errorMessage;

  const LoadState._(this.status, this.data, this.errorMessage);

  const LoadState.loading() : this._(LoadStatus.loading, null, null);
  const LoadState.success(T data) : this._(LoadStatus.success, data, null);
  const LoadState.empty() : this._(LoadStatus.empty, null, null);
  const LoadState.error(String message) : this._(LoadStatus.error, null, message);

  bool get isLoading => status == LoadStatus.loading;
  bool get isSuccess => status == LoadStatus.success;
  bool get isError => status == LoadStatus.error;
}
