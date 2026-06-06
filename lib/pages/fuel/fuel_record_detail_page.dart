import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/fuel_record_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/vehicle_vo.dart';
import '../../providers/item_relation_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/color_util.dart';
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

  final _relationProvider = ItemRelationProvider();
  static const _relationCode = 'fuel_record';

  AccountItem? _linkedItem;
  String? _linkedCategoryName;
  String? _linkedBookId;

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
          // 加载关联账目
          _loadRelation();
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

  Future<void> _loadRelation() async {
    final relations = await _relationProvider.getSourceRelations(
      _relationCode, widget.recordId,
    );
    if (relations.isEmpty || !mounted) return;
    final rel = relations.first;

    final item = await DaoManager.itemDao.findById(rel.itemId);
    if (item == null || !mounted) return;

    String? categoryName;
    if (item.categoryCode != null) {
      final category = await DaoManager.categoryDao.findByBookAndCode(
        item.accountBookId,
        item.categoryCode!,
      );
      categoryName = category?.name;
    }

    if (mounted) {
      setState(() {
        _linkedItem = item;
        _linkedCategoryName = categoryName;
        _linkedBookId = rel.accountBookId;
      });
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
                  value: '${record.fuelGrade}#${record.fuelGrade == '0' ? '柴油' : ''}',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(),
                _buildDetailRow(
                  icon: record.isFullTank == 1
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  label: '加油方式',
                  value: record.isFullTankLabel,
                  theme: theme,
                  colorScheme: colorScheme,
                  valueColor: record.isFullTank == 1
                      ? colorScheme.primary
                      : null,
                ),
                if (record.isFuelLightOn == 1) ...[
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.wb_twilight,
                    label: '油灯状态',
                    value: '油灯亮起',
                    theme: theme,
                    colorScheme: colorScheme,
                    valueColor: Colors.orange,
                  ),
                ],
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

        // 关联账目
        if (_linkedItem != null) ...[
          const SizedBox(height: 16),
          _buildRelationCard(colorScheme, theme),
        ],
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

  /// 关联账目卡片
  Widget _buildRelationCard(ColorScheme colorScheme, ThemeData theme) {
    if (_linkedItem == null) return const SizedBox.shrink();

    final isIncome = _linkedItem!.type == 'INCOME';
    final sign = isIncome ? '+' : '-';
    final amountColor = ColorUtil.getAmountColor(_linkedItem!.type);

    return GestureDetector(
      onTap: _openLinkedItemDetail,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.06),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      amountColor,
                      amountColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _linkedCategoryName ?? '未分类',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (_linkedItem!.description != null &&
                          _linkedItem!.description!.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          _linkedItem!.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '$sign${_linkedItem!.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLinkedItemDetail() async {
    if (_linkedItem == null || _linkedBookId == null) return;
    final userId = AppConfigManager.instance.userId;
    final bookResult =
        await DriverFactory.driver.getBook(userId, _linkedBookId!);
    if (!mounted || !bookResult.ok || bookResult.data == null) return;
    final userItem = UserItemVO.fromAccountItem(
      item: _linkedItem!,
      categoryName: _linkedCategoryName,
    );
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppRoutes.itemEdit,
      arguments: [
        BookMetaVO(bookInfo: bookResult.data!),
        userItem,
      ],
    );
  }
}
