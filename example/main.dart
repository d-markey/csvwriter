import 'dart:io';

import 'package:csvwriter/csvwriter.dart';

void main() async {
  var nbSink = StringBuffer();
  var nbWriter = CsvWriter.withHeaders(nbSink, ['Number', 'Odd?', 'Even?']);
  for (var i = 0; i < 100; i++) {
    nbWriter.set(header: 'Number', value: i);
    nbWriter.set(header: 'Odd?', value: (i % 2) != 0);
    nbWriter.set(header: 'Even?', value: (i % 2) == 0);
    nbWriter.writeData();
    await nbWriter.flush();
  }

  print('NUMBERS:');
  print(nbSink.toString());

  print('');

  var familyFile = File('test.csv');
  var familySink = familyFile.openWrite();
  try {
    var familyWriter = CsvWriter.withHeaders(familySink, [
      'Name',
      'First name',
      'Father name',
      'First name',
      'Mother name',
      'First name',
    ]);
    for (var i = 0; i < 5; i++) {
      familyWriter.set(header: 'Name', value: 'Doe');
      familyWriter.set(header: 'First name', index: 0, value: 'John Jr #$i');
      familyWriter.set(header: 'Father name', value: 'Doe');
      familyWriter.set(header: 'First name', index: 1, value: 'John');
      familyWriter.set(header: 'Mother name', value: 'Smith');
      familyWriter.set(header: 'First name', index: 2, value: 'Ann');
      familyWriter.writeData();
      await familySink.flush();
    }
  } finally {
    await familySink.flush();
    await familySink.close();
  }

  print('FAMILY:');
  print(familyFile.readAsStringSync());
}
