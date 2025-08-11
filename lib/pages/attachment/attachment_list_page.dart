import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../drivers/driver_factory.dart';
import '../../models/dto/attachment_filter_dto.dart';
import '../../models/vo/attachment_show_vo.dart';
import '../../providers/books_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';
import '../../utils/file_util.dart';
import '../../utils/date_util.dart';

/// 附件列表页面
class AttachmentListPage extends StatefulWidget {
  const AttachmentListPage({super.key});

  @override
  State<AttachmentListPage> createState() => _AttachmentListPageState();
}

class _AttachmentListPageState extends State<AttachmentListPage> {
  final List<AttachmentShowVO> _attachments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: Text(l10n.attachment),
        showBackButton: true,
        centerTitle: false,
      ),
      body: _isLoading && _attachments.isEmpty
          ? const CommonLoadingView()
          : _attachments.isEmpty
              ? CommonEmptyView(message: l10n.noData)
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 100 &&
                          !_isLoading &&
                          _hasMore) {
                        _loadAttachments();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _attachments.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _attachments.length) {
                          // 加载更多指示器
                          return _buildLoadMoreIndicator();
                        }
                        return _buildAttachmentItem(_attachments[index]);
                      },
                    ),
                  ),
                ),
    );
  }

  /// 构建附件项
  Widget _buildAttachmentItem(AttachmentShowVO attachment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha(90),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(80), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => FileUtil.openFile(attachment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFileTypeIcon(attachment),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 来源标题
                    Text(
                      attachment.businessName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      attachment.originName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          FileUtil.formatFileSize(attachment.fileLength),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateUtil.format(attachment.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建文件类型图标
  Widget _buildFileTypeIcon(AttachmentShowVO attachment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = attachment.extension.toLowerCase();
    final contentType = attachment.contentType.toLowerCase();

    // 检查是否为图片文件
    if (FileUtil.isImage(attachment.originName) && attachment.file != null) {
      return _buildImagePreview(attachment.file!);
    }

    IconData iconData;
    Color iconColor;

    // 根据文件类型设置图标和颜色
    if (contentType.startsWith('image/') ||
        ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      iconData = Icons.image;
      iconColor = Colors.green;
    } else if (contentType.startsWith('video/') ||
        ['mp4', 'avi', 'mov', 'wmv', 'flv'].contains(extension)) {
      iconData = Icons.video_file;
      iconColor = Colors.red;
    } else if (contentType.startsWith('audio/') ||
        ['mp3', 'wav', 'flac', 'aac'].contains(extension)) {
      iconData = Icons.audio_file;
      iconColor = Colors.orange;
    } else if (['pdf'].contains(extension)) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else if (['xls', 'xlsx'].contains(extension)) {
      iconData = Icons.table_chart;
      iconColor = Colors.green;
    } else if (['ppt', 'pptx'].contains(extension)) {
      iconData = Icons.slideshow;
      iconColor = Colors.orange;
    } else if (['txt'].contains(extension)) {
      iconData = Icons.text_snippet;
      iconColor = colorScheme.onSurfaceVariant;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      iconData = Icons.archive;
      iconColor = Colors.purple;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        iconData,
        size: 28,
        color: iconColor,
      ),
    );
  }

  /// 构建图片预览
  Widget _buildImagePreview(File imageFile) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withAlpha(12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.image,
                size: 24,
                color: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建来源图标
  Widget _buildSourceIcon(String businessCode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData iconData;
    Color iconColor;

    switch (businessCode) {
      case 'item':
        iconData = Icons.receipt;
        iconColor = Colors.blue;
        break;
      case 'note':
        iconData = Icons.note;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.attachment;
        iconColor = colorScheme.onSurfaceVariant;
    }

    return Icon(
      iconData,
      size: 16,
      color: iconColor,
    );
  }

  /// 获取来源文本
  String _getSourceText(String businessCode) {
    final l10n = L10nManager.l10n;
    switch (businessCode) {
      case 'item':
        return l10n.accountItem;
      case 'note':
        return l10n.note;
      default:
        return l10n.attachment;
    }
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator() {
    if (!_hasMore) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  /// 加载附件列表
  Future<void> _loadAttachments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dataDriver = DriverFactory.driver;
      final booksProvider = Provider.of<BooksProvider>(context, listen: false);
      final bookId = booksProvider.selectedBook?.id;

      if (bookId == null) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }

      final result = await dataDriver.listAttachments(
        booksProvider.selectedBook!.createdBy,
        limit: _pageSize,
        offset: _offset,
        filter: const AttachmentFilterDTO(
          businessCode: null, // 获取所有类型的附件
        ),
      );

      if (result.ok && result.data != null) {
        setState(() {
          if (_offset == 0) {
            _attachments.clear();
          }
          _attachments.addAll(result.data!);
          _hasMore = result.data!.length == _pageSize;
          _offset += result.data!.length;
        });
      } else {
        // 处理错误
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? L10nManager.l10n.loadFailed),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10nManager.l10n.loadFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 刷新数据
  Future<void> _refresh() async {
    setState(() {
      _offset = 0;
      _hasMore = true;
    });
    await _loadAttachments();
  }
}
