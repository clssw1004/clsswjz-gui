import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';

class ActivityAddPage extends StatefulWidget {
  const ActivityAddPage({super.key});

  @override
  State<ActivityAddPage> createState() => _ActivityAddPageState();
}

class _ActivityAddPageState extends State<ActivityAddPage> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _saving = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    context.read<ActivityProvider>().loadActivityNames();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  String get _formattedTime =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  int get _createdAtTimestamp {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    ).millisecondsSinceEpoch;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  List<String> _getFilteredSuggestions(String input) {
    final provider = context.read<ActivityProvider>();
    if (input.isEmpty) return [];
    return provider.activityNames
        .where((name) => name.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final result = await context.read<ActivityProvider>().createRecord(
        activityName: name,
        recordDate: _formattedDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        createdAt: _createdAtTimestamp,
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.activityRecord),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期
            TextFormField(
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: '日期',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.all(16),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              controller: TextEditingController(text: _formattedDate),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // 时间
            TextFormField(
              readOnly: true,
              onTap: _pickTime,
              decoration: InputDecoration(
                labelText: '时间',
                prefixIcon: const Icon(Icons.access_time_outlined),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.all(16),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              controller: TextEditingController(text: _formattedTime),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // 活动名称
            Text('${l10n.activityName} *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                hintText: l10n.activityNameHint,
                prefixIcon: const Icon(Icons.playlist_add_check_outlined),
                suffixIcon: _nameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _nameController.clear();
                          setState(() => _showSuggestions = false);
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              style: theme.textTheme.bodyLarge,
              onChanged: (value) {
                setState(() => _showSuggestions = value.isNotEmpty);
              },
              onTap: () {
                setState(() => _showSuggestions = _nameController.text.isNotEmpty);
              },
              onSubmitted: (value) {
                setState(() => _showSuggestions = false);
                _nameFocusNode.unfocus();
              },
            ),

            // 建议列表
            if (_showSuggestions)
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(60),
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    ..._getFilteredSuggestions(_nameController.text).map(
                      (name) => ListTile(
                        dense: true,
                        title: Text(name),
                        onTap: () {
                          _nameController.text = name;
                          setState(() => _showSuggestions = false);
                          _nameFocusNode.unfocus();
                        },
                      ),
                    ),
                    if (_getFilteredSuggestions(_nameController.text).isEmpty)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.add),
                        title: Text('新增"${_nameController.text}"'),
                        onTap: () {
                          setState(() => _showSuggestions = false);
                          _nameFocusNode.unfocus();
                        },
                      ),
                  ],
                ),
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.activityRecord),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
