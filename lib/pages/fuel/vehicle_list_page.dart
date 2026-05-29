import 'package:flutter/material.dart';

import '../../models/vo/vehicle_vo.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import 'vehicle_form_page.dart';
import 'vehicle_management_page.dart';
import 'fuel_record_list_page.dart';
import 'fuel_record_form_page.dart';
import 'fuel_statistics_page.dart';

/// 油耗中心页面（车辆选择 + 跳转记录列表）
class FuelHubPage extends StatefulWidget {
  const FuelHubPage({super.key});

  @override
  State<FuelHubPage> createState() => _FuelHubPageState();
}

class _FuelHubPageState extends State<FuelHubPage> {
  late final VehicleProvider _vehicleProvider;
  VehicleVO? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _vehicleProvider = VehicleProvider();
    _vehicleProvider.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _vehicleProvider.loadItems();
      _selectInitialVehicle();
    });
  }

  @override
  void dispose() {
    _vehicleProvider.removeListener(_onStateChanged);
    _vehicleProvider.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _selectInitialVehicle() {
    if (_vehicleProvider.items.isNotEmpty && _selectedVehicle == null) {
      setState(() {
        _selectedVehicle = _vehicleProvider.items.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: true,
        title: GestureDetector(
          onTap: _showVehicleSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_gas_station, size: 18, color: colorScheme.onSurface),
              const SizedBox(width: 6),
              Text(
                _selectedVehicle?.plateNumber ?? '选择车辆',
                style: theme.textTheme.titleMedium,
              ),
              Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: _navigateToVehicleManagement,
            tooltip: '管理车辆',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToStatistics,
            tooltip: '统计',
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: _selectedVehicle != null && !_vehicleProvider.loading
          ? FloatingActionButton(
              onPressed: _navigateToAddRecord,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_vehicleProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vehicleProvider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              '暂无车辆',
              style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToAddVehicle,
              child: const Text('添加您的第一辆车'),
            ),
          ],
        ),
      );
    }

    if (_selectedVehicle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              '请选择车辆',
              style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showVehicleSelector,
              child: const Text('选择车辆'),
            ),
          ],
        ),
      );
    }

    return _buildVehicleOverview(context, _selectedVehicle!);
  }

  Widget _buildVehicleOverview(BuildContext context, VehicleVO vehicle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 车辆信息卡片
        Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.directions_car, size: 48, color: colorScheme.secondary),
                const SizedBox(height: 12),
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    vehicle.plateNumber,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '默认油品: ${vehicle.defaultFuelGrade}#',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 操作按钮
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _navigateToRecordList(context),
            icon: const Icon(Icons.list_alt),
            label: const Text('查看加油记录'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _navigateToAddRecord,
            icon: const Icon(Icons.add),
            label: const Text('添加加油记录'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showVehicleSelector() {
    final vehicles = _vehicleProvider.items;
    if (vehicles.isEmpty) {
      _navigateToAddVehicle();
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('切换车辆', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...vehicles.map((v) {
                    return ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text('${v.brand} ${v.model}'),
                      subtitle: Text(v.plateNumber),
                      trailing: IconButton(
                        icon: Icon(Icons.edit_outlined, size: 20),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _navigateToEditVehicle(v.id);
                        },
                      ),
                      onTap: () {
                        setState(() => _selectedVehicle = v);
                        Navigator.pop(ctx);
                      },
                      selected: _selectedVehicle?.id == v.id,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('添加车辆'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _navigateToAddVehicle();
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _navigateToVehicleManagement();
                      },
                      child: const Text('管理车辆'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- Navigation methods ----

  Future<void> _navigateToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const VehicleFormPage()),
    );
    if (result == true && mounted) {
      await _vehicleProvider.loadItems();
      _selectInitialVehicle();
    }
  }

  void _navigateToEditVehicle(String vehicleId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => VehicleFormPage(vehicleId: vehicleId)),
    );
    if (result == true && mounted) {
      await _vehicleProvider.loadItems();
    }
  }

  Future<void> _navigateToVehicleManagement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const VehicleManagementPage()),
    );
    if (result == true && mounted) {
      await _vehicleProvider.loadItems();
      if (_vehicleProvider.items.isNotEmpty) {
        if (_selectedVehicle == null ||
            !_vehicleProvider.items.any((v) => v.id == _selectedVehicle!.id)) {
          setState(() {
            _selectedVehicle = _vehicleProvider.items.first;
          });
        }
      } else {
        setState(() {
          _selectedVehicle = null;
        });
      }
    }
  }

  void _navigateToRecordList(BuildContext context) {
    if (_selectedVehicle == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FuelRecordListPage(
          initialVehicleId: _selectedVehicle!.id,
          initialPlateNumber: _selectedVehicle!.plateNumber,
        ),
      ),
    );
  }

  Future<void> _navigateToAddRecord() async {
    if (_selectedVehicle == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FuelRecordFormPage(vehicleId: _selectedVehicle!.id),
      ),
    );
  }

  void _navigateToStatistics() {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择车辆')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FuelStatisticsPage(
          vehicleId: _selectedVehicle!.id,
          plateNumber: _selectedVehicle!.plateNumber,
        ),
      ),
    );
  }
}
