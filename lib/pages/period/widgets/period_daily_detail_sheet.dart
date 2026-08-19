import 'package:flutter/material.dart';
import 'package:clsswjz_gui/models/vo/period_daily_record_vo.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';

/// 每日明细保存数据
class PeriodDailyRecordData {
  final String? flowLevel;
  final List<String>? symptoms;
  final String? mood;
  final String? remark;

  const PeriodDailyRecordData({
    this.flowLevel,
    this.symptoms,
    this.mood,
    this.remark,
  });
}

/// 经期每日明细弹窗
///
/// 用于记录/编辑某一天的流量、症状、情绪等信息。
class PeriodDailyDetailSheet extends StatefulWidget {
  final String date;
  final PeriodDailyRecordVO? existing;
  final Future<void> Function(PeriodDailyRecordData) onSave;

  const PeriodDailyDetailSheet({
    super.key,
    required this.date,
    this.existing,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String date,
    PeriodDailyRecordVO? existing,
    required Future<void> Function(PeriodDailyRecordData) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PeriodDailyDetailSheet(
        date: date,
        existing: existing,
        onSave: onSave,
      ),
    );
  }

  @override
  State<PeriodDailyDetailSheet> createState() => _PeriodDailyDetailSheetState();
}

class _PeriodDailyDetailSheetState extends State<PeriodDailyDetailSheet> {
  String? _flowLevel;
  List<String> _symptoms = [];
  String? _mood;
  final _remarkController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _flowLevel = widget.existing!.flowLevel.code;
      _symptoms = List.from(widget.existing!.symptoms);
      _mood = widget.existing!.mood.code;
      _remarkController.text = widget.existing!.remark ?? '';
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${l10n.periodDailyRecord} - ${widget.date}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            // 流量
            Text(l10n.periodFlowLevel, style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500, color: cs.onSurfaceVariant,
            )),
            const SizedBox(height: 8),
            _buildFlowChips(cs, theme),
            const SizedBox(height: 16),

            // 症状
            Text(l10n.periodSymptoms, style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500, color: cs.onSurfaceVariant,
            )),
            const SizedBox(height: 8),
            _buildSymptomChips(cs, theme),
            const SizedBox(height: 16),

            // 情绪
            Text(l10n.periodMood, style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500, color: cs.onSurfaceVariant,
            )),
            const SizedBox(height: 8),
            _buildMoodChips(cs, theme),
            const SizedBox(height: 16),

            // 备注
            Text(l10n.periodRemark, style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500, color: cs.onSurfaceVariant,
            )),
            const SizedBox(height: 8),
            TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                hintText: l10n.periodRemarkHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _handleSave,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowChips(ColorScheme cs, ThemeData theme) {
    final levels = ['none', 'light', 'medium', 'heavy'];
    final labels = {
      'none': L10nManager.l10n.periodFlowNone,
      'light': L10nManager.l10n.periodFlowLight,
      'medium': L10nManager.l10n.periodFlowMedium,
      'heavy': L10nManager.l10n.periodFlowHeavy,
    };
    final colors = {
      'none': cs.outline,
      'light': cs.primary.withAlpha(100),
      'medium': cs.primary,
      'heavy': cs.error,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: levels.map((level) {
        final selected = _flowLevel == level;
        return ChoiceChip(
          label: Text(labels[level] ?? level),
          selected: selected,
          selectedColor: colors[level]?.withAlpha(30),
          labelStyle: TextStyle(
            color: selected ? colors[level] : cs.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: selected ? BorderSide(color: colors[level]!) : null,
          onSelected: (_) => setState(() => _flowLevel = level),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomChips(ColorScheme cs, ThemeData theme) {
    final symptoms = [
      'headache', 'cramps', 'bloating', 'backPain',
      'fatigue', 'moodSwing', 'breast', 'nausea',
    ];
    final labels = {
      'headache': L10nManager.l10n.symptomHeadache,
      'cramps': L10nManager.l10n.symptomCramps,
      'bloating': L10nManager.l10n.symptomBloating,
      'backPain': L10nManager.l10n.symptomBackPain,
      'fatigue': L10nManager.l10n.symptomFatigue,
      'moodSwing': L10nManager.l10n.symptomMoodSwing,
      'breast': L10nManager.l10n.symptomBreast,
      'nausea': L10nManager.l10n.symptomNausea,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symptoms.map((s) {
        final selected = _symptoms.contains(s);
        return FilterChip(
          label: Text(labels[s] ?? s),
          selected: selected,
          selectedColor: cs.primaryContainer,
          onSelected: (value) {
            setState(() {
              if (value) {
                _symptoms.add(s);
              } else {
                _symptoms.remove(s);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMoodChips(ColorScheme cs, ThemeData theme) {
    final moods = ['good', 'normal', 'bad', 'terrible'];
    final labels = {
      'good': L10nManager.l10n.moodGood,
      'normal': L10nManager.l10n.moodNormal,
      'bad': L10nManager.l10n.moodBad,
      'terrible': L10nManager.l10n.moodTerrible,
    };
    final icons = {
      'good': Icons.sentiment_satisfied,
      'normal': Icons.sentiment_neutral,
      'bad': Icons.sentiment_dissatisfied,
      'terrible': Icons.sentiment_very_dissatisfied,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moods.map((m) {
        final selected = _mood == m;
        return ChoiceChip(
          avatar: Icon(icons[m], size: 18,
            color: selected ? cs.primary : cs.onSurfaceVariant),
          label: Text(labels[m] ?? m),
          selected: selected,
          selectedColor: cs.primaryContainer,
          onSelected: (_) => setState(() => _mood = m),
        );
      }).toList(),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await widget.onSave(PeriodDailyRecordData(
      flowLevel: _flowLevel,
      symptoms: _symptoms.isNotEmpty ? _symptoms : null,
      mood: _mood,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    ));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
