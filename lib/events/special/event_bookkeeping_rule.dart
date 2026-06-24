import '../../enums/operate_type.dart';
import '../../models/vo/bookkeeping_rule_vo.dart';

/// 记账规则变动事件
class BookkeepingRuleChangedEvent {
  final BookkeepingRuleVO rule;
  final OperateType operateType;
  const BookkeepingRuleChangedEvent(this.operateType, this.rule);
}
