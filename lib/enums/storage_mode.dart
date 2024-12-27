import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 数据存储方式
enum StorageMode {
  /// 本地存储
  offline,

  /// 私有服务器
  selfHost,
}

StorageMode? string2StorageMode(String? mode) {
  switch (mode) {
    case 'StorageMode.offline':
      return StorageMode.offline;
    case 'StorageMode.selfHost':
      return StorageMode.selfHost;
    default:
      return null;
  }
}

/// 存储模式扩展
extension StorageModeExtension on StorageMode {
  /// 获取显示名称
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case StorageMode.offline:
        return l10n.offlineStorage;
      case StorageMode.selfHost:
        return l10n.selfHostStorage;
    }
  }
}
