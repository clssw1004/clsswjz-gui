import 'package:flutter/material.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';

/// 车辆表单页面（添加/编辑）
class VehicleFormPage extends StatefulWidget {
  final String? vehicleId;

  const VehicleFormPage({super.key, this.vehicleId});

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _remarkController = TextEditingController();

  String _defaultFuelGrade = '92';
  bool _saving = false;

  bool get isCreateMode => widget.vehicleId == null;

  @override
  void initState() {
    super.initState();
    if (!isCreateMode) {
      _loadVehicle();
    }
  }

  Future<void> _loadVehicle() async {
    final result = await DriverFactory.driver.listVehicles(
      AppConfigManager.instance.userId,
    );
    if (result.ok && result.data != null && mounted) {
      final vehicle = result.data!
          .where((v) => v.id == widget.vehicleId).firstOrNull;
      if (vehicle != null) {
        _plateNumberController.text = vehicle.plateNumber;
        _brandController.text = vehicle.brand;
        _modelController.text = vehicle.model;
        _remarkController.text = vehicle.remark ?? '';
        _defaultFuelGrade = vehicle.defaultFuelGrade;
      }
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(isCreateMode ? '添加车辆' : '编辑车辆'),
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
            CommonTextFormField(
              controller: _plateNumberController,
              labelText: '车牌号',
              hintText: '请输入车牌号',
              required: true,
            ),
            const SizedBox(height: 16),
            CommonTextFormField(
              controller: _brandController,
              labelText: '品牌',
              hintText: '请输入品牌',
              required: true,
            ),
            const SizedBox(height: 16),
            CommonTextFormField(
              controller: _modelController,
              labelText: '车型',
              hintText: '请输入车型',
              required: true,
            ),
            const SizedBox(height: 16),
            // 默认油品
            Text(
              '默认油品',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _defaultFuelGrade,
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
                    _defaultFuelGrade = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final userId = AppConfigManager.instance.userId;
      bool ok;

      if (isCreateMode) {
        final result = await DriverFactory.driver.createVehicle(
          userId,
          plateNumber: _plateNumberController.text.trim(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          remark: _remarkController.text.trim().isEmpty
              ? null
              : _remarkController.text.trim(),
          defaultFuelGrade: _defaultFuelGrade,
        );
        ok = result.ok;
      } else {
        final result = await DriverFactory.driver.updateVehicle(
          userId,
          widget.vehicleId!,
          plateNumber: _plateNumberController.text.trim(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          remark: _remarkController.text.trim().isEmpty
              ? null
              : _remarkController.text.trim(),
          defaultFuelGrade: _defaultFuelGrade,
        );
        ok = result.ok;
      }

      if (ok && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
