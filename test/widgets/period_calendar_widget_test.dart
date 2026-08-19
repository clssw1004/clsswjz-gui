import 'package:clsswjz_gui/generated/l10n/app_localizations_zh.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'package:clsswjz_gui/models/vo/period_cycle_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import 'package:clsswjz_gui/pages/period/widgets/period_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PeriodCycleVO _cycle(String start, {String? end}) => PeriodCycleVO(
      id: 'c-$start',
      startDate: start,
      endDate: end,
      createdAt: 0,
      updatedAt: 0,
    );

void main() {
  setUpAll(() {
    L10nManager.init(AppLocalizationsZh());
  });

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: child),
      );

  testWidgets('渲染月份标题与图例', (tester) async {
    await tester.pumpWidget(wrap(PeriodCalendarWidget(
      year: 2026,
      month: 8,
      cycles: const [],
      onDateTap: (_) {},
    )));

    expect(find.textContaining('2026'), findsOneWidget);
    // 星期头 + 图例
    expect(find.text('经期'), findsOneWidget);
    expect(find.text('排卵期'), findsOneWidget);
    expect(find.text('安全区'), findsOneWidget);
    expect(find.text('预测'), findsOneWidget);
  });

  testWidgets('经期日渲染经期背景色', (tester) async {
    final cycles = [_cycle('2026-08-10', end: '2026-08-12')];
    await tester.pumpWidget(wrap(PeriodCalendarWidget(
      year: 2026,
      month: 8,
      cycles: cycles,
      statistics: PeriodStatisticsVO.empty,
      onDateTap: (_) {},
    )));

    // 浅色主题下经期背景色 = 柔和粉彩 palette.periodBg（light）
    final expected = const Color(0xFFFDE9EF);

    for (final day in ['10', '11', '12']) {
      final text = find.text(day);
      expect(text, findsOneWidget, reason: '日期 $day 应渲染');
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(of: text, matching: find.byType(AnimatedContainer)).first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, expected, reason: '日期 $day 应为经期背景色');
    }
  });

  testWidgets('可预测时未来非特殊日期渲染安全期背景', (tester) async {
    // 构造可预测统计：下次经期较远，今天与下次之间为安全期
    final stats = PeriodStatisticsVO(
      averageCycleLength: 28,
      averagePeriodLength: 5,
      totalRecords: 30,
      recentCycleLengths: [28, 28],
      nextPeriodDate: _addDays(_today(), 10),
      ovulationDate: _addDays(_today(), 10 - 14),
      fertileWindowStart: _addDays(_today(), 10 - 14 - 5),
      fertileWindowEnd: _addDays(_today(), 10 - 14 + 1),
    );
    await tester.pumpWidget(wrap(PeriodCalendarWidget(
      year: DateTime.now().year,
      month: DateTime.now().month,
      cycles: const [],
      statistics: stats,
      onDateTap: (_) {},
    )));

    // 浅色主题下安全期背景色 = 柔和粉彩 palette.safeBg（light）
    final expected = const Color(0xFFE9F4ED);
    final todayDay = DateTime.now().day;

    // 今天应渲染为安全期背景（今天不在经期/易孕/预测窗口内时）
    final text = find.text('$todayDay');
    if (text.evaluate().isNotEmpty) {
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(of: text, matching: find.byType(AnimatedContainer)).first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, expected,
          reason: '今天应为安全期背景色（若不在特殊窗口内）');
    }
  });

  testWidgets('经期连续日连成胶囊条（无缝衔接）', (tester) async {
    final cycles = [_cycle('2026-08-10', end: '2026-08-12')];
    await tester.pumpWidget(wrap(PeriodCalendarWidget(
      year: 2026,
      month: 8,
      cycles: cycles,
      statistics: PeriodStatisticsVO.empty,
      onDateTap: (_) {},
    )));

    AnimatedContainer cellOf(String day) => tester.widget<AnimatedContainer>(
          find
              .ancestor(
                  of: find.text(day),
                  matching: find.byType(AnimatedContainer))
              .first,
        );

    // 中间日（11 号）：左右无缝衔接 + 无圆角
    final mid = cellOf('11');
    expect(mid.margin, const EdgeInsets.fromLTRB(0, 2, 0, 2));
    final midDeco = mid.decoration as BoxDecoration;
    expect(midDeco.borderRadius,
        BorderRadius.horizontal(left: Radius.circular(0), right: Radius.circular(0)));

    // 首日（10 号）：左圆角、右侧无缝
    final first = cellOf('10');
    expect(first.margin, const EdgeInsets.fromLTRB(2, 2, 0, 2));
    final firstDeco = first.decoration as BoxDecoration;
    expect(firstDeco.borderRadius,
        BorderRadius.horizontal(left: Radius.circular(10), right: Radius.circular(0)));

    // 末日（12 号）：左侧无缝、右圆角
    final last = cellOf('12');
    expect(last.margin, const EdgeInsets.fromLTRB(0, 2, 2, 2));
    final lastDeco = last.decoration as BoxDecoration;
    expect(lastDeco.borderRadius,
        BorderRadius.horizontal(left: Radius.circular(0), right: Radius.circular(10)));
  });

  testWidgets('暗色主题下经期背景色适配更亮', (tester) async {
    final cycles = [_cycle('2026-08-10', end: '2026-08-12')];
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: PeriodCalendarWidget(
          year: 2026,
          month: 8,
          cycles: cycles,
          statistics: PeriodStatisticsVO.empty,
          onDateTap: (_) {},
        ),
      ),
    ));

    // 暗色主题下经期背景色 = 柔和粉彩 palette.periodBg（dark）
    final expected = const Color(0xFF482230);

    final text = find.text('10');
    final container = tester.widget<AnimatedContainer>(
      find.ancestor(of: text, matching: find.byType(AnimatedContainer)).first,
    );
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration?.color, expected);
  });

  testWidgets('点击日期触发回调', (tester) async {
    String? tapped;
    final now = DateTime.now();
    await tester.pumpWidget(wrap(PeriodCalendarWidget(
      year: now.year,
      month: now.month,
      cycles: const [],
      onDateTap: (d) => tapped = d,
    )));

    // 1 号必然不是未来日期，可点击
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(tapped, isNotNull);
    expect(tapped, endsWith('-01'));
  });

  testWidgets('未来月份日期不可点击', (tester) async {
    String? tapped;
    final now = DateTime.now();
    final nextYear = now.month == 12 ? now.year + 1 : now.year;
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    await tester.pumpWidget(wrap(PeriodCalendarWidget(
      year: nextYear,
      month: nextMonth,
      cycles: const [],
      onDateTap: (d) => tapped = d,
    )));

    // 下个月的任何日期都晚于今天，不可点击
    await tester.tap(find.text('15'));
    await tester.pump();
    expect(tapped, isNull);
  });
}

String _today() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _addDays(String date, int days) {
  final d = DateTime.parse(date).add(Duration(days: days));
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
