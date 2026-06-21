import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../manager/l10n_manager.dart';
import '../../manager/dao_manager.dart';
import '../../utils/color_util.dart';
import '../../models/vo/monthly_report_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../services/monthly_report_service.dart';
import '../../utils/date_util.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';

class ReportDetailPage extends StatefulWidget {
  final UserNoteVO note;
  const ReportDetailPage({super.key, required this.note});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool _regenerating = false;
  String _content = '';

  @override
  void initState() {
    super.initState();
    _content = widget.note.content;
  }

  Future<void> _regenerate() async {
    setState(() => _regenerating = true);
    final title = widget.note.title ?? '';
    final regExp = RegExp(r'(\d+)年(\d+)月');
    final match = regExp.firstMatch(title);
    if (match == null) {
      ToastUtil.showError(L10nManager.l10n.reportRegenFailed);
      setState(() => _regenerating = false);
      return;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final bookId = widget.note.accountBookId;

    final service = MonthlyReportService();
    final noteId = await service.regenerateReport(bookId, year, month);
    if (mounted) {
      if (noteId != null) {
        final updated = await DaoManager.noteDao.findById(noteId);
        if (updated != null && mounted) {
          setState(() {
            _content = updated.content ?? '';
          });
          ToastUtil.showSuccess(L10nManager.l10n.reportRegenerated);
        }
      } else {
        ToastUtil.showError(L10nManager.l10n.reportRegenFailed);
      }
      setState(() => _regenerating = false);
    }
  }

  static const int _expectedVersion = 1;

  @override
  Widget build(BuildContext context) {
    final r = _parse(_content);
    final versionOk = r != null && r.version == _expectedVersion;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.note.title ?? '月度报告'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: _regenerating ? null : _regenerate,
              icon: _regenerating
                  ? SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.refresh_rounded),
              tooltip: L10nManager.l10n.reportRegenerate,
            ),
          ),
        ],
      ),
      body: !versionOk
          ? _ErrorState(onRegenerate: _regenerating ? null : _regenerate, isRegenerating: _regenerating)
          : _Body(r: r),
    );
  }

  MonthlyReportVO? _parse(String? c) {
    try { return c != null && c.isNotEmpty
        ? MonthlyReportVO.fromJson(jsonDecode(c) as Map<String, dynamic>) : null; }
    catch (_) { return null; }
  }
}

