
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class NoteFilterDTO {
  final String? keyword;
  final List<String>? groupCodes;
  final String? noteType;
  final String? scope;

  const NoteFilterDTO({
    this.keyword,
    this.groupCodes,
    this.noteType,
    this.scope,
  });
}
