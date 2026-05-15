import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/activity_provider.dart';
import '../../models/common.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _saving = false;
  bool _showSuggestions = false;

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
    _nameController.dispose();
    _nameFocusNode.dispose();
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

  List<String> _getFilteredSuggestions(String input) {
    final provider = context.read<ActivityProvider>();
    if (input.isEmpty) return [];
    return provider.activityNames
        .where((name) =>
            name.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }

  Future<void> _save() async {
    final name = _selectedActivityName ?? _nameController.text.trim();
    if (name.isEmpty) return;

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
          TextFormField(
            readOnly: true,
            controller: _dateController,
            onTap: _pickDate,
            decoration: InputDecoration(
              labelText: '日期',
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.all(16),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // 活动名称
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: '${l10n.activityName} *',
              hintText: l10n.activityNameHint,
              prefixIcon: const Icon(Icons.playlist_add_check_outlined),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _nameController.clear();
                        _selectedActivityName = null;
                        setState(() => _showSuggestions = false);
                      },
                    )
                  : null,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.all(16),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            style: theme.textTheme.bodyLarge,
            onChanged: (value) {
              _selectedActivityName = null;
              setState(() {
                _showSuggestions = value.isNotEmpty;
              });
            },
            onTap: () {
              setState(() {
                _showSuggestions = _nameController.text.isNotEmpty;
              });
            },
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _selectedActivityName = value.trim();
                setState(() => _showSuggestions = false);
                _nameFocusNode.unfocus();
              }
            },
          ),

          // 建议列表
          if (_showSuggestions)
            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(60),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  ..._getFilteredSuggestions(_nameController.text).map(
                    (name) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      title: Text(name),
                      onTap: () {
                        _nameController.text = name;
                        _selectedActivityName = name;
                        setState(() => _showSuggestions = false);
                        _nameFocusNode.unfocus();
                      },
                    ),
                  ),
                  if (_getFilteredSuggestions(_nameController.text).isEmpty)
                    ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                        radius: 14,
                        child: Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                      title: Text('新增"${_nameController.text}"'),
                      onTap: () {
                        _selectedActivityName = _nameController.text.trim();
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
