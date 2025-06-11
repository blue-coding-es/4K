import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class _HomePageState extends ConsumerState<HomePage> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Cargamos la URL RTSP al arrancar (puedes hacerlo tras “Conectar” si prefieres)
    player.open(
      Media(
        'rtsp://192.168.88.1/livestream/12',
        // ↓ Opciones FFmpeg para reducir latencia (tune / prueba)
        extras: {
          'rtsp_transport': 'tcp',
          'stimeout': '5000000',      // 5 s timeout
          'max_delay': '200000',      // 200 ms búfer
          'buffer_size': '102400'     // 100 KB
        },
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4K Action Cam')),
      body: Column(
        children: [
          Expanded(child: Video(controller: controller)),   // <— Stream RTSP
          // …botones Conectar / Grabar aquí…
        ],
      ),
    );
  }
}
