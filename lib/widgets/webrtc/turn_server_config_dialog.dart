import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/webrtc_config_dto.dart';
import '../common/common_text_form_field.dart';

/// TURN服务器配置对话框组件
class TurnServerConfigDialog extends StatefulWidget {
  final WebRTCConfigDTO initialConfig;
  final Function(WebRTCConfigDTO config) onApply;

  const TurnServerConfigDialog({
    super.key,
    required this.initialConfig,
    required this.onApply,
  });

  @override
  State<TurnServerConfigDialog> createState() => _TurnServerConfigDialogState();
}

class _TurnServerConfigDialogState extends State<TurnServerConfigDialog> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _userController;
  late final TextEditingController _passController;
  late final TextEditingController _realmController;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.initialConfig.turnIp);
    _portController = TextEditingController(text: widget.initialConfig.turnPort);
    _userController = TextEditingController(text: widget.initialConfig.turnUser);
    _passController = TextEditingController(text: widget.initialConfig.turnPass);
    _realmController = TextEditingController(text: widget.initialConfig.turnRealm);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passController.dispose();
    _realmController.dispose();
    super.dispose();
  }

  void _applyConfig() async {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();
    final realm = _realmController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10nManager.l10n.required)),
      );
      return;
    }

    final config = WebRTCConfigDTO(
      turnIp: ip,
      turnPort: port,
      turnUser: user,
      turnPass: pass,
      turnRealm: realm,
    );
    
    // 保存配置到AppConfigManager
    await AppConfigManager.instance.setWebRTCConfig(config);
    
    widget.onApply(config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.serverConfig,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        foregroundColor: colorScheme.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // 服务器地址配置
                _buildSectionHeader(theme, colorScheme, l10n.serverAddress),
                const SizedBox(height: 16),
                // IP地址和端口输入框放在一行
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CommonTextFormField(
                        controller: _ipController,
                        labelText: l10n.serverAddress,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 1,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: CommonTextFormField(
                        controller: _portController,
                        labelText: l10n.port,
                        hintText: '3478',
                        keyboardType: TextInputType.number,
                        required: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: theme.textTheme.bodyLarge,
                        maxLines: 1,
                        minLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 认证配置
                _buildSectionHeader(theme, colorScheme, l10n.authenticationConfig),
                const SizedBox(height: 16),
                // Realm输入框放在用户名上面
                CommonTextFormField(
                  controller: _realmController,
                  labelText: l10n.realm,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                // 用户名输入框
                CommonTextFormField(
                  controller: _userController,
                  labelText: l10n.username,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                // 密码输入框
                CommonTextFormField(
                  controller: _passController,
                  labelText: l10n.password,
                  obscureText: true,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  minLines: 1,
                ),
                const SizedBox(height: 24),
                
                // 说明文本
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'TURN server helps establish P2P connections behind NAT for better connectivity.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _applyConfig,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.confirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, ColorScheme colorScheme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
