import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _dailyLimitController = TextEditingController();
  String _emoji = '🏃';
  int _color = 0xFF5C6BC0;
  bool get isEditing => widget.definition != null;

  static const List<int> _presetColors = [
    0xFFE53935, 0xFFEF5350, 0xFFFF7043, 0xFFFF8A65,
    0xFFFDD835, 0xFFFFCA28, 0xFFF9A825, 0xFFFF6F00,
    0xFF43A047, 0xFF66BB6A, 0xFF26A69A, 0xFF80CBC4,
    0xFF1E88E5, 0xFF42A5F5, 0xFF5C6BC0, 0xFF7E57C2,
    0xFFAB47BC, 0xFFCE93D8, 0xFFEC407A, 0xFFF06292,
    0xFF8D6E63, 0xFFA1887F, 0xFF78909C, 0xFF90A4AE,
  ];

  static const List<Map<String, List<String>>> _emojiCategories = [
    {'运动': ['🏃', '🚶', '🏊', '🚴', '🧘', '🤸', '⛹️', '🏋️', '⚽', '🏀', '🎾', '🏸']},
    {'学习': ['📖', '✍️', '📝', '📚', '🎓', '💡', '🧠', '📌']},
    {'生活': ['💧', '🥗', '☕', '🍎', '🥦', '💊', '🦷', '🧹', '🛌', '🚿']},
    {'健康': ['❤️', '💪', '🧘‍♀️', '🌿', '🧴', '🏥', '🩺', '😌']},
    {'爱好': ['🎵', '🎨', '🎮', '🎬', '📷', '🎸', '🎹', '🎧', '✈️', '🌍']},
    {'自然': ['🌱', '🌻', '🌲', '🌸', '☀️', '🌙', '⭐', '🌈', '🍀']},
    {'其他': ['🎯', '⭐', '🔥', '💎', '🎁', '🔔', '💼', '🗂️', '🔄']},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.definition != null) {
      _nameController.text = widget.definition!.name;
      _emoji = widget.definition!.emoji;
      _color = widget.definition!.color;
      if (widget.definition!.maxDailyCount != null) {
        _dailyLimitController.text = widget.definition!.maxDailyCount.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyLimitController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _emoji.isNotEmpty;

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32, height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(L10nManager.l10n.selectEmoji,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: _emojiCategories.map((category) {
                        final name = category.keys.first;
                        final emojis = category.values.first;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: emojis.map((emoji) {
                                  final selected = _emoji == emoji;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _emoji = emoji);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? colorScheme.primaryContainer
                                            : colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(10),
                                        border: selected
                                            ? Border.all(color: colorScheme.primary, width: 2)
                                            : null,
                                      ),
                                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
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
            const SizedBox(height: 24),

            // 每日打卡上限
            TextFormField(
              controller: _dailyLimitController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: L10nManager.l10n.activityDailyLimit,
                hintText: L10nManager.l10n.activityDailyLimitUnlimited,
                suffixText: '次/天',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final limitText = _dailyLimitController.text.trim();
    final maxDailyCount = limitText.isEmpty ? null : int.tryParse(limitText);

    Navigator.pop(context, (
      name,
      _emoji,
      _color,
      maxDailyCount,
    ));
  }
}
