import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '_sink_wrapper.dart';

SinkWrapper wrapSink(StringSink sink) => _IOSinkWrapper(sink);

class _IOSinkWrapper implements SinkWrapper {
  _IOSinkWrapper(this._sink) {
    if (_sink is IOSink) {
      (_sink as IOSink).done.whenComplete(_onClose);
    }
  }

  final StringSink _sink;
  final _done = Completer();

  @override
  Future get done => _done.future;

  static final _completed = Future.value();

  @override
  Future flush() {
    if (_sink is IOSink) {
      return (_sink as IOSink).flush();
    } else {
      return _completed;
    }
  }

  bool _closing = false;

  void _onClose() {
    if (!_closing) {
      _done.complete();
    }
  }

  @override
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

  @override
  void write(String data) {
    if (_done.isCompleted) {
      throw UnsupportedError('Cannot write to a closed sink.');
    }
    _sink.write(data);
  }
}
