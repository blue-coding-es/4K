import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../providers/camera_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);

  bool _connected = false;
  bool _recording = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final cam = ref.read(cameraControlProvider);
    await cam.connect();
    await cam.startSession();
    // Carga el stream solo cuando la sesión está activa
    await _player.open(
      const Media('rtsp://192.168.88.1/livestream/12'),
    );
    setState(() => _connected = true);
  }

  Future<void> _toggleRecord() async {
    final cam = ref.read(cameraControlProvider);
    if (_recording) {
      await cam.stopRecord();
    } else {
      await cam.startRecord();
    }
    setState(() => _recording = !_recording);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4K Action Cam')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Video(controller: _controller, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _connected ? null : _connect,
                  child: const Text('Conectar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _connected ? _toggleRecord : null,
                  child: Text(_recording ? 'Detener' : 'Grabar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
