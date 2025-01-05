class OperateResult<T> {
  final bool ok;
  final T? data;
  final String? message;
  final Exception? exception;

  OperateResult({required this.ok, this.data, this.message, this.exception});

  static OperateResult<T> success<T>(T? data) {
    return OperateResult(ok: true, data: data, message: 'ok', exception: null);
  }

  static OperateResult<T> successIfNotNull<T>(T? data) {
    return OperateResult(
        ok: data != null, data: data, message: 'ok', exception: null);
  }

  static OperateResult<T> failed<T>() {
    return OperateResult(
        ok: false, data: null, message: 'failed', exception: null);
  }

  static OperateResult<T> fail<T>({Exception? exception}) {
    if (exception != null) {
      print(exception.toString());
    }
    return OperateResult(
        ok: false, message: exception!.toString(), exception: exception);
  }

  static OperateResult<T> failWithMessage<T>(
      {String? message, Exception? exception}) {
    if (exception != null) {
      print(exception.toString());
    }
    return OperateResult(ok: false, message: message, exception: exception);
  }

  static T? getIfOk<T>(OperateResult<T> result) {
    if (result.ok) {
      return result.data;
    }
    return null;
  }
}
