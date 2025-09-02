import 'package:flutter/material.dart';

/// 媒体控制组件
class MediaControls extends StatelessWidget {
  final bool micOn;
  final bool camOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;

  const MediaControls({
    super.key,
    required this.micOn,
    required this.camOn,
    required this.onToggleMic,
    required this.onToggleCam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '媒体控制',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 媒体控制按钮
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onToggleMic,
                    icon: Icon(micOn ? Icons.mic : Icons.mic_off),
                    label: Text(micOn ? '麦克风开启' : '麦克风关闭'),
                    style: FilledButton.styleFrom(
                      backgroundColor: micOn 
                        ? colorScheme.primaryContainer 
                        : colorScheme.surfaceContainerHighest,
                      foregroundColor: micOn 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onToggleCam,
                    icon: Icon(camOn ? Icons.videocam : Icons.videocam_off),
                    label: Text(camOn ? '摄像头开启' : '摄像头关闭'),
                    style: FilledButton.styleFrom(
                      backgroundColor: camOn 
                        ? colorScheme.primaryContainer 
                        : colorScheme.surfaceContainerHighest,
                      foregroundColor: camOn 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
