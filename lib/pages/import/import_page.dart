import 'dart:io';
import 'package:clsswjz/models/vo/user_book_vo.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../import/import.factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/account_books_provider.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../enums/import_source.dart';
import '../../providers/sync_provider.dart';

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
  bool _importing = false;
  double _importProgress = 0.0;
  String _importMessage = '';
  bool _importComplete = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nManager.l10n.importData),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 账本选择
                CommonSelectFormField<UserBookVO>(
                  items: context.read<AccountBooksProvider>().books,
                  value: _selectedBookId,
                  displayMode: DisplayMode.iconText,
                  displayField: (item) => item.name,
                  keyField: (item) => item.id,
                  icon: Icons.book,
                  label: L10nManager.l10n.accountBook,
                  required: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedBookId = value.id;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return L10nManager.l10n.required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 数据来源选择
                CommonSelectFormField<ImportSource>(
                  items: ImportSource.values,
                  value: _selectedSource,
                  displayMode: DisplayMode.iconText,
                  displayField: (item) => item.name,
                  keyField: (item) => item,
                  icon: Icons.source,
                  label: L10nManager.l10n.dataSource,
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
                      return L10nManager.l10n.required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 文件上传
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(20),
                    ),
                    color: theme.colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _selectedSource != null ? _pickFile : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(32),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.upload_file,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFile?.path ?? L10nManager.l10n.selectFile,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: _selectedFile != null
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                    if (_selectedSource != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '支持的文件类型：${_selectedSource!.fileTypes.map((e) => '.$e').join('、')}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_selectedFile != null)
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedFile == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      L10nManager.l10n.required,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // 导入按钮区域
                if (_importing)
                  // 导入进度
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: ProgressIndicatorBar(
                      label: _importMessage,
                      value: _importProgress,
                    ),
                  )
                else if (_importComplete)
                  // 导入完成按钮
                  FilledButton.icon(
                    onPressed: () {
                      // 先返回首页
                      Navigator.of(context).pop();
                      // 然后同步数据
                      context.read<SyncProvider>().syncData();
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(L10nManager.l10n.importComplete),
                  )
                else
                  // 导入按钮
                  FilledButton.icon(
                    onPressed: _canImport ? _importData : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.upload_file),
                    label: Text(L10nManager.l10n.import),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
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

    setState(() {
      _importing = true;
      _importProgress = 0.0;
      _importMessage = '';
    });

    try {
      await ImportFactory.importData(
        AppConfigManager.instance.userId!,
        (double percent, String message) {
          setState(() {
            _importProgress = percent;
            _importMessage = message;
          });
        },
        source: _selectedSource!,
        accountBookId: _selectedBookId!,
        file: _selectedFile!,
      );
    } finally {
      setState(() {
        _importing = false;
        _importComplete = true;
      });
    }
  }
}
