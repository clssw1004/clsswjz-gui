import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

/// 设备信息
class DeviceInfo {
  /// 设备ID
  final String clientId;

  /// 设备名称
  final String clientName;

  /// 设备类型
  final String clientType;

  const DeviceInfo({
    required this.clientId,
    required this.clientName,
    required this.clientType,
  });
}

class DeviceUtil {
  /// 获取设备信息
  static Future<DeviceInfo> getDeviceInfo(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return DeviceInfo(
          clientId: androidInfo.id,
          clientName: '${androidInfo.brand} ${androidInfo.model}',
          clientType: Theme.of(context).platform.name,
        );
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return DeviceInfo(
          clientId: iosInfo.identifierForVendor ?? 'unknown',
          clientName: '${iosInfo.name} ${iosInfo.model}',
          clientType: Theme.of(context).platform.name,
        );
      } else if (Theme.of(context).platform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return DeviceInfo(
          clientId: windowsInfo.deviceId,
          clientName: '${windowsInfo.computerName} (Windows)',
          clientType: Theme.of(context).platform.name,
        );
      } else if (Theme.of(context).platform == TargetPlatform.macOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        return DeviceInfo(
          clientId: macOsInfo.systemGUID ?? 'unknown',
          clientName: '${macOsInfo.computerName} (macOS)',
          clientType: Theme.of(context).platform.name,
        );
      } else if (Theme.of(context).platform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return DeviceInfo(
          clientId: linuxInfo.machineId ?? 'unknown',
          clientName: '${linuxInfo.name} (Linux)',
          clientType: Theme.of(context).platform.name,
        );
      }
      return DeviceInfo(
        clientId: 'unknown',
        clientName: 'Unknown Device',
        clientType: Theme.of(context).platform.name,
      );
    } catch (e) {
      return DeviceInfo(
        clientId: 'unknown',
        clientName: 'Unknown Device',
        clientType: Theme.of(context).platform.name,
      );
    }
  }
}
