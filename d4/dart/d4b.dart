import "dart:io";

class Record implements Comparable<Record> {
  int id;
  int minute;
  int elapsed;

  Record(final String line) {
    int year = int.parse(line.substring(1, 5));
    int month = int.parse(line.substring(6, 8));
    int day = int.parse(line.substring(9, 11));
    int hour = int.parse(line.substring(12, 14));
    this.minute = int.parse(line.substring(15, 17));
    if (line[25] == '#') this.id = int.parse(line.substring(26, 30));
    else this.id = -1;
    this.elapsed = Record.epoch(year, month, day, hour, this.minute);
  }
  
  static int epoch(int year, int month, int day, int hour, int minute) {
    const DAYS_IN_MON = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const SEC_IN_YEAR = 31557600;
    const SEC_IN_DAY = 86400;
    const SEC_IN_HOUR = 3600;
  
    int total = (year - 1600) * SEC_IN_YEAR;
    for (var i = 0; i < month - 1; i++)
      total += DAYS_IN_MON[i] * SEC_IN_DAY;
    total += day * SEC_IN_DAY;
    total += hour * SEC_IN_HOUR;
    total += minute * 60;
    return total;
  }

  int compareTo(final Record other) {
    return this.elapsed.compareTo(other.elapsed);
  }
}

List parse(final File file) {
  var records = List<Record>();
  var lines = file.readAsLinesSync();

  for (var line in lines) {
    records.add(Record(line));
  }

  return records;
}

void markMinutes(List<int> ttable, final int begin, final int end){
  for (var i = begin; i < end; i++) ttable[i]++;
}

Map update(final List<Record> records) {
  var timeTables = Map<int, List<int>>();
  var id = -1;
  var begin = -1;
  var value;

  for (var record in records) {
    if (record.id >= 0) id = record.id;
    else if (begin < 0) begin = record.minute;
    else {
      value = timeTables[id];
      if (value != null) {
        markMinutes(value, begin, record.minute);  
      }
      else {
        value = List<int>.filled(60, 0);
        markMinutes(value, begin, record.minute);
        timeTables[id] = value;
      }
      begin = -1;
    }
  }
  return timeTables;
}

int getAnswer(final Map<int, List<int>> timeTables) {
  var bestid = -1;
  var bestfreq = -1;
  var bestminute = -1;

  timeTables.forEach((id, ttable) {
    for (var minute = 0; minute < ttable.length; minute++) {
      if (ttable[minute] > bestfreq) {
        bestfreq = ttable[minute];
        bestminute = minute;
        bestid = id;
      }
    }
  });

  return bestid * bestminute;
}

void main() {
  var parseTime = Stopwatch();
  var sortTime = Stopwatch();
  var updateTime = Stopwatch();
  var answerTime = Stopwatch();
  var records = List<Record>();
  var timeTables = Map<int, List<int>>();
  var answer = 0;

  parseTime.start();
  records = parse(File("input.txt")); 
  parseTime.stop();

  sortTime.start();
  records.sort();
  sortTime.stop();

  updateTime.start();
  timeTables = update(records);
  updateTime.stop();

  answerTime.start();
  answer = getAnswer(timeTables);
  answerTime.stop();

  print("Answer: " + answer.toString());
  print("parse:  " + parseTime.elapsedMicroseconds.toString());
  print("sort:   " + sortTime.elapsedMicroseconds.toString());
  print("update: " + updateTime.elapsedMicroseconds.toString());
  print("answer: " + answerTime.elapsedMicroseconds.toString());
}