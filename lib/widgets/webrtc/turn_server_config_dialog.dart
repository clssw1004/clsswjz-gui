import 'package:flutter/material.dart';

/// TURN服务器配置对话框组件
class TurnServerConfigDialog extends StatefulWidget {
  final String initialIp;
  final String initialPort;
  final String initialUser;
  final String initialPass;
  final String initialRealm;
  final Function(String ip, String port, String user, String pass, String realm) onApply;

  const TurnServerConfigDialog({
    super.key,
    required this.initialIp,
    required this.initialPort,
    required this.initialUser,
    required this.initialPass,
    required this.initialRealm,
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
    _ipController = TextEditingController(text: widget.initialIp);
    _portController = TextEditingController(text: widget.initialPort);
    _userController = TextEditingController(text: widget.initialUser);
    _passController = TextEditingController(text: widget.initialPass);
    _realmController = TextEditingController(text: widget.initialRealm);
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

  void _applyConfig() {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();
    final realm = _realmController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TURN IP和端口不能为空')),
      );
      return;
    }

    widget.onApply(ip, port, user, pass, realm);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'TURN 服务器配置',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: '关闭',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 服务器地址配置
            Text(
              '服务器地址',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'TURN IP 地址',
                      hintText: '例如: 139.224.41.190',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.computer),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: '端口',
                      hintText: '3478',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.router),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 认证配置
            Text(
              '认证信息',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      hintText: '例如: clssw',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _passController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      hintText: '例如: 123456',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _realmController,
                    decoration: const InputDecoration(
                      labelText: 'Realm',
                      hintText: '例如: clssw',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.domain),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 说明文本
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TURN服务器用于在NAT环境下建立P2P连接。配置正确的服务器信息可以提高连接成功率。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _applyConfig,
                  child: const Text('应用配置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
