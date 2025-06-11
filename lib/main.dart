// reemplaza solo la definición de HomePage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'providers/camera_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final VlcPlayerController _vlc;
  bool _connected = false;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _vlc = VlcPlayerController.network(
      'rtsp://192.168.88.1/livestream/12',
      hwAcc: HwAcc.full,
      autoPlay: true,
    );
  }

  @override
  void dispose() {
    _vlc.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final cam = ref.read(cameraControlProvider);
    await cam.connect();
    await cam.startSession();
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: VlcPlayer(
                controller: _vlc,
                aspectRatio: 16 / 9,
              ),
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
