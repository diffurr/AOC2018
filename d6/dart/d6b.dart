import "dart:io";

const int MAX_INT = (1 << 63) ^ -1;

class Point {
  int x, y;

  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

class Input {
  List<Point> points;
  int xmax, ymax, xdim, ydim;

  Input(points, xmax, ymax) {
    this.points = points;
    this.xmax = xmax;
    this.ymax = ymax;
    this.xdim = xmax + 1;
    this.ydim = ymax + 1;
  }
}

Input getInput(final String fileName) {
  var points = List<Point>();
  RegExp exp = new RegExp(r"(\d+), (\d+)");
  int xmax = 0;
  int ymax = 0;

  try {
    var lines = File(fileName).readAsLinesSync();
    for (var line in lines) {
      Match match = exp.firstMatch(line);
      if (match == null) throw "$fileName is wrong input file.";
      int x = int.parse(match.group(1));
      int y = int.parse(match.group(2));
      if (x < 0 || y < 0) throw "$fileName is wrong input file.";
      if (x > xmax) xmax = x;
      if (y > ymax) ymax = y;
      points.add(Point(x, y));
    }
  } catch(e) {
    print("$e");
    exit(1);
  }
  return Input(points, xmax, ymax);
}

int manhattan(Point p1, Point p2) {
  return (p1.x - p2.x).abs() + (p1.y - p2.y).abs();
}

int getAnswer(final Input input, int maxdist) {
  final List<Point> points = input.points;
  Point p2 = new Point(0, 0);
  int regions = 0;

  for (int y = 0; y < input.ydim; y++) {
    for (int x = 0; x < input.xdim; x++) {
      p2.x = x;
      p2.y = y;
      regions++;
      int sumdist = 0;
      for (Point p in points) {
        sumdist +=manhattan(p, p2);
        if (sumdist >= maxdist) {
          regions--;
          break;
        }
      }
    }
  }
  return regions;
}

void main() {
  var timing = Stopwatch();
  int answer = 0;
  Input input = getInput("input.txt");
  timing.start();
  answer = getAnswer(input, 10000);
  timing.stop();
  print("Answer: $answer");
  print("timing: ${timing.elapsedMilliseconds} ms");
}