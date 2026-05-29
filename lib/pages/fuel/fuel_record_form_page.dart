import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
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
    final result = await DriverFactory.driver.getFuelRecord(
      AppConfigManager.instance.userId,
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

            // 总价
            Focus(
              onFocusChange: (focused) {
                if (!focused) _recalculate();
              },
              child: CommonTextFormField(
                controller: _totalAmountController,
                labelText: '总价（元）',
                hintText: '请输入总价',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments,
              ),
            ),
            const SizedBox(height: 16),

            // 单价
            Focus(
              onFocusChange: (focused) {
                if (!focused) _recalculate();
              },
              child: CommonTextFormField(
                controller: _unitPriceController,
                labelText: '单价（元/升）',
                hintText: '请输入单价',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.monetization_on,
              ),
            ),
            const SizedBox(height: 16),

            // 加油量
            Focus(
              onFocusChange: (focused) {
                if (!focused) _recalculate();
              },
              child: CommonTextFormField(
                controller: _volumeController,
                labelText: '加油量（升）',
                hintText: '请输入加油量',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.local_gas_station,
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
          ],
        ),
      ),
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

    if (volumeText.isEmpty || unitPriceText.isEmpty || totalAmountText.isEmpty) {
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
          Navigator.pop(context, true);
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
          Navigator.pop(context, true);
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