/// 渲染失败/版本不匹配时的兜底界面
class _ErrorState extends StatelessWidget {
  final VoidCallback? onRegenerate;
  final bool isRegenerating;
  const _ErrorState({this.onRegenerate, this.isRegenerating = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text('报告数据格式已更新',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('请重新生成以查看最新内容',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRegenerate,
              icon: isRegenerating
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.refresh_rounded),
              label: Text(isRegenerating ? '重新生成中…' : '重新生成'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final MonthlyReportVO r;
  const _Body({required this.r});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = r.summary;
    final hasComp = s.hasComparison;
    // 支出金额为负值，用绝对值计算变化方向
    final expAbsDiff = s.totalExpense.abs() - s.prevExpense.abs();
    final expDown = expAbsDiff < 0;
    final expDiffDisplay = expAbsDiff.abs();
    final expPct = s.prevExpense.abs() > 0 ? (expAbsDiff / s.prevExpense.abs()) * 100 : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // ═══ HEADER ═══
        _Header(period: r.period, expenseDiffDisplay: expDiffDisplay,
            expenseDown: expDown, expensePct: expPct,
            prevExpense: s.prevExpense.abs(), currentExpense: s.totalExpense.abs(),
            hasComp: hasComp, cs: cs),
        const SizedBox(height: 20),

        // ═══ KPI COMPARISON CARDS ═══
        _KpiComparisonRow(cs: cs, s: s, hasComp: hasComp),
        const SizedBox(height: 24),

        // ═══ EXPENSE DONUT ═══
        if (r.categoryExpenses.isNotEmpty) ...[
          _sectionTitle(cs, L10nManager.l10n.reportSectionCategories),
          const SizedBox(height: 8),
          _DonutChart(data: r.categoryExpenses
              .map((c) => _ChartData(c.categoryName, c.amount)).toList()),
          const SizedBox(height: 24),
        ],

        // ═══ INCOME DONUT ═══
        if (r.categoryIncomes.isNotEmpty) ...[
          _sectionTitle(cs, L10nManager.l10n.reportSectionIncome),
          const SizedBox(height: 8),
          _DonutChart(data: r.categoryIncomes
              .map((c) => _ChartData(c.categoryName, c.amount)).toList()),
          const SizedBox(height: 24),
        ],

        // ═══ EXPENSE COMPARISON ═══
        if (r.categoryExpenses.isNotEmpty) ...[
          _sectionTitle(cs, L10nManager.l10n.reportSectionComparison),
          const SizedBox(height: 8),
          _CategoryComparison(categories: r.categoryExpenses, cs: cs, hasComp: hasComp),
          const SizedBox(height: 24),
        ],

        // ═══ DAILY CHART ═══
        if (r.dailyAmounts.isNotEmpty) ...[
          _sectionTitle(cs, L10nManager.l10n.reportSectionDaily),
          const SizedBox(height: 8),
          _DailyChart(dailyAmounts: r.dailyAmounts, cs: cs),
          const SizedBox(height: 24),
        ],

        // ═══ YTD COMPARISON ═══
        if (r.ytdSummary != null) ...[
          _sectionTitle(cs, L10nManager.l10n.reportSectionYtd),
          const SizedBox(height: 8),
          _YtdCard(cs: cs, s: s, ytd: r.ytdSummary!),
          const SizedBox(height: 24),
        ],

        // ═══ MONTHLY TREND ═══
        if (r.monthlyTrend.length >= 2) ...[
          _sectionTitle(cs, L10nManager.l10n.reportSectionMonthlyTrend),
          const SizedBox(height: 8),
          _TrendChart(points: r.monthlyTrend, cs: cs),
          const SizedBox(height: 24),
        ],

        // ═══ KEY METRICS ═══
        _sectionTitle(cs, L10nManager.l10n.reportSectionMetrics),
        const SizedBox(height: 10),
        _KeyMetrics(s: s, r: r, cs: cs),

        // ═══ FOOTER ═══
        const SizedBox(height: 24),
        Center(child: Text(L10nManager.l10n.reportGeneratedAt(DateUtil.format(r.generatedAt)),
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))),
      ],
    );
  }

  Widget _sectionTitle(ColorScheme cs, String text) {
    return Row(children: [
      Container(width: 3, height: 14,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
    ]);
  }
}

// ═══ HEADER ═══
class _Header extends StatelessWidget {
  final ReportPeriod period;
  final double expenseDiffDisplay;
  final bool expenseDown;
  final double expensePct;
  final double prevExpense;
  final double currentExpense;
  final bool hasComp;
  final ColorScheme cs;
  const _Header({required this.period, required this.expenseDiffDisplay,
      required this.expenseDown, required this.expensePct,
      required this.prevExpense, required this.currentExpense,
      required this.hasComp, required this.cs});

  @override
  Widget build(BuildContext context) {
    final cc = ColorUtil.EXPENSE;
    final arrow = expenseDown ? Icons.arrow_downward : Icons.arrow_upward;
    final monthLabel = '${period.year}.${period.month.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 第一行：月份 + 变化
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(monthLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
          ),
          if (hasComp) ...[
            const SizedBox(width: 10),
            Text(L10nManager.l10n.reportLabelVsPrevMonth,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const Spacer(),
            Icon(arrow, size: 16, color: cc),
            const SizedBox(width: 3),
            Text('¥${expenseDiffDisplay.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cc, fontFamily: 'monospace')),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: cc.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${(expensePct).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cc)),
            ),
          ],
        ]),
        // 第二行：上月 → 本月
        if (hasComp) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('上月', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
              const SizedBox(width: 4),
              Text('¥${prevExpense.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, size: 11, color: cs.onSurfaceVariant),
              ),
              Text('¥${currentExpense.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cc, fontFamily: 'monospace')),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ═══ KPI + COMPARISON ═══
class _KpiComparisonRow extends StatelessWidget {
  final ColorScheme cs;
  final ReportSummary s;
  final bool hasComp;
  const _KpiComparisonRow({required this.cs, required this.s, required this.hasComp});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Row 1: KPI values only
      Row(children: [
        _kpiValue(cs, L10nManager.l10n.reportLabelExpense, s.totalExpense, ColorUtil.EXPENSE),
        const SizedBox(width: 10),
        _kpiValue(cs, L10nManager.l10n.reportLabelIncome, s.totalIncome, ColorUtil.INCOME),
        const SizedBox(width: 10),
        _kpiValue(cs, L10nManager.l10n.reportLabelBalance, s.balance, cs.tertiary),
      ]),
      // Row 2: Full-width comparison
      if (hasComp) ...[
        const SizedBox(height: 10),
        _ComparisonStrip(cs: cs, s: s),
      ],
    ]);
  }

