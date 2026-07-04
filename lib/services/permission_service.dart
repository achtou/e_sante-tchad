import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Demande les permissions nécessaires pour l'application
  static Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    final permissions = {
      Permission.camera: await Permission.camera.request(),
      Permission.storage: await Permission.storage.request(),
      Permission.phone: await Permission.phone.request(),
    };
    return permissions;
  }

  /// Vérifie si toutes les permissions sont accordées
  static Future<bool> areAllPermissionsGranted() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    final phoneStatus = await Permission.phone.status;
    
    return cameraStatus.isGranted && 
           storageStatus.isGranted && 
           phoneStatus.isGranted;
  }

  /// Demande une permission spécifique
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  /// Ouvre les paramètres de l'application pour gérer les permissions
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
