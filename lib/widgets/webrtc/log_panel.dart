import 'package:flutter/material.dart';

/// 日志面板组件
class LogPanel extends StatelessWidget {
  final List<String> logs;
  final VoidCallback onClear;
  final String title;
  final double height;

  const LogPanel({
    super.key,
    required this.logs,
    required this.onClear,
    this.title = '日志',
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.titleSmall),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      '暂无日志',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        logs[i],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
