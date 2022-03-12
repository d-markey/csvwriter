@TestOn('vm')

import 'dart:io';

import 'package:csvwriter/csvwriter.dart';
import 'package:test/test.dart';

void main() {
  group('VM - StringBuffer', () {
    test('No header', () {
      final sb = StringBuffer();
      final writer = CsvWriter(sb, 3);

      writer.set('First record', index: 0);
      writer.set('A #1', index: 1);
      writer.set('B #1', index: 2);
      writer.writeData();

      writer.set('Second record', index: 0);
      writer.set('A #2', index: 1);
      writer.set('B #2', index: 2);
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 2 records
      expect(lines[0],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[1],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv, equals('First record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Default', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer['Header #1'] = 'First record';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      writer['Header #1'] = 'Second record';
      writer['Header #2'] = 'A #2';
      writer['Header #3'] = 'B #2';
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\nFirst record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Duplicate headers', () {
      final sb = StringBuffer();
      final headers = ['Header', 'Value', 'Value'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer.set('First record', header: 'Header');
      writer.set('A #1', header: 'Value', index: 0);
      writer.set('B #1', header: 'Value', index: 1);
      writer.writeData();

      writer.set('Second record', header: 'Header');
      writer.set('A #2', header: 'Value', index: 0);
      writer.set('B #2', header: 'Value', index: 1);
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0], equals('Header,Value,Value')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header,Value,Value\r\nFirst record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Indexed headers', () {
      final sb = StringBuffer();
      final headers = ['Header', 'Value', 'Value'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer.set('First record', index: 0);
      writer.set('A #1', index: 1);
      writer.set('B #1', index: 2);
      writer.writeData();

      writer.set('Second record', index: 0);
      writer.set('A #2', index: 1);
      writer.set('B #2', index: 2);
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0], equals('Header,Value,Value')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header,Value,Value\r\nFirst record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Setting values - one by one', () {
      final sb = StringBuffer();
      final headers = ['Header', 'Value', 'Value'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer['Header'] = 'TEST #1';
      expect(writer['Header'], equals('TEST #1'));

      writer.set('TEST #2', header: 'Header');
      expect(writer.get(header: 'Header'), equals('TEST #2'));

      writer.set('TEST #2', header: 'Header', index: 0);
      expect(writer.get(header: 'Header', index: 0), equals('TEST #2'));

      expect(() => writer.set('MUST THROW', header: 'Header', index: 1),
          throwsA(isA<InvalidHeaderException>()));

      expect(() => writer['Value'] = 'MUST THROW',
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.set('MUST THROW', header: 'Value'),
          throwsA(isA<InvalidHeaderException>()));

      writer.set('VALUE #1', header: 'Value', index: 0);
      expect(writer.get(header: 'Value', index: 0), equals('VALUE #1'));

      writer.set('VALUE #2', header: 'Value', index: 1);
      expect(writer.get(header: 'Value', index: 1), equals('VALUE #2'));

      expect(() => writer.set('MUST THROW', header: 'Value', index: 2),
          throwsA(isA<InvalidHeaderException>()));

      expect(() => writer['Undefined'] = 'MUST THROW',
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.set('MUST THROW', header: 'Undefined'),
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.set('MUST THROW', header: 'Undefined', index: 1),
          throwsA(isA<InvalidHeaderException>()));
    });

    test('Setting values - using a List', () {
      final sb = StringBuffer();
      final headers = ['Header', 'Value', 'Value'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer.setData(['TEST #1', 'VALUE #1', 'VALUE #2']);
      expect(writer['Header'], equals('TEST #1'));
      expect(writer.get(header: 'Value', index: 0), equals('VALUE #1'));
      expect(writer.get(header: 'Value', index: 1), equals('VALUE #2'));

      writer.setData(['TEST #2']);
      expect(writer['Header'], equals('TEST #2'));
      expect(writer.get(header: 'Value', index: 0), equals('VALUE #1'));
      expect(writer.get(header: 'Value', index: 1), equals('VALUE #2'));

      expect(
          () =>
              writer.setData(['TEST #1', 'VALUE #1', 'VALUE #2', 'MUST THROW']),
          throwsA(isA<InvalidHeaderException>()));
    });

    test('Setting values - using a Map<String, dynamic>', () {
      final sb = StringBuffer();
      final headers = ['Header', 'Value 1', 'Value 2'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer.setData(
          {'Header': 'TEST #1', 'Value 1': 'VALUE #1', 'Value 2': 'VALUE #2'});
      expect(writer['Header'], equals('TEST #1'));
      expect(writer['Value 1'], equals('VALUE #1'));
      expect(writer['Value 2'], equals('VALUE #2'));

      writer.setData({'Header': 'TEST #2'});
      expect(writer['Header'], equals('TEST #2'));
      expect(writer['Value 1'], equals('VALUE #1'));
      expect(writer['Value 2'], equals('VALUE #2'));

      expect(
          () => writer.setData({
                'Header': 'TEST #1',
                'Value 1': 'VALUE #1',
                'Value 2': 'VALUE #2',
                'Value 3': 'MUST THROW'
              }),
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.setData({'Bad Header': 'MUST THROW'}),
          throwsA(isA<InvalidHeaderException>()));
    });

    test('Separator: ;', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers, separator: ';');

      writer['Header #1'] = 'First record';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      writer['Header #1'] = 'Second record';
      writer['Header #2'] = 'A #2';
      writer['Header #3'] = 'B #2';
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1;Header #2;Header #3')); // first line = header
      expect(lines[1],
          equals('First record;A #1;B #1')); // second line = first record
      expect(lines[2],
          equals('Second record;A #2;B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header #1;Header #2;Header #3\r\nFirst record;A #1;B #1\r\nSecond record;A #2;B #2\r\n'));
    });

    test('End-of-line: \\n', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers, endOfLine: '\n');

      writer['Header #1'] = 'First record';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      writer['Header #1'] = 'Second record';
      writer['Header #2'] = 'A #2';
      writer['Header #3'] = 'B #2';
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\nFirst record,A #1,B #1\nSecond record,A #2,B #2\n'));
    });

    test('Escaped Values - separator', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer['Header #1'] = 'First test, with commas, must be escaped';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1],
          equals(
              '"First test, with commas, must be escaped",A #1,B #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\n"First test, with commas, must be escaped",A #1,B #1\r\n'));
    });

    test('Escaped Values - new lines', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer['Header #1'] = 'Multi line test.\nIt must be escaped';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1],
          equals(
              '"Multi line test.\nIt must be escaped",A #1,B #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\n"Multi line test.\nIt must be escaped",A #1,B #1\r\n'));
    });

    test('Escaped Values - quotes', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer['Header #1'] = 'It contains a " and must be escaped';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1],
          equals(
              '"It contains a "" and must be escaped",A #1,B #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\n"It contains a "" and must be escaped",A #1,B #1\r\n'));
    });

    test('Retain values', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer['Header #1'] = 'ITEM 1';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData(clear: false);
      expect(writer['Header #1'], equals('ITEM 1'));
      expect(writer['Header #2'], equals('A #1'));
      expect(writer['Header #3'], equals('B #1'));

      writer['Header #2'] = 'C #1';
      writer['Header #3'] = 'D #1';
      writer.writeData();
      expect(writer['Header #1'], isNull);
      expect(writer['Header #2'], isNull);
      expect(writer['Header #3'], isNull);

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1], equals('ITEM 1,A #1,B #1')); // second line = first record
      expect(
          lines[2], equals('ITEM 1,C #1,D #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\nITEM 1,A #1,B #1\r\nITEM 1,C #1,D #1\r\n'));
    });

    test('Write structured data - List', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer.writeData(data: ['ITEM 1', 'A #1', 'B #1'], clear: false);
      expect(writer['Header #1'], equals('ITEM 1'));
      expect(writer['Header #2'], equals('A #1'));
      expect(writer['Header #3'], equals('B #1'));

      writer.writeData(data: ['ITEM 1', 'C #1', 'D #1']);
      expect(writer['Header #1'], isNull);
      expect(writer['Header #2'], isNull);
      expect(writer['Header #3'], isNull);

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1], equals('ITEM 1,A #1,B #1')); // second line = first record
      expect(
          lines[2], equals('ITEM 1,C #1,D #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\nITEM 1,A #1,B #1\r\nITEM 1,C #1,D #1\r\n'));
    });

    test('Write structured data - Map<String, dynamic>', () {
      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);

      writer.writeData(data: {
        'Header #1': 'ITEM 1',
        'Header #2': 'A #1',
        'Header #3': 'B #1'
      }, clear: false);
      expect(writer['Header #1'], equals('ITEM 1'));
      expect(writer['Header #2'], equals('A #1'));
      expect(writer['Header #3'], equals('B #1'));

      writer.writeData(
          data: {'Header #2': 'C #1', 'Header #3': 'D #1'}, clear: false);
      expect(writer['Header #1'], equals('ITEM 1'));
      expect(writer['Header #2'], equals('C #1'));
      expect(writer['Header #3'], equals('D #1'));

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1], equals('ITEM 1,A #1,B #1')); // second line = first record
      expect(
          lines[2], equals('ITEM 1,C #1,D #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\nITEM 1,A #1,B #1\r\nITEM 1,C #1,D #1\r\n'));
    });

    test('Close', () async {
      var closed = false;

      final sb = StringBuffer();
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(sb, headers);
      writer.done.whenComplete(() {
        closed = true;
      });

      writer.writeData(data: {
        'Header #1': 'ITEM 1',
        'Header #2': 'A #1',
        'Header #3': 'B #1'
      }, clear: false);

      await writer.close();

      expect(closed, isTrue);

      final csv = sb.toString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1], equals('ITEM 1,A #1,B #1')); // second line = first record

      expect(
          csv, equals('Header #1,Header #2,Header #3\r\nITEM 1,A #1,B #1\r\n'));
    });
  });

  group('VM - IOSink', () {
    final file = File('.test.data.csv');

    setUp(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    tearDown(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('No header', () async {
      final writer = CsvWriter(file.openWrite(mode: FileMode.write), 3);

      writer.set('First record', index: 0);
      writer.set('A #1', index: 1);
      writer.set('B #1', index: 2);
      writer.writeData();

      writer.set('Second record', index: 0);
      writer.set('A #2', index: 1);
      writer.set('B #2', index: 2);
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 2 records
      expect(lines[0],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[1],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv, equals('First record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Default', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer['Header #1'] = 'First record';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      writer['Header #1'] = 'Second record';
      writer['Header #2'] = 'A #2';
      writer['Header #3'] = 'B #2';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\nFirst record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Duplicate headers', () async {
      final headers = ['Header', 'Value', 'Value'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer.set('First record', header: 'Header');
      writer.set('A #1', header: 'Value', index: 0);
      writer.set('B #1', header: 'Value', index: 1);
      writer.writeData();

      writer.set('Second record', header: 'Header');
      writer.set('A #2', header: 'Value', index: 0);
      writer.set('B #2', header: 'Value', index: 1);
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0], equals('Header,Value,Value')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header,Value,Value\r\nFirst record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Indexed headers', () async {
      final headers = ['Header', 'Value', 'Value'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer.set('First record', index: 0);
      writer.set('A #1', index: 1);
      writer.set('B #1', index: 2);
      writer.writeData();

      writer.set('Second record', index: 0);
      writer.set('A #2', index: 1);
      writer.set('B #2', index: 2);
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0], equals('Header,Value,Value')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header,Value,Value\r\nFirst record,A #1,B #1\r\nSecond record,A #2,B #2\r\n'));
    });

    test('Setting values', () async {
      final headers = ['Header', 'Value', 'Value'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer['Header'] = 'TEST #1';
      expect(writer['Header'], equals('TEST #1'));

      writer.set('TEST #2', header: 'Header');
      expect(writer.get(header: 'Header'), equals('TEST #2'));

      writer.set('TEST #2', header: 'Header', index: 0);
      expect(writer.get(header: 'Header', index: 0), equals('TEST #2'));

      expect(() => writer.set('MUST THROW', header: 'Header', index: 1),
          throwsA(isA<InvalidHeaderException>()));

      expect(() => writer['Value'] = 'MUST THROW',
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.set('MUST THROW', header: 'Value'),
          throwsA(isA<InvalidHeaderException>()));

      writer.set('VALUE #1', header: 'Value', index: 0);
      expect(writer.get(header: 'Value', index: 0), equals('VALUE #1'));

      writer.set('VALUE #2', header: 'Value', index: 1);
      expect(writer.get(header: 'Value', index: 1), equals('VALUE #2'));

      expect(() => writer.set('MUST THROW', header: 'Value', index: 2),
          throwsA(isA<InvalidHeaderException>()));

      expect(() => writer['Undefined'] = 'MUST THROW',
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.set('MUST THROW', header: 'Undefined'),
          throwsA(isA<InvalidHeaderException>()));
      expect(() => writer.set('MUST THROW', header: 'Undefined', index: 1),
          throwsA(isA<InvalidHeaderException>()));

      await writer.close();
    });

    test('Separator: ;', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(
          file.openWrite(mode: FileMode.write), headers,
          separator: ';');

      writer['Header #1'] = 'First record';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      writer['Header #1'] = 'Second record';
      writer['Header #2'] = 'A #2';
      writer['Header #3'] = 'B #2';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1;Header #2;Header #3')); // first line = header
      expect(lines[1],
          equals('First record;A #1;B #1')); // second line = first record
      expect(lines[2],
          equals('Second record;A #2;B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header #1;Header #2;Header #3\r\nFirst record;A #1;B #1\r\nSecond record;A #2;B #2\r\n'));
    });

    test('End-of-line: \\n', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer = CsvWriter.withHeaders(
          file.openWrite(mode: FileMode.write), headers,
          endOfLine: '\n');

      writer['Header #1'] = 'First record';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      writer['Header #1'] = 'Second record';
      writer['Header #2'] = 'A #2';
      writer['Header #3'] = 'B #2';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(lines[1],
          equals('First record,A #1,B #1')); // second line = first record
      expect(lines[2],
          equals('Second record,A #2,B #2')); // third line = second record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\nFirst record,A #1,B #1\nSecond record,A #2,B #2\n'));
    });

    test('Escaped Values - separator', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer['Header #1'] = 'First test, with commas, must be escaped';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1],
          equals(
              '"First test, with commas, must be escaped",A #1,B #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\n"First test, with commas, must be escaped",A #1,B #1\r\n'));
    });

    test('Escaped Values - new lines', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer['Header #1'] = 'Multi line test.\nIt must be escaped';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1],
          equals(
              '"Multi line test.\nIt must be escaped",A #1,B #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\n"Multi line test.\nIt must be escaped",A #1,B #1\r\n'));
    });

    test('Escaped Values - quotes', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer['Header #1'] = 'It contains a " and must be escaped';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1],
          equals(
              '"It contains a "" and must be escaped",A #1,B #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\n"It contains a "" and must be escaped",A #1,B #1\r\n'));
    });

    test('Retain values', () async {
      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);

      writer['Header #1'] = 'ITEM 1';
      writer['Header #2'] = 'A #1';
      writer['Header #3'] = 'B #1';
      writer.writeData(clear: false);

      writer['Header #2'] = 'C #1';
      writer['Header #3'] = 'D #1';
      writer.writeData();

      await writer.close();
      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(3)); // 1 header + 2 records
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1], equals('ITEM 1,A #1,B #1')); // second line = first record
      expect(
          lines[2], equals('ITEM 1,C #1,D #1')); // second line = first record

      expect(
          csv,
          equals(
              'Header #1,Header #2,Header #3\r\nITEM 1,A #1,B #1\r\nITEM 1,C #1,D #1\r\n'));
    });

    test('Close', () async {
      var closed = false;

      final headers = ['Header #1', 'Header #2', 'Header #3'];
      final writer =
          CsvWriter.withHeaders(file.openWrite(mode: FileMode.write), headers);
      writer.done.whenComplete(() {
        closed = true;
      });

      writer.writeData(data: {
        'Header #1': 'ITEM 1',
        'Header #2': 'A #1',
        'Header #3': 'B #1'
      }, clear: false);

      await writer.close();

      expect(closed, isTrue);

      final csv = await file.readAsString();

      final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();

      expect(lines.length, equals(2)); // 1 header + 1 record
      expect(lines[0],
          equals('Header #1,Header #2,Header #3')); // first line = header
      expect(
          lines[1], equals('ITEM 1,A #1,B #1')); // second line = first record

      expect(
          csv, equals('Header #1,Header #2,Header #3\r\nITEM 1,A #1,B #1\r\n'));
    });
  });
}
