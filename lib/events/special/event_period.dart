import '../../enums/operate_type.dart';

/// 经期记录变动事件
class PeriodRecordChangedEvent {
  final OperateType operateType;
  const PeriodRecordChangedEvent(this.operateType);
}
