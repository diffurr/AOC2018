import "dart:io";

List<int> readInput(String fileName) {
  List<int> data = File(fileName).readAsBytesSync().toList();
  return data;
}

bool react(int a, int b) {
  return a - b == 32 || a - b == -32;
}

int reaction(final List<int> polymer) {
  List<int> polyA = [];
  List<int> polyB = polymer.toList();

  do {
    polyA = polyB;
    polyB = [];

    var i;
    for(i = 0; i < polyA.length - 1; i++) {
      if (react(polyA[i], polyA[i + 1])) ++i;
      else polyB.add(polyA[i]);
    }
    if (i == polyA.length - 1) polyB.add(polyA[i]);

  } while (polyA.length != polyB.length);

  return polyA.length;
}

var timing = Stopwatch();

void main() {
  int answer = 0;

  timing.start();
  final List<int> polymer = readInput("input.txt");
  answer = reaction(polymer);
  timing.stop();

  print("Answer:  $answer");
  print("time:  ${timing.elapsedMilliseconds} ms");
  return;
}