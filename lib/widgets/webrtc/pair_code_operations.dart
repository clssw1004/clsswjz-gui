import 'package:flutter/material.dart';
import '../common/common_text_form_field.dart';
import '../../manager/l10n_manager.dart';

/// 配对码操作组件
class PairCodeOperations extends StatelessWidget {
  final TextEditingController sdpController;
  final bool iceGatheringComplete;
  final bool isConnecting;
  final bool showReconnectButton;
  final bool isInitiator; // 是否为发起方
  final bool isJoiner; // 是否为加入方
  final bool hasConnection; // 是否有连接
  final VoidCallback onCreateOffer;
  final VoidCallback onJoin;
  final VoidCallback onSetRemoteOnly;
  final VoidCallback? onReconnect;
  final VoidCallback? onClearCode; // 清除配对码回调

  const PairCodeOperations({
    super.key,
    required this.sdpController,
    required this.iceGatheringComplete,
    required this.isConnecting,
    required this.showReconnectButton,
    required this.isInitiator,
    required this.isJoiner,
    required this.hasConnection,
    required this.onCreateOffer,
    required this.onJoin,
    required this.onSetRemoteOnly,
    this.onReconnect,
    this.onClearCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 配对码输入区域
        Row(
          children: [
            Expanded(
              child: CommonTextFormField(
                controller: sdpController,
                labelText: l10n.pairCode,
                hintText: l10n.enterPairCode,
                maxLines: 1,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: sdpController.text.isNotEmpty ? () {
                sdpController.clear();
                onClearCode?.call();
              } : null,
              icon: const Icon(Icons.clear),
              tooltip: l10n.clearPairCode,
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
        const SizedBox(height: 20),
        
        // 操作按钮区域 - 横向排列
        Row(
          children: [
            // 发起按钮
            Expanded(
              child: FilledButton.icon(
                onPressed: _canCreateOffer() ? onCreateOffer : null,
                icon: Icon(_getCreateOfferIcon()),
                label: Text(_getCreateOfferText(l10n)),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 加入按钮
            Expanded(
              child: FilledButton.icon(
                onPressed: _canJoin() ? onJoin : null,
                icon: Icon(_getJoinIcon()),
                label: Text(_getJoinText(l10n)),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 仅设置远端按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _canSetRemoteOnly() ? onSetRemoteOnly : null,
                icon: Icon(_getSetRemoteIcon()),
                label: Text(_getSetRemoteText(l10n)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _canSetRemoteOnly() 
                    ? colorScheme.primary 
                    : colorScheme.onSurfaceVariant,
                  side: BorderSide(
                    color: _canSetRemoteOnly() 
                      ? colorScheme.primary 
                      : colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            
            // 重连按钮（仅在需要时显示）
            if (showReconnectButton && onReconnect != null) ...[
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                child: FilledButton.icon(
                  onPressed: onReconnect,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.reconnect),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        
        // ICE状态指示器
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: iceGatheringComplete 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iceGatheringComplete 
                ? colorScheme.primary 
                : colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iceGatheringComplete 
                    ? colorScheme.primary 
                    : colorScheme.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iceGatheringComplete ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
            Text(
              iceGatheringComplete ? l10n.iceGatheringComplete : l10n.iceGathering,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: iceGatheringComplete 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 判断是否可以发起连接
  bool _canCreateOffer() {
    if (isConnecting) return false;
    if (hasConnection && isInitiator) return false; // 已经是发起方且有连接
    if (sdpController.text.trim().isNotEmpty) return false; // 已有配对码
    return true;
  }

  // 判断是否可以加入连接
  bool _canJoin() {
    if (isConnecting) return false;
    if (hasConnection && isJoiner) return false; // 已经是加入方且有连接
    if (sdpController.text.trim().isEmpty) return false; // 没有配对码
    return true;
  }

  // 判断是否可以设置远端
  bool _canSetRemoteOnly() {
    if (isConnecting) return false;
    if (hasConnection) return false; // 已有连接
    if (sdpController.text.trim().isEmpty) return false; // 没有配对码
    return true;
  }

  // 获取发起按钮图标
  IconData _getCreateOfferIcon() {
    if (isConnecting) return Icons.hourglass_empty;
    if (hasConnection && isInitiator) return Icons.check_circle;
    return Icons.play_arrow;
  }

  // 获取发起按钮文本
  String _getCreateOfferText(dynamic l10n) {
    if (isConnecting) return l10n.connecting;
    if (hasConnection && isInitiator) return l10n.connected;
    return l10n.createConnection;
  }

  // 获取加入按钮图标
  IconData _getJoinIcon() {
    if (isConnecting) return Icons.hourglass_empty;
    if (hasConnection && isJoiner) return Icons.check_circle;
    return Icons.login;
  }

  // 获取加入按钮文本
  String _getJoinText(dynamic l10n) {
    if (isConnecting) return l10n.connecting;
    if (hasConnection && isJoiner) return l10n.connected;
    return l10n.joinConnection;
  }

  // 获取设置远端按钮图标
  IconData _getSetRemoteIcon() {
    if (isConnecting) return Icons.hourglass_empty;
    if (hasConnection) return Icons.check_circle;
    return Icons.visibility;
  }

  // 获取设置远端按钮文本
  String _getSetRemoteText(dynamic l10n) {
    if (isConnecting) return l10n.connecting;
    if (hasConnection) return l10n.connected;
    return l10n.setRemoteOnly;
  }
}
