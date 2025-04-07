import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:photo_view/photo_view.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/file_util.dart';
import '../../utils/toast_util.dart';
import '../../models/vo/attachment_vo.dart';
import 'common_app_bar.dart';

/// 通用图片预览组件
class CommonImagePreview extends StatelessWidget {
  /// 附件对象
  final AttachmentVO attachment;

  /// 是否显示AppBar
  final bool showAppBar;

  /// 背景色
  final Color? backgroundColor;

  /// 初始缩放
  final double initialScale;

  /// 最小缩放
  final double minScale;

  /// 最大缩放
  final double maxScale;

  const CommonImagePreview({
    super.key,
    required this.attachment,
    this.showAppBar = true,
    this.backgroundColor,
    this.initialScale = 1.0,
    this.minScale = 0.5,
    this.maxScale = 3.0,
  });

  /// 保存图片到相册
  Future<void> _saveToGallery(BuildContext context) async {
    try {
      if (attachment.file == null) return;

      await Gal.putImageBytes(attachment.file!.readAsBytesSync());
      if (context.mounted) {
        ToastUtil.showSuccess(L10nManager.l10n.saveSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtil.showError(L10nManager.l10n.saveFailed(""));
      }
    }
  }

  /// 使用外部应用打开
  Future<void> _openWithExternalApp(BuildContext context) async {
    if (attachment.file == null) return;
    await FileUtil.openFile(attachment);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 检查是否为图片文件
    if (!FileUtil.isImage(attachment.originName) || attachment.file == null) {
      return const SizedBox.shrink();
    }

    // 构建图片源
    final imageProvider = FileImage(attachment.file!);

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(128),
      appBar: showAppBar
          ? CommonAppBar(
              title: Text(
                attachment.originName,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              actions: [
                // 外部应用打开按钮
                IconButton(
                  icon: Icon(
                    Icons.open_in_new,
                    color: colorScheme.onSurface,
                  ),
                  tooltip: L10nManager.l10n.openWithExternalApp,
                  onPressed: () => _openWithExternalApp(context),
                ),
                // 保存到相册按钮
                IconButton(
                  icon: Icon(
                    Icons.download,
                    color: colorScheme.onSurface,
                  ),
                  tooltip: L10nManager.l10n.saveToGallery,
                  onPressed: () => _saveToGallery(context),
                ),
              ],
            )
          : null,
      body: PhotoView(
        imageProvider: imageProvider,
        initialScale: PhotoViewComputedScale.contained * initialScale,
        minScale: PhotoViewComputedScale.contained * minScale,
        maxScale: PhotoViewComputedScale.contained * maxScale,
        backgroundDecoration: BoxDecoration(
          color: backgroundColor ?? Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                L10nManager.l10n.loadFailed,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图片预览页面
class ImagePreviewPage extends StatelessWidget {
  final AttachmentVO attachment;

  const ImagePreviewPage({
    super.key,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return CommonImagePreview(
      attachment: attachment,
    );
  }
}

/// 打开图片预览
Future<void> showImagePreview(
  BuildContext context, {
  required AttachmentVO attachment,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImagePreviewPage(
        attachment: attachment,
      ),
    ),
  );
}
