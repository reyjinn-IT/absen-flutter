import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
  }

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.location.request();
      return result.isGranted;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}