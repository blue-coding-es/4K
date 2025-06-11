import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:action_cam/services/camera_control.dart'; // <- nombre del paquete

final cameraControlProvider = Provider<CameraControl>((ref) {
  return CameraControl();
});
