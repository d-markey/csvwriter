class InvalidHeaderException implements Exception {
  final String? _message;

  InvalidHeaderException([this._message]);

  @override
  String toString() => (_message ?? '').trim().isEmpty
      ? 'InvalidHeaderException'
      : 'InvalidHeaderException: $_message';
}
