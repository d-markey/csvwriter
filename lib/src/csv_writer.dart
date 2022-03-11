import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'csv_data.dart';
import 'exceptions.dart';

/// [CsvWriter] wraps around a [StringSink] and enables writing data in CSV format. The [CsvWriter] maintains
/// an internal structure for the current data record. Individual values can be set or read via accessors or
/// via the [get] and [set] methods, accessed by header label (provided the [CsvWriter] was created with
/// [CsvWriter.withHeaders]) and/or index. The data is written to the underlying sink record per record.
///
/// Example:
/// ```dart
/// var csv = CsvWriter.withHeaders(mySink, ['Header #1', 'Header #2']);`
/// csv['Header #1'] = 'value';
/// csv.writeData();
/// await csv.close(); // recommended when mySink is a ClosableStringSink or an IOSink
/// ```
///
/// By default, the internal data record values are reset to `null` after each call to [writeData]. This behavior
/// can be overriden by calling [writeData] with `clear` set to `false`.
class CsvWriter {
  /// Builds a new [CsvWriter] bound to [sink] with CSV records consisting of [columns] values. [separator]
  /// (default is `','`) and [endOfLine] (default is `'\r\n'`) can be overriden. Using this constructor, data
  /// can only be set/read by index.
  CsvWriter(StringSink sink, int columns,
      {this.separator = _defSeparator, this.endOfLine = _defEndOfLine})
      : _sink = sink,
        _data = CsvData(columns),
        hasHeader = false {
    _handleOnClose();
  }

  /// Builds a new [CsvWriter] bound to [sink]. The supplied [headers] will be added as the first line, and CS
  ///  records will consist of `headers.length` values. [separator] (default is `','`) and [endOfLine] (default
  /// is `'\r\n'`) can be overriden. Using this constructor, data may be set/read by header name and/or index.
  CsvWriter.withHeaders(StringSink sink, Iterable<String> headers,
      {this.separator = _defSeparator, this.endOfLine = _defEndOfLine})
      : _sink = sink,
        _data = CsvData.withHeaders(headers),
        hasHeader = true {
    _handleOnClose();
    _sink.write(_data.headers.join(separator) + endOfLine);
  }

  static const String _defSeparator = ',';

  /// Separator character; default is `','`.
  final String separator;

  static const String _defEndOfLine = '\r\n';

  /// End-of-line character; default is `'\r\n'`.
  final String endOfLine;

  final StringSink _sink;
  final CsvData _data;

  /// `true` if this instance was constructed with [CsvWriter.withHeaders].
  final bool hasHeader;

  /// Number of values per record.
  int get columnCount => _data.columnCount;

  /// Count of records that have been written to the underlying [StringSink]. This count excludes the header
  /// line if [hasHeader] is `true`.
  int get rowCount => _rowCount;
  int _rowCount = 0;

  /// Clears the current record.
  void clearData() => _data.clear();

  /// Gets value for [header] from the current record. If [header] is an [int], it is interpreted as the
  /// column index. If [header] is a [String], it is used to lookup the header and find the column index.
  dynamic operator [](dynamic header) {
    if (header is int) {
      return _data.get('', header);
    } else if (header is String) {
      return _data.get(header, -1);
    } else {
      throw InvalidHeaderException(
          'Invalid header type ${header.runtimeType}: extected int or String');
    }
  }

  /// Sets value for [header] in the current record. If [header] is an [int], it is interpreted as the
  /// column index. If [header] is a [String], it is used to lookup the header and find the column index.
  /// Data will not be written to the [StringSink] before [writeData] is called.
  void operator []=(dynamic header, dynamic value) {
    if (header is int) {
      _data.set(value, '', header);
    } else if (header is String) {
      _data.set(value, header, -1);
    } else {
      throw InvalidHeaderException(
          'Invalid header type ${header.runtimeType}: extected int or String');
    }
  }

