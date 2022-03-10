import 'dart:io';

import 'package:csvwriter/csvwriter.dart';

void main() async {
  var nbSink = StringBuffer();
  var nbWriter = CsvWriter.withHeaders(nbSink, ['Number', 'Odd?', 'Even?']);
  for (var i = 0; i < 100; i++) {
    nbWriter['Number'] = i;
    nbWriter['Odd?'] = (i % 2) != 0;
    nbWriter['Even?'] = (i % 2) == 0;
    nbWriter.writeData();
  }

  print('NUMBERS:');
  print(nbSink.toString());

  print('');

  var familyFile = File('test.csv');
  var familyWriter = CsvWriter.withHeaders(familyFile.openWrite(), [
    'Name',
    'First name',
    'Father name',
    'First name',
    'Mother name',
    'First name',
  ]);

  try {
    familyWriter.set(header: 'Name', value: 'Doe');
    familyWriter.set(header: 'Father name', value: 'Doe');
    familyWriter.set(header: 'First name', index: 1, value: 'John');
    familyWriter.set(header: 'Mother name', value: 'Smith');
    familyWriter.set(header: 'First name', index: 2, value: 'Ann');

    for (var i = 0; i < 5; i++) {
      familyWriter.set(header: 'First name', index: 0, value: 'John #$i, Jr');
      familyWriter.writeData(clear: false);
      if (i % 2 == 0) {
        await familyWriter.flush();
      }
    }
  } finally {
    await familyWriter.close();
  }

  print('FAMILY:');
  print(familyFile.readAsStringSync());
}
