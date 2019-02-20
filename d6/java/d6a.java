import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;

class Point {
    int x, y;
    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

class Input {
    Point[] points;
    int xmax, ymax, xdim, ydim;
    Input(ArrayList<Point> points, int xmax, int ymax) {
        this.points = new Point[points.size()];
        this.points = points.toArray(this.points);
        this.xmax = xmax;
        this.ymax = ymax;
        this.xdim = xmax + 1;
        this.ydim = ymax + 1;
    }

    boolean infinit(int x, int y) {
        return x == 0 || y == 0 || x == xmax || y == ymax;
    }
}
    
public class d6a {
    private static Input readInput(String fileName) {
        ArrayList<Point> points = new ArrayList<>();
        String line;
        int xmax = 0;
        int ymax = 0;

        try {
            BufferedReader br = new BufferedReader(new FileReader(fileName));
            while ((line = br.readLine()) != null) {
                String[] nums = line.split(",");
                if (nums.length != 2) throw new IllegalArgumentException("Too many numbers in line");
                int x = Integer.parseInt(nums[0].strip());
                int y = Integer.parseInt(nums[1].strip());
                if (x > xmax) xmax = x;
                if (y > ymax) ymax = y;
                if (x < 0 || y < 0 || x > Integer.MAX_VALUE - 1 || y > Integer.MAX_VALUE - 1) {
                    throw new IllegalArgumentException("Coordinates out of range");
                }
                points.add(new Point(x, y));
            }
            br.close();
        } catch (Exception e) {
            System.out.println(e.toString());
        }
        return new Input(points, xmax, ymax);
    }

    private static int manhattan(Point p1, Point p2) {
        return Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y);
    }

    private static int getAnswer(Input input) {
        Point[] points = input.points;
        int[] ids = new int[points.length];
        Arrays.fill(ids, 0);
        Point p = new Point(0, 0);

        for (int y = 0; y < input.ydim; y++) {
            for (int x = 0; x < input.xdim; x++) {
                int mindist = Integer.MAX_VALUE;
                int minid = 0;
                boolean same = false;
                p.x = x; 
                p.y = y;
                for (int id = 0; id < points.length; id++) {
                    int dist = manhattan(points[id], p); 
                    if (dist < mindist) {
                        mindist = dist;
                        minid = id;
                        same = false;
                    }
                    else if (dist == mindist) same = true;
                    //else do nothing, go to next point
                }
                if (input.infinit(x, y)) {
                    ids[minid] = -1;
                }
                else if (!same && !input.infinit(x, y) && ids[minid] != -1) {
                    ids[minid]++;
                }
            }
        }
        Arrays.sort(ids);
        return ids[ids.length - 1];
    }

    public static void main(String[] args) {
        int answer = 0;
        final Input input = readInput("input.txt");
        long start = System.nanoTime();
        answer = getAnswer(input);
        long end = System.nanoTime() - start;
        System.out.println("answer :" + answer);
        System.out.println("timing :" + end / 1000000 + " ms");
    }
}
