import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_control.dart';

final cameraControlProvider = Provider<CameraControl>((ref) {
  return CameraControl(); // host y puerto por defecto
});
