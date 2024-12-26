class ApiResponse<T> {
  final bool ok;
  final String? message;
  final T? data;

  ApiResponse({
    required this.ok,
    this.message,
    this.data,
  });
}
