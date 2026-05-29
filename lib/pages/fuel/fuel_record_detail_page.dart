import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../models/vo/fuel_record_vo.dart';
import '../../models/vo/vehicle_vo.dart';
import '../../widgets/common/common_app_bar.dart';

/// 加油记录详情页面
class FuelRecordDetailPage extends StatefulWidget {
  final String recordId;

  const FuelRecordDetailPage({
    super.key,
    required this.recordId,
  });

  @override
  State<FuelRecordDetailPage> createState() => _FuelRecordDetailPageState();
}

class _FuelRecordDetailPageState extends State<FuelRecordDetailPage> {
  FuelRecordVO? _record;
  VehicleVO? _vehicle;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = AppConfigManager.instance.userId;
      final result = await DriverFactory.driver.getFuelRecord(
        userId,
        widget.recordId,
      );

      if (result.ok && result.data != null) {
        final record = result.data!;
        // Load vehicle info
        final vehicles = await DriverFactory.driver.listVehicles(
          AppConfigManager.instance.userId,
        );
        VehicleVO? vehicle;
        if (vehicles.ok) {
          vehicle = vehicles.data
              ?.where((v) => v.id == record.vehicleId)
              .firstOrNull;
        }

        if (mounted) {
          setState(() {
            _record = record;
            _vehicle = vehicle;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = '未找到加油记录';
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
        title: const Text('加油记录详情'),
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

    if (_record == null) {
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
            _error ?? '加载失败',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = _record!;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final refuelDate = DateTime.fromMillisecondsSinceEpoch(record.refuelTime);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 基本信息卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.directions_car,
                  label: '车辆',
                  value: _vehicle?.displayName ?? record.vehicleId,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.speed,
                  label: '里程',
                  value: '${record.mileage} km',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.local_gas_station,
                  label: '加油量',
                  value: '${record.volume.toStringAsFixed(2)} L',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.monetization_on,
                  label: '单价',
                  value: '${record.unitPrice.toStringAsFixed(2)} 元/升',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.payments,
                  label: '总价',
                  value: '${record.totalAmount.toStringAsFixed(2)} 元',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: Icons.oil_barrel,
                  label: '油品',
                  value: '${record.fuelGrade}号${record.fuelGrade == '0' ? '柴油' : '汽油'}',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: record.isFullTank == 1
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  label: '加油状态',
                  value: record.isFullTankLabel,
                  theme: theme,
                  colorScheme: colorScheme,
                  valueColor: record.isFullTank == 1
                      ? colorScheme.primary
                      : null,
                ),
                if (record.station != null && record.station!.isNotEmpty) ...[
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.store,
                    label: '加油站',
                    value: record.station!,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ],
                if (record.remark != null && record.remark!.isNotEmpty) ...[
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.notes,
                    label: '备注',
                    value: record.remark!,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ],
                const Divider(),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: '加油时间',
                  value: dateFormat.format(refuelDate),
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),

        // 油耗计算卡片（仅加满时显示）
        if (record.isFullTank == 1 &&
            record.fuelConsumption > 0) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '油耗计算',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    label: '平均油耗',
                    value: record.fuelConsumptionText,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    label: '每公里费用',
                    value: record.costPerKmText,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],

        // 底部操作按钮
        const SizedBox(height: 24),
        _buildActionButtons(context, record, colorScheme, theme),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.outline),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
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
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    FuelRecordVO record,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    if (record.hasLinkedAccount) {
      return Center(
        child: Chip(
          avatar: const Icon(Icons.check_circle, size: 18),
          label: const Text('已关联账目'),
          backgroundColor: colorScheme.primaryContainer,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _onLinkAccount,
          icon: const Icon(Icons.book),
          label: const Text('记一笔'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _onLinkAccount() async {
    final messenger = ScaffoldMessenger.of(context);

    // Step 1: Load books
    final booksResult = await DriverFactory.driver.listBooksByUser(
      AppConfigManager.instance.userId,
    );

    if (!mounted) return;

    if (!booksResult.ok || booksResult.data == null || booksResult.data!.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('没有可用的账本')),
      );
      return;
    }

    final books = booksResult.data!;

    // Step 2: Show book selector dialog
    final selectedBook = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('选择账本'),
          children: books.map((book) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, {
                'bookId': book.id,
                'bookName': book.name,
              }),
              child: ListTile(
                leading: Icon(
                  Icons.book,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                title: Text(book.name),
                subtitle: Text(book.description ?? ''),
                dense: true,
              ),
            );
          }).toList(),
        );
      },
    );

    if (selectedBook == null || !mounted) return;

    // Step 3: Navigate to itemAdd with the selected book
    // For now, show a placeholder message since full integration
    // requires additional UX decisions
    messenger.showSnackBar(
      const SnackBar(content: Text('记账功能将在下一版本集成')),
    );
  }
}
