import 'package:clsswjz/models/vo/user_item_vo.dart';

import '../../enums/operate_type.dart';

/// 账目变动事件
class ItemChangedEvent {
  final UserItemVO item;
  final OperateType operateType;
  const ItemChangedEvent(this.operateType, this.item);
}
