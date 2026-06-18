import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.about),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: spacing.formGroupSpacing * 2),
        children: [
          _buildHeroHeader(context),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.formPadding.left),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildLinkCards(context),
                const SizedBox(height: 24),
                _buildSectionCard(
                  context,
                  title: L10nManager.l10n.features,
                  icon: Icons.star_rounded,
                  child: _buildChipList(
                    context,
                    items: [
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
                const SizedBox(height: 16),
                _buildSectionCard(
                  context,
                  title: L10nManager.l10n.technology,
                  icon: Icons.build_rounded,
                  child: _buildChipList(
                    context,
                    items: const ['Flutter', 'Dart', 'Material Design 3', 'SQLite (Drift)', 'Provider', 'WebRTC', 'Docker'],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  context,
                  title: L10nManager.l10n.openSource,
                  icon: Icons.description_rounded,
                  child: Padding(
                    padding: EdgeInsets.only(top: spacing.formItemSpacing),
                    child: Text(
                      'MIT License\n\n'
                      'Copyright (c) 2025-2026 clssw1004\n\n'
                      'Permission is hereby granted, free of charge, to any person obtaining a copy '
                      'of this software and associated documentation files (the "Software"), to deal '
                      'in the Software without restriction, including without limitation the rights '
                      'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                      'copies of the Software, and to permit persons to whom the Software is '
                      'furnished to do so, subject to the following conditions:\n\n'
                      'The above copyright notice and this permission notice shall be included in all '
                      'copies or substantial portions of the Software.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Container(
      padding: EdgeInsets.only(
        top: spacing.formGroupSpacing,
        bottom: spacing.formGroupSpacing * 1.5,
        left: spacing.formPadding.left,
        right: spacing.formPadding.right,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.4),
            colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // 应用图标
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 88,
              height: 88,
            ),
          ),
          const SizedBox(height: 20),
          // 应用名称
          Text(
            L10nManager.l10n.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          // 版本号 + 应用描述
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.connectionState == ConnectionState.done && snapshot.hasData
                  ? snapshot.data!.version
                  : '...';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      '${L10nManager.l10n.version} $version',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCards(BuildContext context) {
    return Column(
      children: [
        _buildLinkTile(
          context,
          title: L10nManager.l10n.frontendProject,
          subtitle: 'GitHub · clssw1004/clsswjz-gui',
          icon: Icons.code_rounded,
          url: 'https://github.com/clssw1004/clsswjz-gui',
        ),
        const SizedBox(height: 8),
        _buildLinkTile(
          context,
          title: L10nManager.l10n.backendProject,
          subtitle: 'GitHub · clssw1004/clsswjz-server',
          icon: Icons.dns_rounded,
          url: 'https://github.com/clssw1004/clsswjz-server',
        ),
      ],
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String url,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => _launchUrl(context, url),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
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
                onPressed: () => _copyToClipboard(context, url),
                icon: Icon(Icons.copy_rounded, size: 20),
                tooltip: L10nManager.l10n.copyLink,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChipList(BuildContext context, {required List<String> items}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: theme.spacing.formItemSpacing),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        )).toList(),
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
