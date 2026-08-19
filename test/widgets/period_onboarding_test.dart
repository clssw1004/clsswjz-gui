import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/generated/l10n/app_localizations_zh.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/manager/cache_manager.dart';
import 'package:clsswjz_gui/manager/database_manager.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'package:clsswjz_gui/pages/period/period_calendar_page.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
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
    // 模拟真实首次安装：只设置用户 ID，不设置 period_onboarding_done（保持 false）
    SharedPreferences.setMockInitialValues({'user_id': userId});
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

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PeriodRecordProvider()..loadRecords(),
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
    // 等待 loadRecords 与 postFrameCallback 完成
    await tester.pumpAndSettle();
  }

  testWidgets('首次进入无数据时弹出经期引导', (tester) async {
    // 确认前置状态：无数据 + 引导标志为 false
    expect(AppConfigManager.instance.periodOnboardingDone, isFalse);
    final provider = PeriodRecordProvider();
    await provider.loadRecords();
    expect(provider.cycles, isEmpty);
    expect(provider.statistics.totalRecords, 0);

    await pumpPage(tester);

    // 引导底部弹窗应出现
    expect(find.text('欢迎使用经期记录'), findsOneWidget,
        reason: '首次进入应弹出经期引导');
  });

  testWidgets('跳过后再次进入仍显示引导（直到录入数据）', (tester) async {
    await pumpPage(tester);
    expect(find.text('欢迎使用经期记录'), findsOneWidget);

    // 用户点击"跳过"
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();
    expect(find.text('欢迎使用经期记录'), findsNothing);

    // 卸载页面后再重新进入（模拟离开再进入，确保 initState 重新执行）
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await pumpPage(tester);

    expect(find.text('欢迎使用经期记录'), findsOneWidget,
        reason: '未录入数据前每次进入都应看到引导');
  });
}
