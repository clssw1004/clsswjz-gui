import 'package:flutter/material.dart';

import '../../models/vo/vehicle_vo.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import 'vehicle_form_page.dart';

/// 车辆管理页面（编辑/删除车辆）
class VehicleManagementPage extends StatefulWidget {
  const VehicleManagementPage({super.key});

  @override
  State<VehicleManagementPage> createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
  late final VehicleProvider _provider;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _provider = VehicleProvider();
    _provider.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadItems();
    });
  }

  @override
  void dispose() {
    _provider.removeListener(_onStateChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _hasChanges) {
          // Return true to parent so it reloads
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(
          title: const Text('管理车辆'),
          showBackButton: true,
        ),
        body: _buildBody(theme, colorScheme),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddVehicle,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_provider.items.isEmpty) {
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
            TextButton(
              onPressed: _navigateToAddVehicle,
              child: const Text('添加车辆'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _provider.loadItems(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _provider.items.length,
        itemBuilder: (context, index) {
          final vehicle = _provider.items[index];
          return _buildVehicleCard(context, vehicle, theme, colorScheme);
        },
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    VehicleVO vehicle,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_car, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    vehicle.plateNumber,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '默认油品: ${vehicle.displayFuelGrade}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  if (vehicle.remark != null && vehicle.remark!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      vehicle.remark!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  onPressed: () => _navigateToEditVehicle(vehicle.id),
                  tooltip: '编辑',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => _deleteVehicle(vehicle),
                  tooltip: '删除',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVehicle(VehicleVO vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('删除车辆'),
          content: Text('确定要删除 ${vehicle.plateNumber} 吗？所有关联的加油记录也将被删除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final result = await _provider.deleteVehicle(vehicle.id);
      if (mounted) {
        _hasChanges = true;
        if (!result.ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '删除失败')),
          );
        }
      }
    }
  }

  void _navigateToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const VehicleFormPage()),
    );
    if (result == true && mounted) {
      _hasChanges = true;
      _provider.loadItems();
    }
  }

  void _navigateToEditVehicle(String vehicleId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => VehicleFormPage(vehicleId: vehicleId)),
    );
    if (result == true && mounted) {
      _hasChanges = true;
      _provider.loadItems();
    }
  }
}
