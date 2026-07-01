import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/account_type.dart';
import '../../enums/operate_type.dart';
import '../../enums/symbol_type.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_relation_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/color_util.dart';
import '../../utils/date_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';

/// 加油记录表单页面（添加/编辑）
class FuelRecordFormPage extends StatefulWidget {
  final String vehicleId;
  final String? recordId;

  const FuelRecordFormPage({
    super.key,
    required this.vehicleId,
    this.recordId,
  });

  @override
  State<FuelRecordFormPage> createState() => _FuelRecordFormPageState();
}

class _FuelRecordFormPageState extends State<FuelRecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _volumeController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _stationController = TextEditingController();
  final _remarkController = TextEditingController();

  String _fuelGrade = '92';
  bool _isFullTank = false;
  bool _isFuelLightOn = false;
  int _refuelTime = DateTime.now().millisecondsSinceEpoch;
  bool _saving = false;

  final _relationProvider = ItemRelationProvider();
  static const _relationCode = 'fuel_record';

  String? _linkedItemId;
  String? _linkedBookId;
  AccountItem? _linkedItem;
  String? _linkedCategoryName;
  String? _linkedDescription;
  double? _linkedAmount;
  String? _linkedType;

  bool get hasLinkedItem => _linkedItemId != null && _linkedBookId != null;

  bool get isCreateMode => widget.recordId == null;

  @override
  void initState() {
    super.initState();
    if (!isCreateMode) {
      _loadRecord();
    }
  }

  /// 失去焦点时自动计算：填二算一
  void _recalculate() {
    final volume = double.tryParse(_volumeController.text);
    final unitPrice = double.tryParse(_unitPriceController.text);
    final totalAmount = double.tryParse(_totalAmountController.text);

    if (volume != null && unitPrice != null && totalAmount == null) {
      _totalAmountController.text = (volume * unitPrice).toStringAsFixed(2);
    } else if (volume != null && totalAmount != null && unitPrice == null) {
      _unitPriceController.text = (totalAmount / volume).toStringAsFixed(2);
    } else if (unitPrice != null && totalAmount != null && volume == null) {
      if (unitPrice > 0) {
        _volumeController.text = (totalAmount / unitPrice).toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _volumeController.dispose();
    _unitPriceController.dispose();
    _totalAmountController.dispose();
    _stationController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _loadRecord() async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.getFuelRecord(
      userId,
      widget.recordId!,
    );
    if (result.ok && result.data != null && mounted) {
      final record = result.data!;
      setState(() {
        _mileageController.text = record.mileage.toString();
        _volumeController.text = record.volume.toStringAsFixed(2);
        _unitPriceController.text = record.unitPrice.toStringAsFixed(2);
        _totalAmountController.text = record.totalAmount.toStringAsFixed(2);
        _fuelGrade = record.fuelGrade;
        _isFullTank = record.isFullTank == 1;
        _isFuelLightOn = record.isFuelLightOn == 1;
        _stationController.text = record.station ?? '';
        _remarkController.text = record.remark ?? '';
        _refuelTime = record.refuelTime;
      });
      // 从关联表加载已关联账目
      _loadExistingRelation();
    }
  }

  Future<void> _loadExistingRelation() async {
    if (widget.recordId == null) return;
    final relations = await _relationProvider.getSourceRelations(
      _relationCode,
      widget.recordId!,
    );
    if (relations.isNotEmpty && mounted) {
      final rel = relations.first;
      setState(() {
        _linkedItemId = rel.itemId;
        _linkedBookId = rel.accountBookId;
      });
      _loadLinkedItemDisplay(rel.itemId);
    }
  }

  Future<void> _loadLinkedItemDisplay(String itemId) async {
    final item = await DaoManager.itemDao.findById(itemId);
    if (item == null || !mounted) return;

    String? categoryName;
    if (item.categoryCode != null) {
      final category = await DaoManager.categoryDao.findByBookAndCode(
        item.accountBookId,
        item.categoryCode!,
      );
      categoryName = category?.name;
    }

    if (mounted) {
      setState(() {
        _linkedItem = item;
        _linkedCategoryName = categoryName;
        _linkedDescription = item.description;
        _linkedAmount = item.amount;
        _linkedType = item.type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final refuelDate = DateTime.fromMillisecondsSinceEpoch(_refuelTime);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(isCreateMode ? '添加加油记录' : '编辑加油记录'),
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 加油时间
            Text(
              '加油时间',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(refuelDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 里程表读数
            CommonTextFormField(
              controller: _mileageController,
              labelText: '里程表读数',
              hintText: '请输入里程数',
              required: true,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.speed,
            ),
            const SizedBox(height: 16),

            // 费用计算：单价 × 油量 = 总价
            Container(
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.calculate_outlined,
                            size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 5),
                        Text(
                          '费用计算',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 单价
                        Expanded(
                          child: Focus(
                            onFocusChange: (focused) {
                              if (!focused) _recalculate();
                            },
                            child: TextFormField(
                              controller: _unitPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                label: const Text('单价',
                                    style: TextStyle(fontSize: 13)),
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.25)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                floatingLabelStyle: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.12)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorScheme.surface,
                              ),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Spacer(),
                              Text(
                                '×',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        // 加油量
                        Expanded(
                          child: Focus(
                            onFocusChange: (focused) {
                              if (!focused) _recalculate();
                            },
                            child: TextFormField(
                              controller: _volumeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                label: const Text('油量',
                                    style: TextStyle(fontSize: 13)),
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.25)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                floatingLabelStyle: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.12)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorScheme.surface,
                              ),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Spacer(),
                              Text(
                                '=',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        // 总价
                        Expanded(
                          child: Focus(
                            onFocusChange: (focused) {
                              if (!focused) _recalculate();
                            },
                            child: TextFormField(
                              controller: _totalAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                label: const Text('总价',
                                    style: TextStyle(fontSize: 13)),
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.25)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                floatingLabelStyle: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.12)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorScheme.surface,
                              ),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 油品
            Text(
              '油品',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _fuelGrade,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: '92', child: Text('92#')),
                DropdownMenuItem(value: '95', child: Text('95#')),
                DropdownMenuItem(value: '98', child: Text('98#')),
                DropdownMenuItem(value: '0', child: Text('0#柴油')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _fuelGrade = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // 是否跳枪
            SwitchListTile(
              title: const Text('是否跳枪'),
              value: _isFullTank,
              onChanged: (value) {
                setState(() {
                  _isFullTank = value;
                });
              },
              secondary: Icon(
                _isFullTank ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _isFullTank ? colorScheme.primary : colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),

            // 油灯是否亮起
            SwitchListTile(
              title: const Text('油灯是否亮起'),
              value: _isFuelLightOn,
              onChanged: (value) {
                setState(() {
                  _isFuelLightOn = value;
                });
              },
              secondary: Icon(
                _isFuelLightOn ? Icons.wb_twilight : Icons.lightbulb_outline,
                color: _isFuelLightOn ? Colors.orange : colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),

            // 加油站
            CommonTextFormField(
              controller: _stationController,
              labelText: '加油站',
              hintText: '可选',
              prefixIcon: Icons.store,
            ),
            const SizedBox(height: 16),

            // 备注
            CommonTextFormField(
              controller: _remarkController,
              labelText: '备注',
              hintText: '可选',
              maxLines: 3,
            ),
            const SizedBox(height: 8),

            // 关联账目（始终可见）
            _buildRelationSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.link, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                '关联账目',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showItemSearchDialog,
                icon: Icon(
                  hasLinkedItem ? Icons.swap_horiz : Icons.add,
                  size: 16,
                ),
                label: Text(hasLinkedItem ? '更换' : '新增'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: colorScheme.primary,
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (hasLinkedItem) _buildLinkedItemCard(colorScheme),
      ],
    );
  }

  Widget _buildLinkedItemCard(ColorScheme colorScheme) {
    if (_linkedType == null) return const SizedBox.shrink();

    final isIncome = _linkedType == 'INCOME';
    final sign = isIncome ? '+' : '-';
    final amountColor = ColorUtil.getAmountColor(_linkedType);

    return Dismissible(
      key: const ValueKey('linked_item'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.error,
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      onDismissed: (_) {
        setState(() {
          _linkedItemId = null;
          _linkedBookId = null;
          _linkedItem = null;
          _linkedCategoryName = null;
          _linkedDescription = null;
          _linkedAmount = null;
          _linkedType = null;
        });
      },
      child: GestureDetector(
        onTap: _openLinkedItemDetail,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.06),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        amountColor,
                        amountColor.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _linkedCategoryName ?? '未分类',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (_linkedDescription != null &&
                            _linkedDescription!.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            _linkedDescription!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '$sign${(_linkedAmount ?? 0).abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showItemSearchDialog() async {
    final userId = AppConfigManager.instance.userId;
    final maxHeight = MediaQuery.of(context).size.height * 0.66;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _ItemSearchSheet(
          userId: userId,
          vehicleId: widget.vehicleId,
          totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
          unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
          volume: double.tryParse(_volumeController.text) ?? 0,
          fuelGrade: _fuelGrade,
          isFullTank: _isFullTank,
          isFuelLightOn: _isFuelLightOn,
          refuelTime: _refuelTime,
          isCreateMode: isCreateMode,
          currentRecordId: widget.recordId,
        ),
      ),
    );

    if (result != null && mounted) {
      // result format: "itemId|bookId"
      final parts = result.split('|');
      if (parts.length == 2) {
        setState(() {
          _linkedItemId = parts[0];
          _linkedBookId = parts[1];
        });
        _loadLinkedItemDisplay(parts[0]);
      }
    }
  }

  Future<void> _openLinkedItemDetail() async {
    if (_linkedItem == null || _linkedBookId == null) return;
    final userId = AppConfigManager.instance.userId;
    final bookResult =
        await DriverFactory.driver.getBook(userId, _linkedBookId!);
    if (!mounted || !bookResult.ok || bookResult.data == null) return;
    final userItem = UserItemVO.fromAccountItem(
      item: _linkedItem!,
      categoryName: _linkedCategoryName,
    );
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppRoutes.itemEdit,
      arguments: [
        BookMetaVO(bookInfo: bookResult.data!),
        userItem,
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.fromMillisecondsSinceEpoch(_refuelTime);

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null && mounted) {
        setState(() {
          _refuelTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ).millisecondsSinceEpoch;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final mileageText = _mileageController.text.trim();
    if (mileageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入里程表读数')),
      );
      return;
    }

    final mileage = int.tryParse(mileageText);
    if (mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('里程表读数格式不正确')),
      );
      return;
    }

    final volumeText = _volumeController.text.trim();
    final unitPriceText = _unitPriceController.text.trim();
    final totalAmountText = _totalAmountController.text.trim();

    if (volumeText.isEmpty ||
        unitPriceText.isEmpty ||
        totalAmountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写加油量、单价和总价中的至少两项')),
      );
      return;
    }

    final volume = double.tryParse(volumeText);
    final unitPrice = double.tryParse(unitPriceText);
    final totalAmount = double.tryParse(totalAmountText);

    if (volume == null || unitPrice == null || totalAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金额或数量格式不正确')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final userId = AppConfigManager.instance.userId;

      if (isCreateMode) {
        final result = await DriverFactory.driver.createFuelRecord(
          userId,
          vehicleId: widget.vehicleId,
          mileage: mileage,
          energyType: _fuelGrade == '0' ? 'diesel' : 'gasoline',
          fuelGrade: _fuelGrade,
          volume: volume,
          unitPrice: unitPrice,
          totalAmount: totalAmount,
          isFullTank: _isFullTank,
          isFuelLightOn: _isFuelLightOn ? 1 : 0,
          station: _stationController.text.trim().isEmpty
              ? null
              : _stationController.text.trim(),
          remark: _remarkController.text.trim().isEmpty
              ? null
              : _remarkController.text.trim(),
          refuelTime: _refuelTime,
        );

        if (result.ok && mounted) {
          // 创建关联
          if (hasLinkedItem) {
            await _relationProvider.createRelation(
              itemId: _linkedItemId!,
              accountBookId: _linkedBookId!,
              relationCode: _relationCode,
              relationId: result.data!,
            );
          }
          if (mounted) Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '保存失败')),
          );
        }
      } else {
        final result = await DriverFactory.driver.updateFuelRecord(
          userId,
          widget.recordId!,
          mileage: mileage,
          energyType: _fuelGrade == '0' ? 'diesel' : 'gasoline',
          fuelGrade: _fuelGrade,
          volume: volume,
          unitPrice: unitPrice,
          totalAmount: totalAmount,
          isFullTank: _isFullTank,
          isFuelLightOn: _isFuelLightOn ? 1 : 0,
          station: _stationController.text.trim().isEmpty
              ? null
              : _stationController.text.trim(),
          remark: _remarkController.text.trim().isEmpty
              ? null
              : _remarkController.text.trim(),
          refuelTime: _refuelTime,
        );

        if (result.ok && mounted) {
          // 同步关联表
          final existing = await _relationProvider.getSourceRelations(
            _relationCode,
            widget.recordId!,
          );
          final oldItemId = existing.isNotEmpty ? existing.first.itemId : null;

          if (hasLinkedItem && oldItemId != _linkedItemId) {
            // 更换关联：先删旧的，再建新的
            if (oldItemId != null) {
              await _relationProvider.deleteRelation(
                relationId: existing.first.id,
                itemId: oldItemId,
                relationCode: _relationCode,
                sourceId: widget.recordId!,
              );
            }
            await _relationProvider.createRelation(
              itemId: _linkedItemId!,
              accountBookId: _linkedBookId!,
              relationCode: _relationCode,
              relationId: widget.recordId!,
            );
          } else if (!hasLinkedItem && oldItemId != null) {
            // 移除关联
            await _relationProvider.deleteRelation(
              relationId: existing.first.id,
              itemId: oldItemId,
              relationCode: _relationCode,
              sourceId: widget.recordId!,
            );
          }
          if (mounted) Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '保存失败')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

/// 单选框选账目
class _ItemSearchSheet extends StatefulWidget {
  final String userId;
  final String vehicleId;
  final double totalAmount;
  final double unitPrice;
  final double volume;
  final String fuelGrade;
  final bool isFullTank;
  final bool isFuelLightOn;
  final int refuelTime;
  final bool isCreateMode;
  final String? currentRecordId;

  const _ItemSearchSheet({
    required this.userId,
    required this.vehicleId,
    required this.totalAmount,
    required this.unitPrice,
    required this.volume,
    required this.fuelGrade,
    required this.isFullTank,
    required this.isFuelLightOn,
    required this.refuelTime,
    required this.isCreateMode,
    this.currentRecordId,
  });

  @override
  State<_ItemSearchSheet> createState() => _ItemSearchSheetState();
}

class _ItemSearchSheetState extends State<_ItemSearchSheet> {
  final _searchController = TextEditingController();
  List<UserItemVO> _items = [];
  bool _searching = false;
  List<UserBookVO> _books = [];
  String? _selectedBookId;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final result = await DriverFactory.driver.listBooksByUser(widget.userId);
    if (result.ok && result.data != null && mounted) {
      final defaultBookId = AppConfigManager.instance.defaultBookId;
      String? selectedId;
      if (defaultBookId != null &&
          result.data!.any((b) => b.id == defaultBookId)) {
        selectedId = defaultBookId;
      } else if (result.data!.isNotEmpty) {
        selectedId = result.data!.first.id;
      }
      setState(() {
        _books = result.data!;
        _selectedBookId = selectedId;
      });
      _search();
    }
  }

  Future<void> _handleCreateItem() async {
    if (_selectedBookId == null) return;
    final book = _books.firstWhere((b) => b.id == _selectedBookId);
    final bookMeta = BookMetaVO(bookInfo: book);
    final userId = AppConfigManager.instance.userId;

    // 构建描述：标号最前，表情符号拼接
    final descParts = <String>[
      '${widget.fuelGrade}号汽油',
      '${widget.unitPrice.toStringAsFixed(2)}元/L*${widget.volume.toStringAsFixed(2)}L',
    ];
    if (widget.isFuelLightOn) descParts.add('亮灯');
    if (widget.isFullTank) descParts.add('跳枪');
    final description = descParts.join(' | ');

    // 格式化加油日期时间
    final refuelDt = DateTime.fromMillisecondsSinceEpoch(widget.refuelTime);
    final accountDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(refuelDt);

    // 构建预填账目
    final preFilledItem = UserItemVO(
      id: '',
      amount: widget.totalAmount,
      description: description,
      type: AccountItemType.expense.code,
      accountDate: accountDate,
      accountBookId: _selectedBookId!,
      fundId: bookMeta.defaultFundId,
      createdBy: userId,
      updatedBy: userId,
      createdAt: DateUtil.now(),
      updatedAt: DateUtil.now(),
      createdAtString: DateTime.now().toString(),
      updatedAtString: DateTime.now().toString(),
    );

    // 查询最近一条存在关联账目的加油记录（新建/编辑都执行）
    // 编辑模式排除当前记录自身
    try {
      final records = await DaoManager.fuelRecordDao.findByVehicleId(
        widget.vehicleId,
        limit: 20,
      );
      for (final record in records) {
        // 编辑模式：跳过当前记录
        if (!widget.isCreateMode &&
            widget.currentRecordId != null &&
            widget.currentRecordId == record.id) {
          continue;
        }
        // 查 ItemRelation 表
        final relations = await DaoManager.itemRelationDao.findByRelation(
          'fuel_record',
          record.id,
        );
        if (relations.isEmpty) continue;
        final rel = relations.first;
        if (rel.accountBookId != _selectedBookId) continue;
        // 找到最近一条有关联的记录
        final lastItem = await DaoManager.itemDao.findById(rel.itemId);
        if (lastItem != null) {
          preFilledItem.categoryCode = lastItem.categoryCode;
          preFilledItem.shopCode = lastItem.shopCode;
          if (lastItem.tagCode != null) {
            final tag = await DaoManager.symbolDao
                .findByBookAndCode(preFilledItem.accountBookId, SymbolType.tag.code, lastItem.tagCode!);
            if (tag != null) preFilledItem.addTag(tag);
          }
          preFilledItem.projectCode = lastItem.projectCode;
        }
        break;
      }
    } catch (_) {
      // 静默失败，不影响创建
    }

    if (!mounted) return;
    // 监听 ItemChangedEvent 获取新建账目 ID
    final completer = Completer<String>();
    StreamSubscription? sub;
    sub = EventBus.instance.on<ItemChangedEvent>((event) {
      if (event.operateType == OperateType.create && !completer.isCompleted) {
        completer.complete(event.item.id);
      }
    });

    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.itemAdd,
      arguments: [bookMeta, preFilledItem],
    );

    await sub.cancel();

    if (result == true && mounted) {
      try {
        final newItemId =
            await completer.future.timeout(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, '$newItemId|$_selectedBookId');
        }
      } catch (_) {
        if (mounted) _search();
      }
    } else if (mounted) {
      _search();
    }
  }

  Future<void> _search() async {
    if (_selectedBookId == null) {
      if (mounted) setState(() => _searching = false);
      return;
    }
    setState(() => _searching = true);
    try {
      final result = await DriverFactory.driver.listItemsByBook(
        widget.userId,
        _selectedBookId!,
        filter: _searchController.text.isNotEmpty
            ? ItemFilterDTO(keyword: _searchController.text)
            : null,
        limit: 50,
      );
      if (mounted) {
        setState(() {
          _items = result.data ?? [];
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.link, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '关联账目',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_books.length > 1)
                  Expanded(
                    child: PopupMenuButton<UserBookVO>(
                      onSelected: (book) {
                        setState(() => _selectedBookId = book.id);
                        _search();
                      },
                      itemBuilder: (context) => _books
                          .map((book) => PopupMenuItem(
                                value: book,
                                child: Row(
                                  children: [
                                    if (book.id == _selectedBookId)
                                      Icon(Icons.check,
                                          size: 18, color: colorScheme.primary),
                                    if (book.id == _selectedBookId)
                                      const SizedBox(width: 8),
                                    Text(book.name),
                                  ],
                                ),
                              ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _books
                                          .where((b) => b.id == _selectedBookId)
                                          .firstOrNull
                                          ?.name ??
                                      '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _handleCreateItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('新建'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colorScheme.primary,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索账目',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _search();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.12)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (_) => _search(),
            ),
          ),
          Flexible(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty ? '暂无账目' : '未找到匹配账目',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isIncome = item.type == 'INCOME';
                          final sign = isIncome ? '+' : '-';
                          final amountColor =
                              ColorUtil.getAmountColor(item.type);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(
                                context,
                                '${item.id}|${item.accountBookId}',
                              ),
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colorScheme.outline
                                        .withValues(alpha: 0.06),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        width: 3.5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              amountColor,
                                              amountColor.withValues(
                                                  alpha: 0.2),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item.categoryName ?? '未分类',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (item.description != null &&
                                                  item.description!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 1),
                                                Text(
                                                  item.description!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                          '$sign${item.amount.abs().toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: amountColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
