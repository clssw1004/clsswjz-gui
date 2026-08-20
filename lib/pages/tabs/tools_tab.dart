import 'package:flutter/material.dart';

import '../../manager/l10n_manager.dart';
import '../../widgets/common/common_app_bar.dart';
import '../tools/feature_hub_body.dart';

/// 「工具/工作台」底部 Tab。
///
/// 承接所有扩展功能入口（记事/报表/经期/打卡等），按分组宫格展示，
/// 与「我的」Tab 解耦，避免扩展功能继续堆积在个人中心。
class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.tabTools),
        showBackButton: false,
        centerTitle: false,
      ),
      body: const FeatureHubBody(),
    );
  }
}
