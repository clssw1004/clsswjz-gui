import 'dart:async';

/// 事件总线，用于在不同组件间传递事件
class EventBus {
  EventBus._internal();

  static final EventBus _instance = EventBus._internal();
  static EventBus get instance => _instance;

  final _streamController = StreamController.broadcast();

  /// 发送事件
  void emit(dynamic event) {
    _streamController.add(event);
  }

  /// 监听事件
  StreamSubscription on<T>(void Function(T event) callback) {
    return _streamController.stream.where((event) => event is T).cast<T>().listen(callback);
  }

  /// 销毁
  void dispose() {
    _streamController.close();
  }
}
