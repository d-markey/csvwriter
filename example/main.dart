import 'dart:io';

import 'package:csvwriter/csvwriter.dart';

void main() async {
  final nbSink = StringBuffer();
  final nbWriter = CsvWriter.withHeaders(nbSink, ['Number', 'Odd?', 'Even?']);
  for (var i = 0; i < 100; i++) {
    nbWriter.writeData(
        data: {'Number': i, 'Odd?': (i % 2) != 0, 'Even?': (i % 2) == 0});
  }

  print('NUMBERS:');
  print(nbSink.toString());

  print('');

  final familyFile = File('family.csv');
  final familySink = familyFile.openWrite(mode: FileMode.write);
  var sinkIsClosed = false;
  familySink.done.whenComplete(() {
    sinkIsClosed = true;
  });
  final familyWriter = CsvWriter.withHeaders(familySink, [
    'Name',
    'First name',
    'Father name',
    'First name',
    'Mother name',
    'First name',
  ]);

  try {
    familyWriter.set('Doe', header: 'Name');
    familyWriter.set('Doe', header: 'Father name');
    familyWriter.set('John', header: 'First name', index: 1);
    familyWriter.set('Smith', header: 'Mother name');
    familyWriter.set('Ann', header: 'First name', index: 2);

    for (var i = 0; i < 5; i++) {
      familyWriter.set('John #$i, Jr', header: 'First name', index: 0);
      familyWriter.writeData(clear: false);
      if (i % 2 == 0) {
        await familyWriter.flush();
      }
    }
  } finally {
    await familyWriter.close();
  }

  print('FAMILY (sink ${sinkIsClosed ? 'has been' : 'has not been'} closed):');
  print(familyFile.readAsStringSync());
}
