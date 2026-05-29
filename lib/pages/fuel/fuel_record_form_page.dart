import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/fuel_record_provider.dart';
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
  int _refuelTime = DateTime.now().millisecondsSinceEpoch;
  bool _saving = false;

  /// 防止自动计算时的递归更新
  bool _isUpdating = false;


  bool get isCreateMode => widget.recordId == null;

  @override
  void initState() {
    super.initState();
    _setupAutoCalculate();

    if (!isCreateMode) {
      _loadRecord();
    }
  }

  void _setupAutoCalculate() {
    _volumeController.addListener(_onFieldChanged);
    _unitPriceController.addListener(_onFieldChanged);
    _totalAmountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (_isUpdating) return;

    _isUpdating = true;

    final volumeText = _volumeController.text;
    final unitPriceText = _unitPriceController.text;
    final totalAmountText = _totalAmountController.text;

    final volume = double.tryParse(volumeText);
    final unitPrice = double.tryParse(unitPriceText);
    final totalAmount = double.tryParse(totalAmountText);

    // Count how many fields have values
    int filledCount = 0;
    if (volume != null) filledCount++;
    if (unitPrice != null) filledCount++;
    if (totalAmount != null) filledCount++;

    if (filledCount >= 2) {
      // Check which two fields are set and calculate the third
      if (volume != null && unitPrice != null && totalAmount == null) {
        // volume + unitPrice -> totalAmount
        _totalAmountController.text = (volume * unitPrice).toStringAsFixed(2);
      } else if (volume != null && totalAmount != null && unitPrice == null) {
        // volume + totalAmount -> unitPrice
        _unitPriceController.text = (totalAmount / volume).toStringAsFixed(2);
      } else if (unitPrice != null && totalAmount != null && volume == null) {
        // unitPrice + totalAmount -> volume
        _volumeController.text = (totalAmount / unitPrice).toStringAsFixed(2);
      }
    }

    _isUpdating = false;
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
    final provider = context.read<FuelRecordProvider>();
    final record = await provider.getFuelRecord(widget.recordId!);
    if (record != null && mounted) {
      _mileageController.text = record.mileage.toString();
      _volumeController.text = record.volume.toStringAsFixed(2);
      _unitPriceController.text = record.unitPrice.toStringAsFixed(2);
      _totalAmountController.text = record.totalAmount.toStringAsFixed(2);
      _fuelGrade = record.fuelGrade;
      _isFullTank = record.isFullTank == 1;
      _stationController.text = record.station ?? '';
      _remarkController.text = record.remark ?? '';
      _refuelTime = record.refuelTime;
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

            // 加油量
            CommonTextFormField(
              controller: _volumeController,
              labelText: '加油量（升）',
              hintText: '请输入加油量',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.local_gas_station,
            ),
            const SizedBox(height: 16),

            // 单价
            CommonTextFormField(
              controller: _unitPriceController,
              labelText: '单价（元/升）',
              hintText: '请输入单价',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.monetization_on,
            ),
            const SizedBox(height: 16),

            // 总价
            CommonTextFormField(
              controller: _totalAmountController,
              labelText: '总价（元）',
              hintText: '请输入总价',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments,
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
                DropdownMenuItem(value: '92', child: Text('92号汽油')),
                DropdownMenuItem(value: '95', child: Text('95号汽油')),
                DropdownMenuItem(value: '98', child: Text('98号汽油')),
                DropdownMenuItem(value: '0', child: Text('0号柴油')),
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

            // 是否加满
            SwitchListTile(
              title: const Text('是否加满'),
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
            const SizedBox(height: 16),

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
      final provider = context.read<FuelRecordProvider>();

      if (isCreateMode) {
        final result = await provider.createFuelRecord(
          vehicleId: widget.vehicleId,
          mileage: mileage,
          energyType: _fuelGrade == '0' ? 'diesel' : 'gasoline',
          fuelGrade: _fuelGrade,
          volume: volume,
          unitPrice: unitPrice,
          totalAmount: totalAmount,
          isFullTank: _isFullTank,
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
        final result = await provider.updateFuelRecord(
          widget.recordId!,
          mileage: mileage,
          energyType: _fuelGrade == '0' ? 'diesel' : 'gasoline',
          fuelGrade: _fuelGrade,
          volume: volume,
          unitPrice: unitPrice,
          totalAmount: totalAmount,
          isFullTank: _isFullTank,
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
