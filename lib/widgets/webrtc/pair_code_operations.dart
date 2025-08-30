import 'package:flutter/material.dart';

/// 配对码操作组件
class PairCodeOperations extends StatelessWidget {
  final TextEditingController sdpController;
  final bool iceGatheringComplete;
  final bool isConnecting;
  final bool showReconnectButton;
  final VoidCallback onCreateOffer;
  final VoidCallback onJoin;
  final VoidCallback onSetRemoteOnly;
  final VoidCallback onTestTurn;
  final VoidCallback onCheckVideoStatus;
  final VoidCallback? onReconnect;

  const PairCodeOperations({
    super.key,
    required this.sdpController,
    required this.iceGatheringComplete,
    required this.isConnecting,
    required this.showReconnectButton,
    required this.onCreateOffer,
    required this.onJoin,
    required this.onSetRemoteOnly,
    required this.onTestTurn,
    required this.onCheckVideoStatus,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: sdpController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: '输入6位配对码（自动复制到剪贴板）。粘贴对方的配对码到这里。',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(24),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            // 发起按钮
            FilledButton.tonal(
              onPressed: isConnecting ? null : onCreateOffer,
              child: Text(isConnecting ? '连接中...' : '发起（生成6位码）'),
            ),
            const SizedBox(height: 8),
            
            // 加入按钮
            FilledButton.tonal(
              onPressed: isConnecting ? null : onJoin,
              child: Text(isConnecting ? '连接中...' : '加入（粘贴6位码）'),
            ),
            const SizedBox(height: 8),
            
            // 仅设置远端按钮
            FilledButton.tonal(
              onPressed: isConnecting ? null : onSetRemoteOnly,
              child: Text(isConnecting ? '连接中...' : '仅设置远端'),
            ),
            const SizedBox(height: 8),
            
            // 测试TURN按钮
            FilledButton.tonal(
              onPressed: isConnecting ? null : onTestTurn,
              child: const Text('测试TURN'),
            ),
            const SizedBox(height: 8),
            
            // 检查视频状态按钮
            FilledButton.tonal(
              onPressed: onCheckVideoStatus,
              child: const Text('检查视频状态'),
            ),
            const SizedBox(height: 8),
            
            // 重新连接按钮（条件显示）
            if (showReconnectButton && onReconnect != null)
              FilledButton.tonal(
                onPressed: onReconnect,
                child: const Text('重新连接'),
              ),
            if (showReconnectButton && onReconnect != null)
              const SizedBox(height: 8),
            
            // ICE状态指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: iceGatheringComplete 
                  ? colorScheme.primaryContainer 
                  : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                iceGatheringComplete ? '✅ ICE 已收集完成' : '⏳ 收集中 ICE…',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: iceGatheringComplete 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
