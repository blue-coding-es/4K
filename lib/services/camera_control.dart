import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Modelo base de comando enviado a la cámara.
class _Cmd {
  final int msgId;
  final int token;
  final Map<String, dynamic> extra;

  const _Cmd(this.msgId, this.token, [this.extra = const {}]);

  Map<String, dynamic> toJson() => {
        'msg_id': msgId,
        'token': token,
        ...extra,
      };
}

/// Excepción lanzada cuando el socket aún no está conectado.
class NotConnectedException implements Exception {
  @override
  String toString() => 'Socket no conectado. Llama primero a connect()';
}

/// Controlador principal para enviar comandos TCP-JSON a la cámara.
class CameraControl {
  CameraControl({this.host = '192.168.88.1', this.port = 7878});

  final String host;
  final int port;

  Socket? _sock;
  int _token = 0; // Se actualiza tras startSession()

  /*─────────────────────── Conexión ───────────────────────*/

  Future<void> connect() async {
    _sock = await Socket.connect(host, port,
        timeout: const Duration(seconds: 5));
  }

  Future<void> disconnect() async {
    await _sock?.close();
    _sock = null;
  }

  Stream<Map<String, dynamic>> get messages async* {
    final socket = _sock;
    if (socket == null) throw NotConnectedException();
    await for (final data in socket) {
      final text = utf8.decode(data);
      try {
        yield json.decode(text) as Map<String, dynamic>;
      } catch (_) {
        // Ignora paquetes que no sean JSON
      }
    }
  }

  Future<Map<String, dynamic>> _send(_Cmd cmd) async {
    final socket = _sock;
    if (socket == null) throw NotConnectedException();
    socket.writeln(json.encode(cmd.toJson()));
    await socket.flush();
    return await messages.firstWhere((m) => m['msg_id'] == cmd.msgId);
  }

  /*─────────────────── Comandos de sesión ──────────────────*/

  Future<void> startSession() async {
    final resp = await _send(const _Cmd(257, 0));
    _token = resp['param'] is int ? resp['param'] as int : 1;
  }

  Future<void> closeSession() => _send(_Cmd(258, _token));

  /*──────────────────── Grabar y foto ─────────────────────*/

  Future<void> startRecord() => _send(_Cmd(513, _token));
  Future<void> stopRecord()  => _send(_Cmd(514, _token));

  /*──────────────────── Ajustes genéricos ──────────────────*/

  Future<Map<String, dynamic>> setParam(String key, dynamic value) =>
      _send(_Cmd(2, _token, {'type': key, 'param': value}));

  Future<Map<String, dynamic>> getParam(String key) =>
      _send(_Cmd(1, _token, {'type': key}));

  Future<Map<String, dynamic>> listOptions(String key) =>
      _send(_Cmd(9, _token, {'param': key}));
}
