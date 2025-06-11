// lib/services/camera_control.dart
// Controlador TCP puro para cámaras H22 (puerto 7878)

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

/// Controlador principal para enviar comandos TCP‑JSON a la cámara.
class CameraControl {
  CameraControl({this.host = '192.168.88.1', this.port = 7878});

  final String host;
  final int port;

  Socket? _sock;
  int _token = 0; // El token se actualiza tras startSession()

  /// Conecta el socket. Lanza TimeoutException si no hay respuesta en 5 s.
  Future<void> connect() async {
    _sock = await Socket.connect(host, port,
        timeout: const Duration(seconds: 5));
  }

  /// Cierra la conexión TCP.
  Future<void> disconnect() async {
    await _sock?.close();
    _sock = null;
  }

  /// Devuelve un [Stream] con todos los mensajes JSON entrantes.
  Stream<Map<String, dynamic>> get messages async* {
    final socket = _sock; // copia local para evitar nulos entre awaits
    if (socket == null) throw NotConnectedException();
    await for (final data in socket) {
      final text = utf8.decode(data);
      try {
        yield json.decode(text) as Map<String, dynamic>;
      } catch (_) {
        // Puede llegar basura / keep‑alive; la ignoramos.
      }
    }
  }

  /// Envía un comando y espera la primera respuesta.
  Future<Map<String, dynamic>> _send(_Cmd cmd) async {
    final socket = _sock;
    if (socket == null) throw NotConnectedException();
    socket.writeln(json.encode(cmd.toJson()));
    await socket.flush();
    // Esperamos la primera respuesta que tenga el mismo msg_id
    return await messages.firstWhere((m) => m['msg_id'] == cmd.msgId);
  }

  /*───────────────────────── Comandos de alto nivel ─────────────────────────*/

  /// Inicia sesión y actualiza [_token]. Algunos firmwares devuelven el token
  /// en el campo `param`. Si no, usamos 1 por defecto.
  Future<void> startSession() async {
    final resp = await _send(const _Cmd(257, 0));
    _token = resp['param'] is int ? resp['param'] as int : 1;
  }

  Future<void> closeSession() => _send(_Cmd(258, _token));

  Future<void> startRecord() => _send(_Cmd(513, _token));

  Future<void> stopRecord() => _send(_Cmd(514, _token));

  Future<Map<String, dynamic>> setParam(String key, dynamic value) => _send(
        _Cmd(2, _token, {'type': key, 'param': value}),
      );

  Future<Map<String, dynamic>> getParam(String key) => _send(
        _Cmd(1, _token, {'type': key}),
      );

  /// Obtiene la lista de opciones para un parámetro (msg_id 9).
  Future<Map<String, dynamic>> listOptions(String key) => _send(
        _Cmd(9, _token, {'param': key}),
      );
}
