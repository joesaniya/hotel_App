import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceRegistrationService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get device registration data
  Future<Map<String, dynamic>> getDeviceRegistrationData() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceData();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceData();
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      print('Error getting device info: $e');
      rethrow;
    }
  }

  /// Get Android device information
  Future<Map<String, dynamic>> _getAndroidDeviceData() async {
    final androidInfo = await _deviceInfo.androidInfo;

    return {
      "action": "deviceRegister",
      "deviceRegister": {
        "deviceModel": androidInfo.model,
        "deviceFingerprint": androidInfo.fingerprint,
        "deviceBrand": androidInfo.brand,
        "deviceId": androidInfo.id,
        "deviceName":
            "${androidInfo.model}_${androidInfo.version.sdkInt}_${androidInfo.version.release}",
        "deviceManufacturer": androidInfo.manufacturer,
        "deviceProduct": androidInfo.product,
        "deviceSerialNumber": "unknown",
      },
    };
  }

  /// Get iOS device information
  Future<Map<String, dynamic>> _getIOSDeviceData() async {
    final iosInfo = await _deviceInfo.iosInfo;

    return {
      "action": "deviceRegister",
      "deviceRegister": {
        "deviceModel": iosInfo.model,
        "deviceFingerprint": iosInfo.identifierForVendor ?? "unknown",
        "deviceBrand": "Apple",
        "deviceId": iosInfo.identifierForVendor ?? "unknown",
        "deviceName": iosInfo.name,
        "deviceManufacturer": "Apple",
        "deviceProduct": iosInfo.utsname.machine,
        "deviceSerialNumber": "unknown",
      },
    };
  }
}
