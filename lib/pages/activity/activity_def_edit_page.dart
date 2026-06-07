import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';

class ActivityDefEditPage extends StatefulWidget {
  final ActivityDefinitionVO? definition;

  const ActivityDefEditPage({super.key, this.definition});

  @override
  State<ActivityDefEditPage> createState() => _ActivityDefEditPageState();
}

class _ActivityDefEditPageState extends State<ActivityDefEditPage> {
  final _nameController = TextEditingController();
  String _emoji = '🏃';
  int _color = 0xFF5C6BC0;
  bool get isEditing => widget.definition != null;

  static const List<int> _presetColors = [
    0xFFE53935, 0xFFFF7043, 0xFFFDD835, 0xFF43A047,
    0xFF26A69A, 0xFF1E88E5, 0xFF5C6BC0, 0xFFAB47BC,
    0xFFEC407A, 0xFF8D6E63,
  ];

  static const List<String> _presetEmojis = [
    '🏃', '📖', '🧘', '💧', '🥗', '🎵', '✍️', '🎨',
    '🏋️', '🚴', '🧹', '🌱', '📝', '☕', '💊', '🦷',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.definition != null) {
      _nameController.text = widget.definition!.name;
      _emoji = widget.definition!.emoji;
      _color = widget.definition!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _emoji.isNotEmpty;

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10nManager.l10n.selectEmoji,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetEmojis.map((emoji) {
                  final selected = _emoji == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _emoji = emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? L10nManager.l10n.activityEdit : L10nManager.l10n.activityCreate),
        actions: [
          TextButton(
            onPressed: _isValid ? _onSave : null,
            child: Text(L10nManager.l10n.save,
                style: TextStyle(
                    color: _isValid ? null : colorScheme.onSurface.withAlpha(100))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预览卡片
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(_color).withAlpha(30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color(_color).withAlpha(80),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 4),
                    Text(_nameController.text.isEmpty ? L10nManager.l10n.name : _nameController.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Color(_color))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 名称
            Text(L10nManager.l10n.activityName,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: L10nManager.l10n.activityNameHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Emoji
            Text(L10nManager.l10n.emoji,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showEmojiPicker,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    Text(_emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text(L10nManager.l10n.clickToSelectEmoji,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 颜色
            Text(L10nManager.l10n.color,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetColors.map((c) {
                final selected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: colorScheme.onSurface, width: 3)
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: Color(c).withAlpha(100), blurRadius: 8)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(context, (
      name: name,
      emoji: _emoji,
      color: _color,
    ));
  }
}
