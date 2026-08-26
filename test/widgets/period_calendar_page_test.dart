import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/database/tables/period_cycle_table.dart';
import 'package:clsswjz_gui/database/tables/period_daily_record_table.dart';
import 'package:clsswjz_gui/generated/l10n/app_localizations_zh.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/manager/cache_manager.dart';
import 'package:clsswjz_gui/manager/dao_manager.dart';
import 'package:clsswjz_gui/manager/database_manager.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'package:clsswjz_gui/pages/period/period_calendar_page.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/providers/shared_module_provider.dart';
import 'package:clsswjz_gui/theme/theme_radius.dart';
import 'package:clsswjz_gui/theme/theme_spacing.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'test-user-1';
  late AppDatabase db;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': userId,
      'period_onboarding_done': true, // 避免进入引导弹窗阻塞测试
    });
    await CacheManager.init();
    await AppConfigManager.init();
    L10nManager.init(AppLocalizationsZh());
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseManager.setDbForTest(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpPage(WidgetTester tester,
      {bool dismissOnboarding = true}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PeriodRecordProvider()..loadRecords()),
          // 页面 _loadSharedUsers 需要（v1.5.0 共享功能引入）
          ChangeNotifierProvider(create: (_) => SharedModuleProvider()),
        ],
        child: MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: const [
              ThemeSpacing(),
              ThemeRadius(radius: 8),
            ],
          ),
          home: const PeriodCalendarPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 无数据用例会触发引导弹窗，自动点"跳过"关闭，避免阻塞后续交互
    if (dismissOnboarding &&
        find.text('欢迎使用经期记录').evaluate().isNotEmpty) {
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
    }
  }

  group('经期日历页底部操作面板', () {
    testWidgets('点击已记录的历史周期日期：显示明细操作，不出现补记', (tester) async {
      // 历史周期 08-10 ~ 08-14（已结束）
      await DaoManager.periodCycleDao.insert(PeriodCycleTable.toCreateCompanion(
        userId,
        startDate: '2026-08-10',
        endDate: '2026-08-14',
      ));
      await pumpPage(tester);

      // 点击周期内的日期 08-12
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();

      // 底部面板出现：可记录/编辑每日详情 + 可删除整个周期
      expect(find.text('记录每日详情'), findsOneWidget);
      expect(find.text('删除整个经期'), findsOneWidget);
      // 已记录日期不再出现补记操作
      expect(find.text('补记经期'), findsNothing);
    });

    testWidgets('历史周期内的日期可删除单日明细', (tester) async {
      final cycleCompanion = PeriodCycleTable.toCreateCompanion(
        userId,
        startDate: '2026-08-10',
        endDate: '2026-08-14',
      );
      await DaoManager.periodCycleDao.insert(cycleCompanion);
      final cycles = await DaoManager.periodCycleDao.findAllCycles(userId);
      // 08-12 已有明细
      await DaoManager.periodDailyRecordDao.insert(
        PeriodDailyRecordTable.toCreateCompanion(
          userId,
          cycleId: cycles.first.id,
          recordDate: '2026-08-12',
          flowLevel: 'medium',
          symptoms: ['cramps'],
          mood: 'bad',
        ),
      );
      await pumpPage(tester);

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();

      // 已记录标记 + 仅删除当天 + 删除整个经期
      expect(find.text('已记录当天详情'), findsOneWidget);
      expect(find.text('仅删除当天'), findsOneWidget);
      expect(find.text('删除整个经期'), findsOneWidget);
    });

    testWidgets('点击历史空白日：显示补记操作', (tester) async {
      await pumpPage(tester);
      // 当前月无任何周期，08-05 是历史空白日
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(find.text('补记经期'), findsOneWidget);
    });

    testWidgets('点击今天（无周期）：显示标记经期开始', (tester) async {
      await pumpPage(tester);
      final today = DateTime.now();

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      // 面板与 hero 卡（无数据引导）都可能有"标记经期开始"，断言至少出现
      expect(find.text('标记经期开始'), findsWidgets);
    });

    testWidgets('面板可关闭', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(find.text('补记经期'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('补记经期'), findsNothing);
    });

    testWidgets('补记弹窗：结束日期必填，无"经期进行中"开关', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('补记经期'));
      await tester.pumpAndSettle();

      // 补记历史不允许"进行中"：不出现 Switch 开关
      expect(find.byType(Switch), findsNothing);
      // 结束日期未选择时，确认按钮禁用（confirm 文案实际为"确定"）
      final confirmBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '确定'),
      );
      expect(confirmBtn.onPressed, isNull,
          reason: '补记必须填写结束日期才能确认');
    });
  });
}
