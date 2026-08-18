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
            onPressed: _save,
            child: Text(l10n.save, style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: spacing.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.periodStatus, style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            _buildSegmentedChoice<PeriodStatus>(
              values: PeriodStatus.values,
              selected: _periodStatus,
              labelBuilder: (s) => s.text,
              onChanged: (v) => setState(() => _periodStatus = v),
            ),

            if (_periodStatus == PeriodStatus.period) ...[
              SizedBox(height: spacing.formGroupSpacing),
              Text(l10n.flowLevel, style: theme.textTheme.titleSmall),
              SizedBox(height: spacing.formItemSpacing),
              _buildSegmentedChoice<FlowLevel>(
                values: FlowLevel.values.where((f) => f != FlowLevel.none).toList(),
                selected: _flowLevel,
                labelBuilder: (f) => f.text,
                onChanged: (v) => setState(() => _flowLevel = v),
              ),
            ],

            SizedBox(height: spacing.formGroupSpacing),
            Text(l10n.symptomsMultiSelect, style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            Wrap(
              spacing: spacing.formItemSpacing,
              runSpacing: spacing.formItemSpacing,
              children: PeriodSymptoms.all.map((s) {
                final selected = _symptoms.contains(s.code);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 16),
                      const SizedBox(width: 4),
                      Text(s.label),
                    ],
                  ),
                  selected: selected,
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _symptoms.add(s.code);
                      } else {
                        _symptoms.remove(s.code);
                      }
                    });
                  },
                  selectedColor: cs.primaryContainer,
                  checkmarkColor: cs.primary,
                );
              }).toList(),
            ),

            SizedBox(height: spacing.formGroupSpacing),
            Text(l10n.mood, style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            _buildSegmentedChoice<PeriodMood>(
              values: PeriodMood.values,
              selected: _mood,
              labelBuilder: (m) => m.text,
              onChanged: (v) => setState(() => _mood = v),
            ),

            SizedBox(height: spacing.formGroupSpacing),
            Text(l10n.remark, style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            TextField(
              controller: _remarkController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.remarkHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedChoice<T>({
    required List<T> values,
    required T selected,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      children: values.map((v) {
        final isSelected = v == selected;
        return ChoiceChip(
          label: Text(labelBuilder(v)),
          selected: isSelected,
          onSelected: (_) => onChanged(v),
          selectedColor: cs.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    final provider = context.read<PeriodRecordProvider>();
    final result = await provider.updatePeriodDay(
      widget.recordDate,
      periodStatus: _periodStatus.code,
      flowLevel: _periodStatus == PeriodStatus.period ? _flowLevel.code : FlowLevel.none.code,
      symptoms: _symptoms,
      mood: _mood.code,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );
    if (mounted && result.ok) {
      Navigator.pop(context);
    }
  }
}
