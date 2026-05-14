import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/activity_provider.dart';
import '../../models/common.dart';
import '../common/common_select_form_field.dart';
import '../common/common_text_form_field.dart';

class ActivityAddSheet extends StatefulWidget {
  const ActivityAddSheet({super.key});

  @override
  State<ActivityAddSheet> createState() => _ActivityAddSheetState();
}

class _ActivityAddSheetState extends State<ActivityAddSheet> {
  late DateTime _selectedDate;
  String? _selectedActivityName;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = _formattedDate;
    context.read<ActivityProvider>().loadActivityNames();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formattedDate;
      });
    }
  }

  Future<void> _save() async {
    final name = _selectedActivityName;
    if (name == null || name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final OperateResult<String> result = await context.read<ActivityProvider>().createRecord(
        activityName: name,
        recordDate: _formattedDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );
      if (result.ok && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? L10nManager.l10n.operationFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final theme = Theme.of(context);
    final provider = context.watch<ActivityProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.activityRecord, style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),

          // 日期
          CommonTextFormField(
            readOnly: true,
            controller: _dateController,
            prefixIcon: Icons.calendar_today_outlined,
            labelText: '日期',
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),

          // 活动名称（与记账页商户选择交互一致）
          CommonSelectFormField<String>(
            items: provider.activityNames,
            value: _selectedActivityName,
            displayMode: DisplayMode.iconText,
            displayField: (name) => name,
            keyField: (name) => name,
            icon: Icons.playlist_add_check_outlined,
            label: l10n.activityName,
            required: true,
            onCreateItem: (value) async => value,
            onChanged: (value) {
              setState(() => _selectedActivityName = value as String?);
            },
          ),
          const SizedBox(height: 16),

          // 地点
          CommonTextFormField(
            controller: _locationController,
            labelText: l10n.activityLocation,
            hintText: l10n.activityLocationHint,
          ),
          const SizedBox(height: 24),

          // 保存按钮
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.activityRecord),
          ),
        ],
      ),
    );
  }
}
