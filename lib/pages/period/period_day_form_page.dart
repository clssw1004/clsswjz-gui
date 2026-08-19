import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'widgets/period_daily_detail_sheet.dart';

/// 经期日记录页面
///
/// 打开后直接弹出每日明细表单，保存后自动返回。
class PeriodDayFormPage extends StatelessWidget {
  final String recordDate;

  const PeriodDayFormPage({
    super.key,
    required this.recordDate,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PeriodRecordProvider>();
    final existing = provider.getDailyRecordByDate(recordDate);

    // 直接弹出明细表单
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        PeriodDailyDetailSheet.show(
          context,
          date: recordDate,
          existing: existing,
          onSave: (data) async {
            await provider.upsertDailyRecord(
              recordDate,
              flowLevel: data.flowLevel,
              symptoms: data.symptoms,
              mood: data.mood,
              remark: data.remark,
            );
          },
        ).then((_) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });

    return Scaffold(
      appBar: CommonAppBar(title: Text(L10nManager.l10n.periodDailyRecord)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
