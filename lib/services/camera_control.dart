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
