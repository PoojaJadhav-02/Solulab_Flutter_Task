import 'package:permission_handler/permission_handler.dart';

/// Wraps [permission_handler] to keep permission logic out of UI code.
class PermissionService {
  const PermissionService();

  /// Requests camera permission and returns whether it was granted.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Checks current camera permission status without requesting it.
  Future<PermissionStatus> checkCameraPermission() async {
    return Permission.camera.status;
  }

  /// Opens the OS app-settings page so the user can manually grant denied
  /// permissions.
  Future<bool> openAppSettings() => openAppSettings();
}
