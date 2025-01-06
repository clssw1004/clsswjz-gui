/// 同步状态枚举
enum SyncState {
  /// 未同步
  unsynced('unsynced'),

  /// 已同步
  synced('synced'),

  /// 同步中
  syncing('syncing'),

  /// 同步失败
  failed('failed');

  /// 构造函数
  const SyncState(this.value);

  /// 枚举值
  final String value;

  /// 从字符串转换为枚举
  static SyncState? fromString(String? value) {
    if (value == null) return null;
    return SyncState.values.firstWhere(
      (element) => element.value == value,
      orElse: () => unsynced,
    );
  }

  /// 转换为字符串
  String toJson() => value;
}
