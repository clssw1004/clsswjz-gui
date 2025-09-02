import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// 视频渲染器组件
class VideoRendererWidget extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final String label;
  final bool isLocal;
  final bool showBorder;
  final Color? backgroundColor;

  const VideoRendererWidget({
    super.key,
    required this.renderer,
    required this.label,
    this.isLocal = false,
    this.showBorder = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: showBorder 
          ? Border.all(color: colorScheme.outlineVariant, width: 1.5)
          : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 视频渲染器
          RTCVideoView(
            renderer,
            mirror: isLocal, // 本地视频镜像显示
          ),
          // 标签
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary, width: 1),
              ),
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 视频状态指示器
          if (renderer.srcObject == null)
            Positioned.fill(
              child: Container(
                color: colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLocal ? Icons.videocam_off : Icons.videocam,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isLocal ? '本地摄像头' : '等待远端视频',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 视频显示区域组件
class VideoDisplayArea extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final Color? backgroundColor;

  const VideoDisplayArea({
    super.key,
    required this.localRenderer,
    required this.remoteRenderer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: VideoRendererWidget(
            renderer: localRenderer,
            label: '本地',
            isLocal: true,
            backgroundColor: backgroundColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VideoRendererWidget(
            renderer: remoteRenderer,
            label: '远端',
            isLocal: false,
            backgroundColor: backgroundColor,
          ),
        ),
      ],
    );
  }
}
