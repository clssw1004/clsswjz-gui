import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/tree_select_form_field.dart';
class ActionValueSelector extends StatelessWidget {
  final String field;
  final String value;
  final ValueChanged<String> onChanged;
  final List<AccountCategory> categories;
  final List<UserFundVO> funds;
  final List<AccountShop> shops;
  final List<AccountSymbol> tags;
  final List<AccountSymbol> projects;

  const ActionValueSelector({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    required this.categories,
    required this.funds,
    required this.shops,
    required this.tags,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    switch (field) {
      case 'categoryCode':
        return CommonSelectFormField<AccountCategory>(
          key: ValueKey('act_cat_$value'),
          items: categories,
          displayField: (c) => c.name,
          keyField: (c) => c.code,
          value: value,
          label: '分类',
          allowCreate: false,
          onChanged: (v) { if (v is AccountCategory) onChanged(v.code); },
        );
      case 'fundId':
        return CommonSelectFormField<UserFundVO>(
          key: ValueKey('act_fund_$value'),
          items: funds,
          displayField: (f) => f.name,
          keyField: (f) => f.id,
          value: value,
          label: '账户',
          allowCreate: false,
          onChanged: (v) { if (v is UserFundVO) onChanged(v.id); },
        );
      case 'shopCode':
        return TreeSelectFormField<AccountShop>(
          key: ValueKey('act_shop_$value'),
          roots: TreeBuilder.buildTree(shops,
              getId: (c) => c.id, getParentId: (c) => c.parentId,
              getLastUsedAt: (c) => c.lastAccountItemAt),
          value: value,
          displayField: (s) => s.name,
          idField: (s) => s.code,
          isSelectableCheck: (data) => true,
          label: '商家',
          onChanged: (v) {
            if (v is AccountShop) onChanged(v.code);
          },
        );
      case 'tagCode':
        return CommonSelectFormField<AccountSymbol>(
          key: ValueKey('act_tag_$value'),
          items: tags,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          value: value,
          label: '标签',
          allowCreate: false,
          onChanged: (v) { if (v is AccountSymbol) onChanged(v.code); },
        );
      case 'projectCode':
        return CommonSelectFormField<AccountSymbol>(
          key: ValueKey('act_proj_$value'),
          items: projects,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          value: value,
          label: '项目',
          allowCreate: false,
          onChanged: (v) { if (v is AccountSymbol) onChanged(v.code); },
        );
      default:
        return TextField(
          decoration: const InputDecoration(
            labelText: '值',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          controller: TextEditingController(text: value),
          onChanged: onChanged,
        );
    }
  }
}

class FieldLabelChip extends StatelessWidget {
  final String label;
  final Color color;
  const FieldLabelChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
