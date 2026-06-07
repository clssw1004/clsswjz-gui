import '../../enums/operate_type.dart';
import '../../models/vo/activity_definition_vo.dart';

class ActivityDefinitionChangedEvent {
  final ActivityDefinitionVO definition;
  final OperateType operateType;
  const ActivityDefinitionChangedEvent(this.operateType, this.definition);
}
