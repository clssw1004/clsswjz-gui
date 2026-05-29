import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vo/vehicle_vo.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import 'vehicle_form_page.dart';

/// 车辆列表页面
class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VehicleProvider>(
      create: (_) => VehicleProvider(),
      child: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: CommonAppBar(
              title: const Text('油耗记录'),
              showBackButton: true,
            ),
            body: _buildBody(context, provider),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddVehicle(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, VehicleProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无车辆',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _navigateToAddVehicle(context),
              child: const Text('添加车辆'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadItems(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final vehicle = provider.items[index];
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
      child: ListTile(
        title: Text(
          '${vehicle.brand} ${vehicle.model}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              vehicle.plateNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '默认油品: ${vehicle.displayFuelGrade}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.outline,
        ),
        onTap: () => _navigateToRecords(context, vehicle),
      ),
    );
  }

  void _navigateToAddVehicle(BuildContext context) async {
    final provider = this.context.read<VehicleProvider>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const VehicleFormPage(),
      ),
    );
    if (result == true && mounted) {
      provider.loadItems();
    }
  }

  void _navigateToRecords(BuildContext context, VehicleVO vehicle) {
    Navigator.pushNamed(
      context,
      '/fuel/records',
      arguments: {
        'vehicleId': vehicle.id,
        'plateNumber': vehicle.plateNumber,
      },
    );
  }
}
