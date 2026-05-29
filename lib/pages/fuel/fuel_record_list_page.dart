import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../models/vo/fuel_record_vo.dart';
import '../../models/vo/vehicle_vo.dart';
import '../../providers/fuel_record_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import 'fuel_record_form_page.dart';
import 'fuel_statistics_page.dart';
import 'vehicle_form_page.dart';
import 'vehicle_management_page.dart';

/// 加油记录列表页面（自包含车辆选择）
class FuelRecordListPage extends StatefulWidget {
  final String? initialVehicleId;
  final String? initialPlateNumber;

  const FuelRecordListPage({
    super.key,
    this.initialVehicleId,
    this.initialPlateNumber,
  });

  @override
  State<FuelRecordListPage> createState() => _FuelRecordListPageState();
}

class _FuelRecordListPageState extends State<FuelRecordListPage> {
  late final FuelRecordProvider _recordProvider;
  late final VehicleProvider _vehicleProvider;
  String? _vehicleId;
  String? _plateNumber;

  @override
  void initState() {
    super.initState();
    _recordProvider = FuelRecordProvider();
    _vehicleProvider = VehicleProvider();
    _vehicleProvider.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _vehicleProvider.loadItems();
      _resolveVehicle();
    });
  }

  void _resolveVehicle() {
    // Priority: widget param > saved config > first vehicle
    final savedId = widget.initialVehicleId ?? AppConfigManager.instance.selectedVehicleId;
    VehicleVO? match;
    if (savedId != null) {
      match = _vehicleProvider.items.where((v) => v.id == savedId).firstOrNull;
    }
    match ??= _vehicleProvider.items.isNotEmpty ? _vehicleProvider.items.first : null;

    if (match != null) {
      _selectVehicle(match);
    } else {
      setState(() {});
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _selectVehicle(VehicleVO vehicle) {
    setState(() {
      _vehicleId = vehicle.id;
      _plateNumber = vehicle.plateNumber;
    });
    _recordProvider.loadItems(vehicle.id);
    AppConfigManager.instance.setSelectedVehicle(vehicle.id, vehicle.plateNumber);
  }

  @override
  void dispose() {
    _recordProvider.dispose();
    _vehicleProvider.removeListener(_onStateChanged);
    _vehicleProvider.dispose();
    super.dispose();
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
                _plateNumber ?? '选择车辆',
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
          if (_vehicleId != null)
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => _navigateToStatistics(context),
              tooltip: '统计',
            ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: _vehicleId != null
          ? FloatingActionButton(
              onPressed: () => _navigateToAddRecord(context),
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
            Text('暂无车辆', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.outline)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToAddVehicle,
              child: const Text('添加您的第一辆车'),
            ),
          ],
        ),
      );
    }

    if (_vehicleId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('请选择车辆', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.outline)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showVehicleSelector,
              child: const Text('选择车辆'),
            ),
          ],
        ),
      );
    }

    if (_recordProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recordProvider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_gas_station, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('暂无加油记录', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.outline)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _navigateToAddRecord(context),
              child: const Text('添加加油记录'),
            ),
          ],
        ),
      );
    }

    final items = _recordProvider.items;
    final stats = _computeStats(items);

    return RefreshIndicator(
      onRefresh: () => _recordProvider.loadItems(_vehicleId!),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
        children: [
          _buildStatsCard(context, stats, theme, colorScheme),
          const SizedBox(height: 24),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final tripKm = i == items.length - 1
                ? 0
                : (items[i].mileage - items[i + 1].mileage).clamp(0, 9999999);
            return _buildTimelineItem(
              context,
              entry.value,
              i,
              tripKm,
              i == 0,
              i == items.length - 1,
              theme,
              colorScheme,
            );
          }),
        ],
      ),
    );
  }

  // ── 车辆选择器 ──────────────────────────────────────

  void _showVehicleSelector() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final vehicles = _vehicleProvider.items;
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
                        _selectVehicle(v);
                        Navigator.pop(ctx);
                      },
                      selected: _vehicleId == v.id,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ── 统计 ────────────────────────────────────────────

  _ListStats _computeStats(List<FuelRecordVO> items) {
    if (items.isEmpty) return _ListStats.empty();

    double totalVolume = 0;
    double totalAmount = 0;
    final fullTankRecords = <FuelRecordVO>[];
    int totalMileage = 0;

    for (final r in items) {
      totalVolume += r.volume;
      totalAmount += r.totalAmount;
      if (r.isFullTank == 1 && r.fuelConsumption > 0) {
        fullTankRecords.add(r);
      }
    }

    // 行驶总里程 = 每次加油里程差之和（不含初始里程）
    for (int i = 1; i < items.length; i++) {
      final diff = items[i - 1].mileage - items[i].mileage;
      if (diff > 0) totalMileage += diff;
    }

    double? avgConsumption;
    if (fullTankRecords.isNotEmpty) {
      double sum = 0;
      for (final r in fullTankRecords) {
        sum += r.fuelConsumption;
      }
      avgConsumption = sum / fullTankRecords.length;
    }

    double? avgCostPerKm;
    if (totalMileage > 0) avgCostPerKm = totalAmount / totalMileage;

    return _ListStats(
      recordCount: items.length,
      totalVolume: totalVolume,
      totalAmount: totalAmount,
      totalMileage: totalMileage,
      avgConsumption: avgConsumption,
      avgCostPerKm: avgCostPerKm,
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    _ListStats stats,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _statItem(label: '总费用', value: '${stats.totalAmount.toStringAsFixed(0)}元', icon: Icons.payments, iconColor: colorScheme.tertiary, theme: theme, colorScheme: colorScheme)),
              _statDivider(colorScheme),
              Expanded(child: _statItem(label: '总里程', value: stats.totalMileage > 0 ? '${stats.totalMileage} km' : '--', icon: Icons.speed, iconColor: colorScheme.secondary, theme: theme, colorScheme: colorScheme)),
              _statDivider(colorScheme),
              Expanded(child: _statItem(label: '总油量', value: '${stats.totalVolume.toStringAsFixed(1)}L', icon: Icons.local_gas_station, iconColor: colorScheme.primary, theme: theme, colorScheme: colorScheme)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statItem(label: '平均油耗', value: stats.avgConsumption != null ? '${stats.avgConsumption!.toStringAsFixed(1)}L/100km' : '--', icon: Icons.eco, iconColor: Colors.green, theme: theme, colorScheme: colorScheme)),
              _statDivider(colorScheme),
              Expanded(child: _statItem(label: '每公里费用', value: stats.avgCostPerKm != null ? '${stats.avgCostPerKm!.toStringAsFixed(2)}元' : '--', icon: Icons.money, iconColor: colorScheme.error, theme: theme, colorScheme: colorScheme)),
              _statDivider(colorScheme),
              Expanded(child: _statItem(label: '记录次数', value: '${stats.recordCount}次', icon: Icons.receipt_long, iconColor: colorScheme.outline, theme: theme, colorScheme: colorScheme)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required String label, required String value, required IconData icon, required Color iconColor,
    required ThemeData theme, required ColorScheme colorScheme,
  }) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: iconColor),
      const SizedBox(height: 4),
      Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline)),
    ]);
  }

  Widget _statDivider(ColorScheme colorScheme) {
    return Container(width: 1, height: 36, color: colorScheme.outlineVariant);
  }

  // ── 时间线条目 ───────────────────────────────────────

  Widget _buildTimelineItem(
    BuildContext context,
    FuelRecordVO record,
    int index,
    int tripKm,
    bool isFirst,
    bool isLast,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final refuelDate = DateTime.fromMillisecondsSinceEpoch(record.refuelTime);

    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 左侧时间线（仅圆点+竖线） ──
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      border: Border.all(color: colorScheme.surface, width: 2.5),
                      boxShadow: [
                        BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 4),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ── 内容区域：日期/公里/删除行 + 卡片 ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 时间、行驶公里数、删除 在一行（左中右）
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          dateFormat.format(refuelDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (tripKm > 0) ...[
                          Text(
                            '+ $tripKm',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'km',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                        const Spacer(),
                        InkWell(
                          onTap: () => _confirmDelete(context, record),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 卡片
                  _buildRecordCard(context, record, theme, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 记录卡片（无背景内块 + 加油标号） ──────────────

  Widget _buildRecordCard(
    BuildContext context,
    FuelRecordVO record,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 外层顶部：油耗 + 编辑 ──
            Row(
              children: [
                Icon(Icons.eco, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  record.fuelConsumption > 0
                      ? '${record.fuelConsumption.toStringAsFixed(1)} L/100km'
                      : '-- L/100km',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _navigateToEditRecord(context, record),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: colorScheme.outline),
                        const SizedBox(width: 2),
                        Text(
                          '编辑',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── 内部方块（无背景色） ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _innerBlockValue(
                        record.totalAmount.toStringAsFixed(0),
                        '元',
                        theme,
                        colorScheme.tertiary,
                      ),
                      _innerBlockDivider(colorScheme),
                      _innerBlockValue(
                        record.unitPrice.toStringAsFixed(2),
                        '元/L',
                        theme,
                        colorScheme.secondary,
                      ),
                      _innerBlockDivider(colorScheme),
                      _innerBlockValue(
                        record.volume.toStringAsFixed(1),
                        'L',
                        theme,
                        colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _innerBlockLabel('总里程 ${record.mileage} km', theme, colorScheme),
                      Container(width: 1, height: 12, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      _innerBlockLabel(
                        record.costPerKm > 0
                            ? '每公里 ${record.costPerKm.toStringAsFixed(2)}元'
                            : '每公里 --',
                        theme,
                        colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── 外层底部：跳枪 / 油灯 / 加油标号 ──
            Row(
              children: [
                if (record.isFullTank == 1)
                  _badge('跳枪', colorScheme.primaryContainer, colorScheme.onPrimaryContainer, theme),
                if (record.isFullTank == 1 && record.isFuelLightOn == 1) const SizedBox(width: 6),
                if (record.isFuelLightOn == 1)
                  _badge('油灯', Colors.orange.withValues(alpha: 0.15), Colors.orange.shade700, theme),
                const Spacer(),
                // 加油标号（右下角）
                Text(
                  '${record.fuelGrade}#',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _innerBlockValue(String value, String unit, ThemeData theme, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 2),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _innerBlockDivider(ColorScheme colorScheme) {
    return Container(width: 1, height: 24, color: colorScheme.outlineVariant.withValues(alpha: 0.3));
  }

  Widget _innerBlockLabel(String text, ThemeData theme, ColorScheme colorScheme) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
    );
  }

  Widget _badge(String text, Color bgColor, Color textColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }

  // ── 删除确认 ─────────────────────────────────────────

  Future<void> _confirmDelete(BuildContext context, FuelRecordVO record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定删除 ${dateFormat(DateTime.fromMillisecondsSinceEpoch(record.refuelTime))} 的加油记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await DriverFactory.driver.deleteFuelRecord(
        AppConfigManager.instance.userId,
        record.id,
      );
      if (!mounted) return;
      if (result.ok) {
        _recordProvider.loadItems(_vehicleId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '删除失败')),
        );
      }
    }
  }

  String dateFormat(DateTime dt) => DateFormat('yyyy/MM/dd HH:mm').format(dt);

  // ── 导航方法 ─────────────────────────────────────────

  void _navigateToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const VehicleFormPage()),
    );
    if (result == true && mounted) {
      await _vehicleProvider.loadItems();
      _resolveVehicle();
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
      if (_vehicleProvider.items.isEmpty) {
        setState(() {
          _vehicleId = null;
          _plateNumber = null;
        });
      } else if (_vehicleId == null || !_vehicleProvider.items.any((v) => v.id == _vehicleId)) {
        _resolveVehicle();
      }
    }
  }

  void _navigateToAddRecord(BuildContext context) async {
    if (_vehicleId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => FuelRecordFormPage(vehicleId: _vehicleId!)),
    );
    if (result == true && mounted) _recordProvider.loadItems(_vehicleId!);
  }

  void _navigateToEditRecord(BuildContext context, FuelRecordVO record) async {
    if (_vehicleId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FuelRecordFormPage(vehicleId: record.vehicleId, recordId: record.id),
      ),
    );
    if (result == true && mounted) _recordProvider.loadItems(_vehicleId!);
  }

  void _navigateToStatistics(BuildContext context) {
    if (_vehicleId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FuelStatisticsPage(
          vehicleId: _vehicleId!,
          plateNumber: _plateNumber,
        ),
      ),
    );
  }
}

/// 列表统计内部类
class _ListStats {
  final int recordCount;
  final double totalVolume;
  final double totalAmount;
  final int totalMileage;
  final double? avgConsumption;
  final double? avgCostPerKm;

  const _ListStats({
    required this.recordCount,
    required this.totalVolume,
    required this.totalAmount,
    required this.totalMileage,
    this.avgConsumption,
    this.avgCostPerKm,
  });

  static _ListStats empty() => const _ListStats(
        recordCount: 0, totalVolume: 0, totalAmount: 0, totalMileage: 0,
      );
}
