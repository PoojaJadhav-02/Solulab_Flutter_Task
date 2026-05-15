import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<PermissionStatus> checkCameraPermission() async {
    return Permission.camera.status;
  }

  Future<bool> openAppSettings() => openAppSettings();
}
