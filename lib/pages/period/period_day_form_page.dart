import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/enums/flow_level.dart';
import 'package:clsswjz_gui/enums/period_mood.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/constants/period_symptoms.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';

/// 分组卡片式经期日记录表单
///
/// 每个字段组包裹在卡片容器中，视觉层次更清晰
class PeriodDayFormPage extends StatefulWidget {
  final String recordDate;
  final PeriodRecordVO? record;

  const PeriodDayFormPage({
    super.key,
    required this.recordDate,
    this.record,
  });

  @override
  State<PeriodDayFormPage> createState() => _PeriodDayFormPageState();
}

class _PeriodDayFormPageState extends State<PeriodDayFormPage> {
  late PeriodStatus _periodStatus;
  late FlowLevel _flowLevel;
  late List<String> _symptoms;
  late PeriodMood _mood;
  late TextEditingController _remarkController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _periodStatus = widget.record?.periodStatus ?? PeriodStatus.none;
    _flowLevel = widget.record?.flowLevel ?? FlowLevel.none;
    _symptoms = List.from(widget.record?.symptoms ?? []);
    _mood = widget.record?.mood ?? PeriodMood.normal;
    _remarkController = TextEditingController(text: widget.record?.remark ?? '');
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.recordDate),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save, style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: spacing.formPadding,
        child: Column(
          children: [
            // ── 状态 ──
            _buildCard(
              cs,
              spacing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle(theme, l10n.periodStatus, Icons.circle, cs.primary),
                  SizedBox(height: spacing.formItemSpacing),
                  _buildStatusRow(cs, l10n),
                ],
              ),
            ),

            SizedBox(height: spacing.formGroupSpacing),

            // ── 流量（仅经期时显示）──
            if (_periodStatus == PeriodStatus.period) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _buildCard(
                  cs,
                  spacing,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardTitle(theme, l10n.flowLevel, Icons.water_drop_outlined, cs.error),
                      SizedBox(height: spacing.formItemSpacing),
                      _buildFlowRow(cs, l10n),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing.formGroupSpacing),
            ],

            // ── 症状 ──
            _buildCard(
              cs,
              spacing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle(theme, l10n.symptomsMultiSelect, Icons.healing_outlined, Colors.teal),
                  SizedBox(height: spacing.formItemSpacing),
                  _buildSymptomGrid(cs),
                ],
              ),
            ),

            SizedBox(height: spacing.formGroupSpacing),

            // ── 心情 ──
            _buildCard(
              cs,
              spacing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle(theme, l10n.mood, Icons.emoji_emotions_outlined, Colors.amber),
                  SizedBox(height: spacing.formItemSpacing),
                  _buildMoodRow(cs, l10n),
                ],
              ),
            ),

            SizedBox(height: spacing.formGroupSpacing),

            // ── 备注 ──
            _buildCard(
              cs,
              spacing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle(theme, l10n.remark, Icons.notes_outlined, cs.onSurfaceVariant),
                  SizedBox(height: spacing.formItemSpacing),
                  TextField(
                    controller: _remarkController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.remarkHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ColorScheme cs, ThemeSpacing spacing, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: spacing.contentPadding,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildCardTitle(ThemeData theme, String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(ColorScheme cs, dynamic l10n) {
    final items = [
      (PeriodStatus.none, l10n.periodStatusNone, cs.primary),
      (PeriodStatus.period, l10n.periodRecord, cs.error),
    ];

    return Row(
      children: items.map((item) {
        final (status, label, color) = item;
        final isSelected = _periodStatus == status;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _periodStatus = status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(20) : cs.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : cs.outlineVariant.withAlpha(60),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      status == PeriodStatus.period
                          ? Icons.water_drop
                          : Icons.circle_outlined,
                      size: 16,
                      color: isSelected ? color : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? color : cs.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlowRow(ColorScheme cs, dynamic l10n) {
    final items = [
      (FlowLevel.light, FlowLevel.light.text, cs.tertiary),
      (FlowLevel.medium, FlowLevel.medium.text, cs.error.withAlpha(180)),
      (FlowLevel.heavy, FlowLevel.heavy.text, cs.error),
    ];

    return Row(
      children: items.map((item) {
        final (level, label, color) = item;
        final isSelected = _flowLevel == level;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _flowLevel = level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(20) : cs.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : cs.outlineVariant.withAlpha(60),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 20,
                      color: isSelected ? color : cs.onSurfaceVariant.withAlpha(120),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? color : cs.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomGrid(ColorScheme cs) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PeriodSymptoms.all.map((s) {
        final selected = _symptoms.contains(s.code);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _symptoms.remove(s.code);
              } else {
                _symptoms.add(s.code);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? cs.primary.withAlpha(80) : cs.outlineVariant.withAlpha(40),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  s.icon,
                  size: 16,
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? cs.onPrimaryContainer : cs.onSurface,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodRow(ColorScheme cs, dynamic l10n) {
    final items = [
      (PeriodMood.good, '😊', PeriodMood.good.text),
      (PeriodMood.normal, '😐', PeriodMood.normal.text),
      (PeriodMood.bad, '😢', PeriodMood.bad.text),
      (PeriodMood.terrible, '😤', PeriodMood.terrible.text),
    ];

    return Row(
      children: items.map((item) {
        final (mood, emoji, label) = item;
        final isSelected = _mood == mood;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _mood = mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? cs.primary.withAlpha(80) : cs.outlineVariant.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final provider = context.read<PeriodRecordProvider>();
    if (provider.isInPeriod) {
      await provider.upsertDailyRecord(
        widget.recordDate,
        flowLevel: _flowLevel.code,
        symptoms: _symptoms,
        mood: _mood.code,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
      );
    }
    if (mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }
}
