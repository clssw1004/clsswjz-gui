import 'package:flutter/material.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../models/vo/fuel_statistics_vo.dart';
import '../../widgets/common/common_app_bar.dart';

/// 油耗统计页面
class FuelStatisticsPage extends StatefulWidget {
  final String vehicleId;
  final String? plateNumber;

  const FuelStatisticsPage({
    super.key,
    required this.vehicleId,
    this.plateNumber,
  });

  @override
  State<FuelStatisticsPage> createState() => _FuelStatisticsPageState();
}

class _FuelStatisticsPageState extends State<FuelStatisticsPage> {
  FuelStatisticsVO? _statistics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await DriverFactory.driver.getFuelStatistics(
        AppConfigManager.instance.userId,
        widget.vehicleId,
      );

      if (mounted) {
        if (result.ok) {
          setState(() {
            _statistics = result.data;
            _loading = false;
          });
        } else {
          setState(() {
            _error = result.message ?? '加载失败';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载失败: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.plateNumber != null
            ? '${widget.plateNumber} 油耗统计'
            : '油耗统计'),
        showBackButton: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(context);
    }

    if (_statistics == null) {
      return _buildErrorState(context);
    }

    return _buildContent(context);
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? '暂无数据',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStatistics,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stats = _statistics!;

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 统计概览卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 平均油耗 - 突出显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.speed,
                        size: 28,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '平均油耗',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats.averageFuelConsumptionText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 详细统计卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatisticsRow(
                    icon: Icons.monetization_on,
                    label: '平均每公里费用',
                    value: stats.averageCostPerKmText,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const Divider(),
                  _buildStatisticsRow(
                    icon: Icons.local_gas_station,
                    label: '加油次数',
                    value: '${stats.totalRecords} 次',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const Divider(),
                  _buildStatisticsRow(
                    icon: Icons.local_gas_station,
                    label: '总加油量',
                    value: '${stats.totalVolume.toStringAsFixed(2)} L',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const Divider(),
                  _buildStatisticsRow(
                    icon: Icons.payments,
                    label: '总费用',
                    value: '${stats.totalAmount.toStringAsFixed(2)} 元',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),

          // 说明
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '油耗数据基于加满记录计算，无加满记录时平均油耗显示为 --',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