  /// Gets value for [header] / [index] from the current record. The column index in the CSV record is retrieved
  /// according to [header] and [index]. If [header] is not set, [index] is used as the column index (starting from
  /// 0). If [header] is set, the column index will be retrieved from the set of headers provided to [CsvWriter.withHeaders].
  /// If multiple headers have the same label, [index] can be used to distinguish amongst them (starting from 0).
  /// If no match is found, or if [index] is out of bounds, throws an [InvalidHeaderException].
  dynamic get({String header = '', int index = -1}) => _data.get(header, index);

  /// Sets [value] for [header] / [index] in the current record. The column index in the CSV record is retrieved
  /// according to [header] and [index]. If [header] is not set, [index] is used as the column index (starting from
  /// 0). If [header] is set, the column index will be retrieved from the set of headers provided to [CsvWriter.withHeaders].
  /// If multiple headers have the same label, [index] can be used to distinguish amongst them (starting from 0).
  /// If no match is found, or if [index] is out of bounds, throws an [InvalidHeaderException]. Data will not be
  /// written to the [StringSink] before [writeData] is called.
  void set(dynamic value, {String header = '', int index = -1}) =>
      _data.set(value, header, index);

  /// Loads [data] into the current data structure. [data] can either be a [List] (data is loaded by index) or
  /// a [Map]`<String, dynamic>` (data is loaded by header name).
  void setData(dynamic data) {
    if (data is List) {
      for (var i = 0; i < data.length; i++) {
        set(data[i], index: i);
      }
    } else if (data is Map<String, dynamic>) {
      for (var entry in data.entries) {
        set(entry.value, header: entry.key);
      }
    }
  }

  /// Writes the current record to the CSV file, if is not empty. The current record is considered empty if all
  /// of its values are `null` or their [String] representations are empty or contain only whitespaces. If [data]
  /// is provided, it is passed to [setData] to populate the internal data record before the write operation occurs.
  /// After the record has been written to the underlying [StringSink], the count of records is incremented and the
  /// internal data record is reset unless [clear] is `false`.
  void writeData({dynamic data, bool clear = true}) {
    if (_done.isCompleted) {
      throw UnsupportedError('Cannot write to a closed sink.');
    }
    if (data != null) {
      setData(data);
    }
    if (!_data.isEmpty) {
      _sink.write(_data.toCsv(separator) + endOfLine);
      _rowCount++;
      if (clear) {
        clearData();
      }
    }
  }

  static final Future _completed = Future.value();

  /// Flushes the underlying [StringSink] if it is an [IOSink], otherwise returns a completed [Future].
  Future flush() {
    if (_sink is IOSink) {
      return (_sink as IOSink).flush();
    } else {
      return _completed;
    }
  }

  /// Returns a [Future] that completes when this instance is closed. The returned [Future] is the same
  /// as the one returned by [close].
  Future get done => _done.future;
  final _done = Completer();

  bool _closing = false;

  void _onClose() {
    if (!_closing) {
      _done.complete();
    }
  }

  void _handleOnClose() {
    if (_sink is IOSink) {
      (_sink as IOSink).done.whenComplete(_onClose);
    }
  }

  /// If the underlying [StringSink] is an [IOSink], flushes and closes it. If it is a [ClosableStringSink],
  /// simply close it. This method returns the same future as [done]. Multiple calls to [close] are allowed
  /// but only the first one will have an effect.
  Future close() {
    if (!_done.isCompleted) {
      if (_sink is IOSink) {
        final ioSink = _sink as IOSink;
        _done.complete(ioSink.flush().whenComplete(() async {
          _closing = true;
          try {
            await ioSink.close();
          } finally {
            _closing = false;
          }
        }));
      } else if (_sink is ClosableStringSink) {
        final closableSink = _sink as ClosableStringSink;
        closableSink.close();
        _done.complete();
      } else {
        _done.complete();
      }
    }
    return _done.future;
  }
}
