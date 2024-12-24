class OperateResult<T> {
  final bool ok;
  final T? data;
  final String? message;
  final Exception? exception;

  OperateResult({required this.ok, this.data, this.message, this.exception});

  static OperateResult<T> success<T>(T data) {
    return OperateResult(ok: true, data: data, message: 'ok', exception: null);
  }

  static OperateResult<T> fail<T>(String message, Exception? exception) {
    return OperateResult(ok: false, message: message, exception: exception);
  }
}
