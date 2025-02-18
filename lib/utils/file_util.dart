import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import '../models/vo/attachment_vo.dart';
import '../models/common.dart';

class FileUtil {
  static Future<File> toCacheFile(AttachmentVO attachment) async {
    try {
      String cacheDir = (await getTemporaryDirectory()).path;
      String fileName = attachment.originName;
      String newPath = path.join(cacheDir, fileName);

      /// 若缓存文件夹中已存在该文件，则直接返回
      if (File(newPath).existsSync()) {
        return File(newPath);
      }
      return attachment.file!.copy(newPath);
    } catch (e) {
      throw Exception('复制文件到缓存目录失败：$e');
    }
  }

  /// 使用系统默认应用打开文件
  static Future<OperateResult<void>> openFile(AttachmentVO attachment) async {
    try {
      if (attachment.file == null) {
        return OperateResult.failWithMessage(message: '文件不存在');
      }

      // File file = await toCacheFile(attachment);
      // final result = await OpenFilex.open(file.path);

      // if (result.type == ResultType.error) {
      //   return OperateResult.failWithMessage(
      //     message: '打开文件失败：${result.message}',
      //   );
      // }

      // if (result.type == ResultType.noAppToOpen) {
      //   return OperateResult.failWithMessage(
      //     message: '没有找到可以打开该类型文件的应用',
      //   );
      // }

      // if (result.type == ResultType.permissionDenied) {
      //   return OperateResult.failWithMessage(
      //     message: '没有权限打开文件',
      //   );
      // }

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '打开文件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
