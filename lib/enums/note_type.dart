/// 笔记类型枚举
enum NoteType {
  /// 普通笔记
  note('NOTE'),

  /// 待办事项
  todo('TODO'),
  
  /// 债务记录
  debt('DEBT');

  /// 编码
  final String code;

  const NoteType(this.code);

  /// 从编码获取枚举值
  static NoteType fromCode(String code) {
    return NoteType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => NoteType.note,
    );
  }
} 