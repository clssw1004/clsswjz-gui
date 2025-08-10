/// 附件筛选条件
class AttachmentFilterDTO {
  /// 业务类型
  final String? businessCode;
  
  /// 业务ID列表
  final List<String>? businessIds;
  
  /// 文件扩展名筛选
  final List<String>? extensions;
  
  /// 内容类型筛选
  final List<String>? contentTypes;
  
  /// 文件大小范围（最小，单位：字节）
  final int? minFileSize;
  
  /// 文件大小范围（最大，单位：字节）
  final int? maxFileSize;
  
  /// 创建时间范围（开始）
  final DateTime? startDate;
  
  /// 创建时间范围（结束）
  final DateTime? endDate;
  
  /// 文件名关键字
  final String? fileNameKeyword;

  const AttachmentFilterDTO({
    this.businessCode,
    this.businessIds,
    this.extensions,
    this.contentTypes,
    this.minFileSize,
    this.maxFileSize,
    this.startDate,
    this.endDate,
    this.fileNameKeyword,
  });

  /// 创建副本并更新指定字段
  AttachmentFilterDTO copyWith({
    String? businessCode,
    List<String>? businessIds,
    List<String>? extensions,
    List<String>? contentTypes,
    int? minFileSize,
    int? maxFileSize,
    DateTime? startDate,
    DateTime? endDate,
    String? fileNameKeyword,
  }) {
    return AttachmentFilterDTO(
      businessCode: businessCode ?? this.businessCode,
      businessIds: businessIds ?? this.businessIds,
      extensions: extensions ?? this.extensions,
      contentTypes: contentTypes ?? this.contentTypes,
      minFileSize: minFileSize ?? this.minFileSize,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fileNameKeyword: fileNameKeyword ?? this.fileNameKeyword,
    );
  }
} 