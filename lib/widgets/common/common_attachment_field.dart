import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/vo/attachment_vo.dart';
import '../../theme/theme_radius.dart';

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
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Text(
                  widget.required ? '${widget.label} *' : widget.label!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: widget.errorText != null
                        ? colorScheme.error
                        : colorScheme.onSurface,
                  ),
                ),
                if (widget.canUpload) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isUploading ? null : _pickFiles,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline),
                  ),
                ],
              ],
            ),
          ),
        if (widget.attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline.withAlpha(20)),
              borderRadius: BorderRadius.circular(
                theme.extension<ThemeRadius>()?.radius ?? 8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attachment_outlined,
                  size: 48,
                  color: colorScheme.outline.withAlpha(50),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hint ?? l10n.noData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline.withAlpha(50),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline.withAlpha(20)),
              borderRadius: BorderRadius.circular(
                theme.extension<ThemeRadius>()?.radius ?? 8,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                theme.extension<ThemeRadius>()?.radius ?? 8,
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.attachments.map((attachment) {
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withAlpha(30),
                          borderRadius: BorderRadius.circular(
                            theme.extension<ThemeRadius>()?.radius ?? 8,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onTap != null
                                ? () => widget.onTap!(attachment)
                                : null,
                            borderRadius: BorderRadius.circular(
                              theme.extension<ThemeRadius>()?.radius ?? 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.attachment_outlined,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      attachment.originName,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.onDelete != null) ...[
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () =>
                                          _deleteAttachment(attachment),
                                      customBorder: const CircleBorder(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: colorScheme.onSurfaceVariant
                                              .withAlpha(60),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
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
