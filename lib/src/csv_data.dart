import 'exceptions.dart';

class CsvData {
  CsvData.withHeaders(Iterable<String> headers)
      : _headers = headers.toList(),
        _values = List.filled(headers.length, null);

  CsvData(int nbColumns) : this.withHeaders(List.filled(nbColumns, ''));

  final List<String> _headers;
  final List _values;

  Iterable<String> get headers => _headers;
  Iterable<dynamic> get values => _values;

  int get columnCount => _headers.length;

  final _columnCache = <String, List<int>>{};

  bool _isEmpty(dynamic str) => (str?.toString() ?? '').trim().isEmpty;

  bool get isEmpty => _values.every(_isEmpty);

  void _buildColumnCache() {
    for (var i = 0; i < _headers.length; i++) {
      final list = _columnCache.putIfAbsent(_headers[i], () => <int>[]);
      list.add(i);
    }
  }

  int _getHeaderIndex(String header, int index) {
    if (_isEmpty(header)) {
      if (index < 0 || index >= _values.length) {
        throw InvalidHeaderException(
            'Header "$index" out of range (0..${_values.length - 1})');
      }
      return index;
    }
    if (_columnCache.isEmpty) {
      _buildColumnCache();
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
    } else if (indexes.isNotEmpty && (index < 0 || index >= indexes.length)) {
      throw InvalidHeaderException(
          'Multiple headers "$header": index $index is out of range (0..${indexes.length - 1})');
    }
    return indexes[index];
  }

  dynamic get([String header = '', int index = -1]) =>
      _values[_getHeaderIndex(header, index)];

  void set(dynamic value, [String header = '', int index = -1]) =>
      _values[_getHeaderIndex(header, index)] = value;

  // ignore: non_constant_identifier_names
  static final _CR = '\r'.runes.first;
  // ignore: non_constant_identifier_names
  static final _LF = '\n'.runes.first;
  // ignore: non_constant_identifier_names
  static final _QUOTE = '"'.runes.first;

  static bool _matchAt(List<int> runes, List<int> srunes, int idx) {
    var i = 0;
    var l = runes.length;
    var sl = srunes.length;
    while (i < sl && idx < l) {
      if (runes[idx++] != srunes[i++]) {
        return false;
      }
    }
    return (i == sl);
  }

  static String _getCsvValue(dynamic value, String separator) {
    final str = value?.toString() ?? '';
    final runes = str.runes.toList();
    final len = runes.length;
    if (len == 0) {
      return '';
    }
    var escape = false, i = 0;
    var srunes = separator.runes.toList();
    while (!escape && i < len) {
      final ch = runes[i++];
      if (ch == _CR || ch == _LF || ch == _QUOTE) {
        escape = true;
      } else if (_matchAt(runes, srunes, i)) {
        escape = true;
      }
    }
    if (escape) {
      return '"' + str.replaceAll('"', '""') + '"';
    } else {
      return str;
    }
  }

  String toCsv(String separator) =>
      _values.map((v) => _getCsvValue(v, separator)).join(separator);

  void clear() {
    for (var i = 0; i < _values.length; i++) {
      _values[i] = null;
    }
  }
}
