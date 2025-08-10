
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class NoteFilterDTO {
  final String? keyword;
  final List<String>? groupCodes;

  NoteFilterDTO(this.keyword, this.groupCodes);
}
