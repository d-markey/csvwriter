import 'dart:async';
import 'dart:convert';
import 'sink_wrapper.dart';

SinkWrapper wrapSink(StringSink sink) => BrowserSinkWrapper(sink);

class BrowserSinkWrapper implements SinkWrapper {
  BrowserSinkWrapper(this._sink);

  final StringSink _sink;
  final _done = Completer();

  @override
  Future get done => _done.future;

  static final _completed = Future.value();

  @override
  Future flush() {
    return _completed;
  }

  @override
  Future close() {
    if (!_done.isCompleted) {
      if (_sink is ClosableStringSink) {
        final closableSink = _sink as ClosableStringSink;
        closableSink.close();
        _done.complete();
      } else {
        _done.complete();
      }
    }
    return _done.future;
  }

  @override
  void write(String data) {
    if (_done.isCompleted) {
      throw UnsupportedError('Cannot write to a closed sink');
    }
    _sink.write(data);
  }
}
