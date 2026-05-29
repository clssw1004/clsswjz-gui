import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/vo/fuel_record_vo.dart';
import '../../providers/fuel_record_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import 'fuel_record_form_page.dart';
import 'fuel_record_detail_page.dart';
import 'fuel_statistics_page.dart';

/// 加油记录列表页面
class FuelRecordListPage extends StatefulWidget {
  final String vehicleId;
  final String? plateNumber;

  const FuelRecordListPage({
    super.key,
    required this.vehicleId,
    this.plateNumber,
  });

  @override
  State<FuelRecordListPage> createState() => _FuelRecordListPageState();
}

class _FuelRecordListPageState extends State<FuelRecordListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuelRecordProvider>().loadItems(widget.vehicleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FuelRecordProvider>(
      create: (_) => FuelRecordProvider(),
      child: Consumer<FuelRecordProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: CommonAppBar(
              title: Text(widget.plateNumber ?? '加油记录'),
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  onPressed: () => _navigateToStatistics(context),
                  tooltip: '统计',
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToAddRecord(context),
                  tooltip: '添加记录',
                ),
              ],
            ),
            body: _buildBody(context, provider),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddRecord(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FuelRecordProvider provider) {
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
              Icons.local_gas_station,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无加油记录',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _navigateToAddRecord(context),
              child: const Text('添加加油记录'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadItems(widget.vehicleId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final record = provider.items[index];
          return _buildRecordCard(context, record, theme, colorScheme);
        },
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    FuelRecordVO record,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final refuelDate =
        DateTime.fromMillisecondsSinceEpoch(record.refuelTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(context, record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部行：时间和加满标签
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(refuelDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  if (record.isFullTank == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '加满',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // 里程和油品
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${record.mileage} km',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.local_gas_station,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${record.fuelGrade}号',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 加油量和总价
              Row(
                children: [
                  Text(
                    '${record.volume.toStringAsFixed(2)} L',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${record.totalAmount.toStringAsFixed(2)} 元',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddRecord(BuildContext context) async {
    final provider = this.context.read<FuelRecordProvider>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ChangeNotifierProvider<FuelRecordProvider>(
          create: (_) => FuelRecordProvider(),
          child: FuelRecordFormPage(vehicleId: widget.vehicleId),
        ),
      ),
    );
    if (result == true && mounted) {
      provider.loadItems(widget.vehicleId);
    }
  }

  void _navigateToDetail(BuildContext context, FuelRecordVO record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<FuelRecordProvider>(
          create: (_) => FuelRecordProvider(),
          child: FuelRecordDetailPage(recordId: record.id),
        ),
      ),
    );
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FuelStatisticsPage(
          vehicleId: widget.vehicleId,
          plateNumber: widget.plateNumber,
        ),
      ),
    );
  }
}

