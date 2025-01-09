/// 导入数据源类型
enum ImportSource {
  /// 薄荷记账
  bohe,
}

/// 导入数据源扩展
extension ImportSourceExtension on ImportSource {
  /// 获取导入数据源名称
  String get name {
    switch (this) {
      case ImportSource.bohe:
        return '薄荷记账';
    }
  }

  /// 获取导入数据源图标
  String get icon {
    switch (this) {
      case ImportSource.bohe:
        return 'assets/images/import/bohe.png';
    }
  }

  /// 获取导入数据源文件类型
  List<String> get fileTypes {
    switch (this) {
      case ImportSource.bohe:
        return ['csv'];
    }
  }
}
