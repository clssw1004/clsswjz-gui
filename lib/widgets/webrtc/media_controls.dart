import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';

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
    final l10n = L10nManager.l10n;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.control_camera,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                  Text(
                    l10n.videoControl,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 媒体控制按钮
            Row(
              children: [
                Expanded(
                  child: _buildControlButton(
                    theme,
                    colorScheme,
                    icon: micOn ? Icons.mic : Icons.mic_off,
                    label: micOn ? l10n.microphoneOn : l10n.microphoneOff,
                    isActive: micOn,
                    onPressed: onToggleMic,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildControlButton(
                    theme,
                    colorScheme,
                    icon: camOn ? Icons.videocam : Icons.videocam_off,
                    label: camOn ? l10n.cameraOn : l10n.cameraOff,
                    isActive: camOn,
                    onPressed: onToggleCam,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: isActive 
                ? colorScheme.primary 
                : colorScheme.surfaceContainerHighest,
            foregroundColor: isActive 
                ? colorScheme.onPrimary 
                : colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
