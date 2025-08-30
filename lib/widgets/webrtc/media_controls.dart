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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          onPressed: onToggleMic,
          icon: Icon(micOn ? Icons.mic : Icons.mic_off),
          label: Text(micOn ? 'Mic On' : 'Mic Off'),
        ),
        const SizedBox(width: 12),
        FilledButton.tonalIcon(
          onPressed: onToggleCam,
          icon: Icon(camOn ? Icons.videocam : Icons.videocam_off),
          label: Text(camOn ? 'Cam On' : 'Cam Off'),
        ),
      ],
    );
  }
}
