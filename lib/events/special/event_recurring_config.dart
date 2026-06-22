import '../../enums/operate_type.dart';
import '../../models/vo/recurring_config_vo.dart';

/// 固定收支配置变动事件
class RecurringConfigChangedEvent {
  final RecurringConfigVO config;
  final OperateType operateType;
  const RecurringConfigChangedEvent(this.operateType, this.config);
}
