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

onborderFunc(int xmax, ymax) {
  return (Point p) { return p.x == 0 || p.y == 0 || p.x == xmax || p.y == ymax; };
}

int getAnswer(final Input input) {
  final List<Point> points = input.points;
  List<int> ids = new List.filled(points.length, 0);
  var onborder = onborderFunc(input.xmax, input.ymax);
  Point p = new Point(0, 0);

  for (int y = 0; y < input.ydim; y++) {
    for (int x = 0; x < input.xdim; x++) {
      p.x = x;
      p.y = y;
      bool same = false;
      int mindist = MAX_INT;
      int minid = 0;
      for (int id = 0; id < points.length; id++) {
        int dist = manhattan(points[id], p);
        if (dist < mindist) {
          mindist = dist;
          minid = id;
          same = false;
        }
        else if (dist == mindist) same = true;
      }
      if (onborder(p)) ids[minid] = -1;
      else if (!onborder(p) && ids[minid] != -1 && !same) ids[minid]++;
    }
  }
  ids.sort();
  return ids.last;
}

void main() {
  var timing = Stopwatch();
  int answer = 0;
  Input input = getInput("input.txt");
  timing.start();
  answer = getAnswer(input);
  timing.stop();
  print("Answer: $answer");
  print("timing: ${timing.elapsedMilliseconds} ms");
}