import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'exceptions.dart';

class CsvWriter {
  CsvWriter.withHeaders(this._sink, Iterable<String> headers,
      {String separator = ',', String endOfLine = '\r\n'})
      : _data = _Data.withHeaders(headers),
        _separator = separator,
        _eol = endOfLine {
    _sink.write(_data.headers.join(_separator) + _eol);
  }

  CsvWriter(this._sink, int columns,
      {String separator = ',', String endOfLine = '\r\n'})
      : _data = _Data(columns),
        _separator = separator,
        _eol = endOfLine;

  final StringSink _sink;

  final String _separator;
  final String _eol;

  final _Data _data;

  void clearData() => _data.clear();

  void writeData({bool clear = true}) {
    if (!_data.isEmpty) {
      _sink.write(_data.toCsv(_separator) + _eol);
      if (clear) {
        clearData();
      }
    }
  }

  static final Future _completed = Future.value();

  Future flush() {
    if (_sink is IOSink) {
      return (_sink as IOSink).flush();
    } else {
      return _completed;
    }
  }

  Future close() async {
    if (_sink is IOSink) {
      final ioSink = _sink as IOSink;
      await ioSink.flush();
      await ioSink.close();
    } else if (_sink is ClosableStringSink) {
      final closableSink = _sink as ClosableStringSink;
      closableSink.close();
    }
  }

  dynamic operator [](String header) => _data.get(header: header);

  void operator []=(String header, dynamic value) =>
      _data.set(header: header, value: value);

  dynamic get({String header = '', int index = -1}) =>
      _data.get(header: header, index: index);

  void set({String header = '', int index = -1, dynamic value}) =>
      _data.set(header: header, index: index, value: value);
}

class _Data {
  _Data.withHeaders(Iterable<String> headers)
      : _headers = headers.toList(),
        _values = List.filled(headers.length, null);

  _Data(int nbColumns) : this.withHeaders(List.filled(nbColumns, ''));

  final List<String> _headers;
  final List _values;

  Iterable<String> get headers => _headers;
  Iterable<dynamic> get values => _values;

  bool _isEmpty(dynamic str) => (str?.toString() ?? '').trim().isEmpty;

  bool get isEmpty => _values.every(_isEmpty);

  int _getHeaderIndex(String header, int index) {
    if (_isEmpty(header)) {
      if (index < 0 || index >= _values.length) {
        throw InvalidHeaderException(
            'Header "$index" out of range (0..${_values.length})');
      }
      return index;
    }
    var headerIndex = -1;
    var idx = (index < 0) ? 0 : index;
    for (var i = 0; i < _headers.length; i++) {
      if (_headers[i] == header) {
        if (headerIndex < 0 && idx == 0) {
          headerIndex = i;
        } else {
          if (index < 0) {
            throw InvalidHeaderException('Multiple headers for "$header"');
          }
          idx--;
        }
      }
    }
    if (headerIndex < 0) {
      throw InvalidHeaderException((index < 0)
          ? 'Header "$header" not found'
          : 'Header "$header" ($index) not found');
    }
    return headerIndex;
  }

  dynamic get({String header = '', int index = -1}) =>
      _values[_getHeaderIndex(header, index)];

  void set({String header = '', int index = -1, dynamic value}) =>
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
