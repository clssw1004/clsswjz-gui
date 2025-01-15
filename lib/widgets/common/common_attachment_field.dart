import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/attachment_vo.dart';
import '../../theme/theme_radius.dart';
import 'common_dialog.dart';

/// 通用附件组件
class CommonAttachmentField extends StatefulWidget {
  /// 附件列表
  final List<AttachmentVO> attachments;

  /// 是否可以上传
  final bool canUpload;

  /// 是否必填
  final bool required;

  /// 标签文本
  final String? label;

  /// 提示文本
  final String? hint;

  /// 错误文本
  final String? errorText;

  /// 附件上传回调
  final Future<void> Function(List<File> files)? onUpload;

  /// 附件删除回调
  final Future<void> Function(AttachmentVO attachment)? onDelete;

  /// 附件点击回调
  final void Function(AttachmentVO attachment)? onTap;

  const CommonAttachmentField({
    super.key,
    required this.attachments,
    this.canUpload = true,
    this.required = false,
    this.label,
    this.hint,
    this.errorText,
    this.onUpload,
    this.onDelete,
    this.onTap,
  });

  @override
  State<CommonAttachmentField> createState() => _CommonAttachmentFieldState();
}

class _CommonAttachmentFieldState extends State<CommonAttachmentField> {
  bool _isUploading = false;

  /// 选择文件
  Future<void> _pickFiles() async {
    if (_isUploading || widget.onUpload == null) return;

    try {
      setState(() => _isUploading = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        dialogTitle: L10nManager.l10n.addAttachment,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.where((file) => file.path != null).map((file) => File(file.path!)).toList();

        if (files.isNotEmpty) {
          await widget.onUpload!(files);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// 删除附件
  Future<void> _deleteAttachment(AttachmentVO attachment) async {
    if (widget.onDelete != null) {
      await widget.onDelete!(attachment);
    }
  }

  /// 弹出附件列表对话框
  void _showAttachmentDialog() {
    CommonDialog.show(
      context: context,
      title: L10nManager.l10n.attachments,
      width: 400,
      content: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.attachments.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final attachment = widget.attachments[index];
            return ListTile(
              dense: true,
              horizontalTitleGap: 0,
              leading: const Icon(Icons.attachment_outlined, size: 20),
              title: Text(
                attachment.originName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: widget.onDelete != null
                  ? IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteAttachment(attachment);
                      },
                    )
                  : null,
              onTap: widget.onTap != null ? () => widget.onTap!(attachment) : null,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(60),
                borderRadius: BorderRadius.circular(
                  theme.extension<ThemeRadius>()?.radius ?? 8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: widget.attachments.isNotEmpty ? _showAttachmentDialog : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attachment_rounded, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          L10nManager.l10n.attachNum(widget.attachments.length),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.canUpload) ...[
                    Container(
                      width: 1,
                      height: 20,
                      color: colorScheme.onSurface.withAlpha(20),
                    ),
                    Tooltip(
                      message: L10nManager.l10n.addAttachment,
                      child: TextButton.icon(
                        onPressed: _isUploading ? null : _pickFiles,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: colorScheme.primary,
                        ),
                        icon: _isUploading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : const Icon(Icons.add_circle_outline, size: 20),
                        label: Text(
                          L10nManager.l10n.uploadAttachment,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
