import 'package:flutter/material.dart';
import '../common/common_text_form_field.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 配对码输入区域
        Row(
          children: [
            Expanded(
              child: CommonTextFormField(
                controller: sdpController,
                labelText: '配对码',
                hintText: '输入或粘贴6位配对码',
                maxLines: 1,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: sdpController.text.isNotEmpty ? () {
                sdpController.clear();
                onClearCode?.call();
              } : null,
              icon: const Icon(Icons.clear),
              tooltip: '清除配对码',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 操作按钮区域 - 横向排列
        Row(
          children: [
            // 发起按钮
            Expanded(
              child: FilledButton.icon(
                onPressed: _canCreateOffer() ? onCreateOffer : null,
                icon: Icon(_getCreateOfferIcon()),
                label: Text(_getCreateOfferText()),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 加入按钮
            Expanded(
              child: FilledButton.icon(
                onPressed: _canJoin() ? onJoin : null,
                icon: Icon(_getJoinIcon()),
                label: Text(_getJoinText()),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 仅设置远端按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _canSetRemoteOnly() ? onSetRemoteOnly : null,
                icon: Icon(_getSetRemoteIcon()),
                label: Text(_getSetRemoteText()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _canSetRemoteOnly() 
                    ? colorScheme.primary 
                    : colorScheme.onSurfaceVariant,
                  side: BorderSide(
                    color: _canSetRemoteOnly() 
                      ? colorScheme.primary 
                      : colorScheme.outlineVariant,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            // 重连按钮（仅在需要时显示）
            if (showReconnectButton && onReconnect != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: FilledButton.icon(
                  onPressed: onReconnect,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重连'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        
        // ICE状态指示器
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: iceGatheringComplete 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: iceGatheringComplete 
                ? colorScheme.primary 
                : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iceGatheringComplete ? Icons.check_circle : Icons.schedule,
                size: 16,
                color: iceGatheringComplete 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                iceGatheringComplete ? 'ICE 已收集完成' : 'ICE 收集中...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: iceGatheringComplete 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
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
  String _getCreateOfferText() {
    if (isConnecting) return '连接中...';
    if (hasConnection && isInitiator) return '已发起';
    return '发起连接';
  }

  // 获取加入按钮图标
  IconData _getJoinIcon() {
    if (isConnecting) return Icons.hourglass_empty;
    if (hasConnection && isJoiner) return Icons.check_circle;
    return Icons.login;
  }

  // 获取加入按钮文本
  String _getJoinText() {
    if (isConnecting) return '连接中...';
    if (hasConnection && isJoiner) return '已加入';
    return '加入连接';
  }

  // 获取设置远端按钮图标
  IconData _getSetRemoteIcon() {
    if (isConnecting) return Icons.hourglass_empty;
    if (hasConnection) return Icons.check_circle;
    return Icons.visibility;
  }

  // 获取设置远端按钮文本
  String _getSetRemoteText() {
    if (isConnecting) return '连接中...';
    if (hasConnection) return '已设置';
    return '仅设置远端';
  }
}
