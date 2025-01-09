import 'dart:io';
import 'package:clsswjz/models/vo/user_book_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/account_books_provider.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../enums/import_source.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  ImportSource? _selectedSource;
  String? _selectedBookId;
  File? _selectedFile;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importData),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 数据来源选择
            CommonSelectFormField<ImportSource>(
              items: ImportSource.values,
              value: _selectedSource,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.name,
              keyField: (item) => item,
              icon: Icons.source,
              label: l10n.dataSource,
              required: true,
              onChanged: (value) {
                setState(() {
                  _selectedSource = value;
                  // 清除已选文件，因为不同数据源支持的文件类型不同
                  _selectedFile = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 账本选择
            CommonSelectFormField<UserBookVO>(
              items: context.read<AccountBooksProvider>().books,
              value: _selectedBookId,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.name,
              keyField: (item) => item.id,
              icon: Icons.book,
              label: l10n.accountBook,
              required: true,
              onChanged: (value) {
                setState(() {
                  _selectedBookId = value.id;
                });
              },
              validator: (value) {
                if (value == null) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 文件上传
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(20),
                ),
              ),
              leading: Icon(
                Icons.upload_file,
                color: theme.colorScheme.primary,
              ),
              title: Text(_selectedFile?.path ?? l10n.selectFile),
              subtitle: _selectedSource != null
                  ? Text(
                      '支持的文件类型：${_selectedSource!.fileTypes.map((e) => '.$e').join('、')}',
                      style: theme.textTheme.bodySmall,
                    )
                  : null,
              trailing: _selectedFile != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                        });
                      },
                    )
                  : null,
              onTap: _selectedSource != null ? _pickFile : null,
              enabled: _selectedSource != null,
            ),
            if (_selectedFile == null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  l10n.required,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // 导入按钮
            FilledButton(
              onPressed: _canImport ? _importData : null,
              child: Text(l10n.import),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canImport {
    return _selectedSource != null && _selectedBookId != null && _selectedFile != null;
  }

  Future<void> _pickFile() async {
    if (_selectedSource == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _selectedSource!.fileTypes,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _importData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: 实现导入逻辑
  }
}
