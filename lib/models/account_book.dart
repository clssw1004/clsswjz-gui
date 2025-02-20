/// 账本模型
class AccountBook {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? currency;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountBook({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.currency,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  AccountBook copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? currency,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountBook(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'currency': currency,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountBook.fromJson(Map<String, dynamic> json) {
    return AccountBook(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      currency: json['currency'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
} 