  Widget _kpiValue(ColorScheme cs, String label, double current, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('¥${current.abs().toStringAsFixed(0)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color, fontFamily: 'monospace', height: 1.1)),
        ]),
      ),
    );
  }
}

/// 全宽环比对比条
class _ComparisonStrip extends StatelessWidget {
  final ColorScheme cs;
  final ReportSummary s;
  const _ComparisonStrip({required this.cs, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        _compLine(cs, L10nManager.l10n.reportLabelExpense, s.prevExpense, s.totalExpense, true),
        const SizedBox(height: 6),
        _compLine(cs, L10nManager.l10n.reportLabelIncome, s.prevIncome, s.totalIncome, false),
        const SizedBox(height: 6),
        _compLine(cs, L10nManager.l10n.reportLabelBalance, s.prevBalance, s.balance, false),
      ]),
    );
  }

  Widget _compLine(ColorScheme cs, String label, double prev, double current, [bool isExpense = false]) {
    // 金额可能为负值（支出），用绝对值计算变化
    final absPrev = prev.abs();
    final absCur = current.abs();
    final absDiff = absCur - absPrev;
    final isDown = absDiff < 0; // 绝对值减少 = 降低
    final displayDiff = absDiff.abs();
    final pct = absPrev > 0 ? (displayDiff / absPrev) * 100 : 0.0;
    // 费用降低（支出减少）意味着正向变化，用 primary 色；费用升高用 error 色
    final isGoodChange = isExpense ? isDown : !isDown;
    final changeColor = isGoodChange ? cs.primary : cs.error;
    return Row(children: [
      SizedBox(width: 36, child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface))),
      const SizedBox(width: 8),
      Text('${L10nManager.l10n.reportLabelPrevMonth} ¥${absPrev.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontFamily: 'monospace')),
      const SizedBox(width: 8),
      Icon(Icons.arrow_forward, size: 12, color: cs.onSurfaceVariant),
      const SizedBox(width: 8),
      Text('¥${absCur.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace')),
      const Spacer(),
      Icon(isDown ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: changeColor),
      const SizedBox(width: 2),
      Text(displayDiff.toStringAsFixed(0),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: changeColor, fontFamily: 'monospace')),
      const SizedBox(width: 4),
      Text('(${pct.toStringAsFixed(1)}%)',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    ]);
  }
}

// ═══ CATEGORY DONUT CHART ═══
class _DonutChart extends StatelessWidget {
  final List<_ChartData> data;
  const _DonutChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = data.fold<double>(0, (s, d) => s + d.y);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        SizedBox(
          height: 180,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            legend: Legend(isVisible: false),
            series: <CircularSeries>[
              DoughnutSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.y,
                pointColorMapper: (d, _) => d.color,
                dataLabelMapper: (d, _) => d.y / total >= 0.05 ? '${(d.y / total * 100).toStringAsFixed(0)}%' : '',
                animationDuration: 600,
                innerRadius: '60%',
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        ...data.take(6).map((d) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Expanded(child: Text(d.x, style: TextStyle(fontSize: 11, color: cs.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text('${(d.y / total * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text('¥${d.y.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace')),
          ]),
        )),
      ]),
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  final Color color;
  _ChartData(this.x, this.y) : color = _palette[x.hashCode.abs() % _palette.length];
}

const List<Color> _palette = [
  Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047),
  Color(0xFFFB8C00), Color(0xFF8E24AA), Color(0xFF00ACC1),
  Color(0xFFD81B60), Color(0xFF3949AB), Color(0xFF6D4C41),
  Color(0xFF546E7A),
];

// ═══ CATEGORY COMPARISON ═══
class _CategoryComparison extends StatelessWidget {
  final List<CategoryExpenseItem> categories;
  final ColorScheme cs;
  final bool hasComp;
  const _CategoryComparison({required this.categories, required this.cs, required this.hasComp});

