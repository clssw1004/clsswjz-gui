import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.about),
      ),
      body: ListView(
        children: [
          // 应用图标和名称区域
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // 应用图标
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 96,
                    height: 96,
                  ),
                ),
                const SizedBox(height: 24),
                // 应用名称
                Text(
                  L10nManager.l10n.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                // 版本号
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '${L10nManager.l10n.version}: 1.0.0-alpha.1',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 开源地址
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10nManager.l10n.openSource,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLinkCard(
                  context,
                  title: L10nManager.l10n.frontendProject,
                  subtitle: 'https://github.com/clssw1004/clsswjz-gui',
                  icon: Icons.code,
                  onTap: () => _launchUrl(context, 'https://github.com/clssw1004/clsswjz-gui'),
                  onCopy: () => _copyToClipboard(context, 'https://github.com/clssw1004/clsswjz-gui'),
                ),
                const SizedBox(height: 12),
                _buildLinkCard(
                  context,
                  title: L10nManager.l10n.backendProject,
                  subtitle: 'https://github.com/clssw1004/clsswjz-server',
                  icon: Icons.dns_outlined,
                  onTap: () => _launchUrl(context, 'https://github.com/clssw1004/clsswjz-server'),
                  onCopy: () => _copyToClipboard(context, 'https://github.com/clssw1004/clsswjz-server'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 功能介绍
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildSection(
              context,
              title: L10nManager.l10n.features,
              content: [
                L10nManager.l10n.featureMultiUser,
                L10nManager.l10n.featureMultiBook,
                L10nManager.l10n.featureMultiCurrency,
                L10nManager.l10n.featureDataBackup,
                L10nManager.l10n.featureDataSync,
                L10nManager.l10n.featureCustomTheme,
                L10nManager.l10n.featureMultiLanguage,
              ],
            ),
          ),
          const Divider(height: 1),
          // 技术栈
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildSection(
              context,
              title: L10nManager.l10n.technology,
              content: [
                'Flutter',
                'Material Design 3',
                'SQLite',
                'Provider',
                'Drift',
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<String> content,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...content.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLinkCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_outlined),
                tooltip: L10nManager.l10n.copyLink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'https') {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        throw Exception(L10nManager.l10n.unsupportedLinkType);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtil.showError(L10nManager.l10n.cannotOpenLink(e.toString()));
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ToastUtil.showSuccess(L10nManager.l10n.linkCopied);
    }
  }
}
