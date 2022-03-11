/// [InvalidHeaderException] thrown when the CSV column cannot be found.
class InvalidHeaderException implements Exception {
  /// The exception message.
  final String? message;

  /// Creates a new [InvalidHeaderException] with [message].
  InvalidHeaderException([this.message]);

  @override
  String toString() => (message ?? '').trim().isEmpty
      ? 'InvalidHeaderException'
      : 'InvalidHeaderException: $message';
}