  @override
  Widget build(BuildContext context) {
    final maxAmount = categories.fold<double>(0, (m, c) => max(m, c.amount));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        // Header row
        Row(children: [
          const SizedBox(width: 60, child: Text('', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Container()),
          SizedBox(width: 44, child: Text(L10nManager.l10n.reportLabelCurrentMonth, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey), textAlign: TextAlign.right)),
          if (hasComp) SizedBox(width: 44, child: Text(L10nManager.l10n.reportLabelPrevMonth, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey), textAlign: TextAlign.right)),
          const SizedBox(width: 6),
        ]),
        const SizedBox(height: 6),
        ...categories.take(5).map((c) => _compRow(c, maxAmount, cs, hasComp)),
      ]),
    );
  }

  Widget _compRow(CategoryExpenseItem c, double maxAmt, ColorScheme cs, bool hasComp) {
    final thisRatio = maxAmt > 0 ? (c.amount / maxAmt).clamp(0.0, 1.0) : 0.0;
    final prevRatio = maxAmt > 0 && c.prevAmount > 0 ? (c.prevAmount / maxAmt).clamp(0.0, 1.0) : 0.0;
    final isUp = c.diff > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 60,
            child: Text(c.categoryName, style: TextStyle(fontSize: 12, color: cs.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(children: [
            // This month bar
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: thisRatio,
                    backgroundColor: Colors.transparent,
                    color: ColorUtil.EXPENSE,
                    minHeight: 8,
                  ),
                ),
              ),
            ]),
            // Previous month bar
            if (hasComp && c.prevAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: prevRatio,
                        backgroundColor: Colors.transparent,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ]),
              ),
          ]),
        ),
        const SizedBox(width: 6),
        SizedBox(width: 44,
            child: Text('¥${c.amount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace'),
                textAlign: TextAlign.right)),
        if (hasComp) SizedBox(width: 44,
            child: Text(c.prevAmount > 0 ? '¥${c.prevAmount.toStringAsFixed(0)}' : '-',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontFamily: 'monospace'),
                textAlign: TextAlign.right)),
        const SizedBox(width: 4),
        if (hasComp && c.prevAmount > 0)
          Text(isUp ? '↑' : '↓',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUp ? cs.error : cs.primary)),
      ]),
    );
  }
}

// ═══ DAILY EXPENSE CHART ═══
class _DailyChart extends StatelessWidget {
  final List<double> dailyAmounts;
  final ColorScheme cs;
  const _DailyChart({required this.dailyAmounts, required this.cs});

