import 'package:flutter/material.dart';
import '../common/common_text_form_field.dart';

/// 简化的房间操作组件
class SimpleRoomOperations extends StatefulWidget {
  final TextEditingController roomCodeController;
  final bool isConnecting;
  final bool showReconnectButton;
  final bool hasConnection;
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;
  final VoidCallback? onReconnect;
  final VoidCallback? onClearCode;
  final bool isWaitingForAnswer;

  const SimpleRoomOperations({
    super.key,
    required this.roomCodeController,
    required this.isConnecting,
    required this.showReconnectButton,
    required this.hasConnection,
    required this.onCreateRoom,
    required this.onJoinRoom,
    this.onReconnect,
    this.onClearCode,
    this.isWaitingForAnswer = false,
  });

  @override
  State<SimpleRoomOperations> createState() => _SimpleRoomOperationsState();
}

class _SimpleRoomOperationsState extends State<SimpleRoomOperations> {
  @override
  void initState() {
    super.initState();
    // 监听房间码输入框变化
    widget.roomCodeController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 房间码输入区域
        Row(
          children: [
            Expanded(
              child: CommonTextFormField(
                controller: widget.roomCodeController,
                labelText: '房间码',
                hintText: '输入6位房间码',
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
              onPressed: widget.roomCodeController.text.isNotEmpty ? () {
                widget.roomCodeController.clear();
                widget.onClearCode?.call();
              } : null,
              icon: const Icon(Icons.clear),
              tooltip: '清除房间码',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 操作按钮区域
        Row(
          children: [
            // 创建房间按钮
            Expanded(
              child: FilledButton.icon(
                onPressed: _canCreateRoom() ? widget.onCreateRoom : null,
                icon: Icon(_getCreateRoomIcon()),
                label: Text(_getCreateRoomText()),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 加入房间按钮
            Expanded(
              child: FilledButton.icon(
                onPressed: _canJoinRoom() ? widget.onJoinRoom : null,
                icon: Icon(_getJoinRoomIcon()),
                label: Text(_getJoinRoomText()),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            // 重连按钮（仅在需要时显示）
            if (widget.showReconnectButton && widget.onReconnect != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: FilledButton.icon(
                  onPressed: widget.onReconnect,
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
        
        // 连接状态指示器
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.hasConnection 
              ? colorScheme.primaryContainer 
              : widget.isWaitingForAnswer
                ? colorScheme.tertiaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.hasConnection 
                ? colorScheme.primary 
                : widget.isWaitingForAnswer
                  ? colorScheme.tertiary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.hasConnection 
                  ? Icons.check_circle 
                  : widget.isWaitingForAnswer
                    ? Icons.schedule
                    : Icons.signal_wifi_off,
                size: 16,
                color: widget.hasConnection 
                  ? colorScheme.primary 
                  : widget.isWaitingForAnswer
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                widget.hasConnection 
                  ? '已连接' 
                  : widget.isWaitingForAnswer
                    ? '等待对方加入...'
                    : '未连接',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.hasConnection 
                    ? colorScheme.onPrimaryContainer 
                    : widget.isWaitingForAnswer
                      ? colorScheme.onTertiaryContainer
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

  // 判断是否可以创建房间
  bool _canCreateRoom() {
    if (widget.isConnecting) return false;
    if (widget.roomCodeController.text.trim().isNotEmpty) return false; // 已有房间码
    return true; // 只要没有房间码就可以创建
  }

  // 判断是否可以加入房间
  bool _canJoinRoom() {
    final canJoin = !widget.isConnecting && widget.roomCodeController.text.trim().isNotEmpty;
    debugPrint('🔍 _canJoinRoom: isConnecting=${widget.isConnecting}, hasRoomCode=${widget.roomCodeController.text.trim().isNotEmpty}, canJoin=$canJoin');
    return canJoin;
  }

  // 获取创建房间按钮图标
  IconData _getCreateRoomIcon() {
    if (widget.isWaitingForAnswer) return Icons.schedule;
    if (widget.isConnecting) return Icons.hourglass_empty;
    if (widget.hasConnection) return Icons.check_circle;
    return Icons.add_circle;
  }

  // 获取创建房间按钮文本
  String _getCreateRoomText() {
    if (widget.isWaitingForAnswer) return '等待加入...';
    if (widget.isConnecting) return '创建中...';
    if (widget.hasConnection) return '已连接';
    return '创建房间';
  }

  // 获取加入房间按钮图标
  IconData _getJoinRoomIcon() {
    if (widget.isConnecting) return Icons.hourglass_empty;
    if (widget.hasConnection) return Icons.check_circle;
    return Icons.login;
  }

  // 获取加入房间按钮文本
  String _getJoinRoomText() {
    if (widget.isConnecting) return '连接中...';
    if (widget.hasConnection) return '已连接';
    return '加入房间';
  }
}
