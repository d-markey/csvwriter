import 'exceptions.dart';

class CsvData {
  CsvData.withHeaders(
      Iterable<String> headers, String separator, String endOfLine)
      : _headers = List.unmodifiable(headers),
        _values = List.filled(headers.length, null),
        _separator = separator,
        _separatorRunes = separator.runes.toList(),
        _endOfLineRunes = endOfLine.runes.toList() {
    for (var i = 0; i < _headers.length; i++) {
      _columnCache.putIfAbsent(_headers[i], () => <int>[]).add(i);
    }
  }

  CsvData(int nbColumns, String separator, String endOfLine)
      : this.withHeaders(List.filled(nbColumns, ''), separator, endOfLine);

  final List<String> _headers;
  final List _values;
  final String _separator;
  final List<int> _separatorRunes;
  final List<int> _endOfLineRunes;

  static dynamic _identity(dynamic value) => value;

  Iterable<String> get headers => _headers;
  Iterable<dynamic> get values => _values.map(_identity);

  int get columnCount => _headers.length;

  final _columnCache = <String, List<int>>{};

  // ignore: non_constant_identifier_names
  static final _CR = '\r'.runes.first;
  // ignore: non_constant_identifier_names
  static final _LF = '\n'.runes.first;
  // ignore: non_constant_identifier_names
  static final _QUOTE = '"'.runes.first;
  // ignore: non_constant_identifier_names
  static final _SPACE = ' '.runes.first;

  static final _needEscape = {_CR, _LF, _QUOTE};

  static bool _isSpace(int rune) => rune == _SPACE;

  static bool _isEmpty(dynamic str) {
    final s = str?.toString() ?? '';
    return s.isEmpty || s.runes.every(_isSpace);
  }

  bool get isEmpty => _values.every(_isEmpty);

  int _getHeaderIndex(String header, int index) {
    if (_isEmpty(header)) {
      if (index < 0 || index >= _values.length) {
        throw InvalidHeaderException(
            'Header "$index" out of range (0..${_values.length - 1})');
      }
      return index;
    }
    final indexes = _columnCache[header];
    if (indexes == null) {
      throw InvalidHeaderException('Header "$header" not found');
    }
    if (index < 0) {
      if (indexes.length > 1) {
        throw InvalidHeaderException(
            'Multiple headers "$header": missing index');
      }
      index = 0;
    }
    if (index < 0 || index >= indexes.length) {
      throw InvalidHeaderException(
          'Out of range index $index for header "$header": valid range is (0..${indexes.length - 1})');
    }
    return indexes[index];
  }

  dynamic get([String header = '', int index = -1]) =>
      _values[_getHeaderIndex(header, index)];

  void set(dynamic value, [String header = '', int index = -1]) =>
      _values[_getHeaderIndex(header, index)] = value;

  bool _isMatchAt(List<int> runes, int idx, List<int> otherRunes) {
    var i = 0, l = runes.length, ol = otherRunes.length;
    while (i < ol && idx < l) {
      if (runes[idx] != otherRunes[i]) {
        return false;
      }
      idx++;
      i++;
    }
    return (i == ol);
  }

  String _getCsvValue(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.isEmpty) {
      return '';
    }
    final runes = str.runes.toList(), len = runes.length;
    for (var i = 0; i < len; i++) {
      if (_needEscape.contains(runes[i]) ||
          _isMatchAt(runes, i, _separatorRunes) ||
          _isMatchAt(runes, i, _endOfLineRunes)) {
        // needs escape
        return '"${str.replaceAll('"', '""')}"';
      }
    }
    return str;
  }

  String toCsv() => _values.map(_getCsvValue).join(_separator);

  void clear() => _values.fillRange(0, _values.length, null);
}