  @override
  Widget build(BuildContext context) {
    final data = List.generate(dailyAmounts.length, (i) =>
        _ChartData('${i + 1}', dailyAmounts[i]));
    if (data.every((d) => d.y == 0)) return const SizedBox();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: SizedBox(
        height: 140,
        child: SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
            interval: dailyAmounts.length > 20 ? 5 : 3,
          ),
          primaryYAxis: NumericAxis(
            isVisible: false,
            minimum: 0,
          ),
          series: <CartesianSeries>[
            ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.x,
              yValueMapper: (d, _) => d.y,
              pointColorMapper: (d, _) => d.y > 0 ? ColorUtil.EXPENSE.withValues(alpha: 0.6) : Colors.transparent,
              width: 0.6,
              spacing: 0.15,
              borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 每月收支趋势双线图
class _TrendChart extends StatelessWidget {
  final List<MonthlyTrendPoint> points;
  final ColorScheme cs;
  const _TrendChart({required this.points, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: SizedBox(
        height: 210,
        child: SfCartesianChart(
          margin: const EdgeInsets.only(right: 8),
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: AxisLine(width: 0),
            majorGridLines: MajorGridLines(color: cs.outline.withValues(alpha: 0.06)),
            labelFormat: '{value}',
            labelStyle: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
            numberFormat: null,
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            color: cs.surface,
            textStyle: TextStyle(color: cs.onSurface, fontSize: 11),
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            textStyle: TextStyle(fontSize: 11, color: cs.onSurface),
          ),
          series: <CartesianSeries>[
            LineSeries<MonthlyTrendPoint, String>(
              dataSource: points,
              xValueMapper: (p, _) => '${p.month}月',
              yValueMapper: (p, _) => p.income,
              name: L10nManager.l10n.reportLabelIncome,
              color: ColorUtil.INCOME,
              width: 2.5,
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8, height: 8,
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: ColorUtil.INCOME),
              ),
              animationDuration: 600,
            ),
            LineSeries<MonthlyTrendPoint, String>(
              dataSource: points,
              xValueMapper: (p, _) => '${p.month}月',
              yValueMapper: (p, _) => p.expense,
              name: L10nManager.l10n.reportLabelExpense,
              color: ColorUtil.EXPENSE,
              width: 2.5,
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.diamond,
                width: 9, height: 9,
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.bottom,
                textStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: ColorUtil.EXPENSE),
              ),
              animationDuration: 600,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ KEY METRICS ═══
class _KeyMetrics extends StatelessWidget {
  final ReportSummary s;
  final MonthlyReportVO r;
  final ColorScheme cs;
  const _KeyMetrics({required this.s, required this.r, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Wrap(spacing: 4, runSpacing: 10, children: [
        _metric(cs, L10nManager.l10n.reportMetricSavingsRate, '${r.savingsRate.toStringAsFixed(1)}%', r.savingsRate >= 20 ? cs.primary : cs.error),
        _metric(cs, L10nManager.l10n.reportMetricDailyAvg, '¥${s.dailyAverage.toStringAsFixed(1)}', cs.onSurface),
        _metric(cs, L10nManager.l10n.reportMetricItemCount, '${r.itemCount}', cs.onSurface),
        _metric(cs, L10nManager.l10n.reportMetricCategoryCount, '${r.categoryExpenses.length}', cs.onSurface),
        _metric(cs, L10nManager.l10n.reportMetricSpendingDays, '${r.dailyAmounts.where((d) => d > 0).length}天', cs.onSurface),
        _metric(cs, L10nManager.l10n.reportMetricMaxTxn, '¥${r.trends.maxSpendAmount?.toStringAsFixed(0) ?? "-"}', cs.onSurface),
      ]),
    );
  }

  Widget _metric(ColorScheme cs, String label, String value, Color valueColor) {
    return SizedBox(
      width: 100,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor, fontFamily: 'monospace')),
      ]),
    );
  }
}

/// 年度累计对比卡片
class _YtdCard extends StatelessWidget {
  final ColorScheme cs;
  final ReportSummary s;
  final YtdSummary ytd;

  const _YtdCard({required this.cs, required this.s, required this.ytd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curExpense = s.totalExpense.abs();
    final curIncome = s.totalIncome.abs();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        // 本月 vs 月均
        _row(theme, cs, L10nManager.l10n.reportLabelExpense, '¥${curExpense.toStringAsFixed(0)}',
             L10nManager.l10n.reportMonthlyAvg(ytd.monthlyAvgExpense.toStringAsFixed(0)),
             curExpense > ytd.monthlyAvgExpense ? cs.error : cs.primary),
        const SizedBox(height: 10),
        _row(theme, cs, L10nManager.l10n.reportLabelIncome, '¥${curIncome.toStringAsFixed(0)}',
             L10nManager.l10n.reportMonthlyAvg(ytd.monthlyAvgIncome.toStringAsFixed(0)),
             curIncome > ytd.monthlyAvgIncome ? cs.primary : cs.onSurfaceVariant),
        const SizedBox(height: 10),
        Divider(height: 1, color: cs.outline.withValues(alpha: 0.1)),
        const SizedBox(height: 10),
        _row(theme, cs, L10nManager.l10n.reportYtdExpense, '¥${ytd.totalExpense.toStringAsFixed(0)}',
             '${L10nManager.l10n.reportYtdIncome} ¥${ytd.totalIncome.toStringAsFixed(0)}', cs.onSurface),
        const SizedBox(height: 6),
        _row(theme, cs, L10nManager.l10n.reportYtdSavingsRate, '${ytd.savingsRate.toStringAsFixed(1)}%',
             L10nManager.l10n.reportCoverageMonths(ytd.monthsWithData, ytd.monthCount),
             ytd.savingsRate >= 20 ? cs.primary : cs.error),
      ]),
    );
  }

  Widget _row(ThemeData theme, ColorScheme cs, String label, String value,
      String sub, Color valueColor) {
    return Row(children: [
      SizedBox(width: 90, child: Text(label,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
      Expanded(child: Text(sub,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: valueColor, fontFamily: 'monospace')),
    ]);
  }
}
