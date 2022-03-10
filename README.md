# csvwriter

Lightweight Dart package to write CSV data to a `StringSink`. 

# Usage

```dart
import 'dart:io';

import 'package:csvwriter/csvwriter.dart';

void main() async {
  var numbersFile = File('test.csv');
  var numbersCsv = CsvWriter.withHeaders(numbersFile.openWrite(), ['Number', 'Odd?', 'Even?']);

  try {
    for (var i = 0; i < 100; i++) {
        numbersCsv['Number'] = i;
        numbersCsv['Odd?'] = (i % 2) != 0);
        numbersCsv['Even?'] = (i % 2) == 0);
        numbersCsv.writeData();
    }
  } finally {
      await numbersCsv.close();
  }
}
```

