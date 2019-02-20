using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace d6a
{
    struct Point
    {
        public int x, y;
        public Point(int x, int y)
        {
            if (x < 0 || y < 0 || x > int.MaxValue - 1 || y > int.MaxValue - 1) throw new ArgumentOutOfRangeException();
            this.x = x; this.y = y;
        }
    }
    struct Input
    {
        public readonly Point[] points;
        public readonly int xmax, ymax, xdim, ydim;
        public Input(Point[] points, int xmax, int ymax)
        {
            if (points == null || xmax > int.MaxValue - 1 || ymax > int.MaxValue - 1) throw new ArgumentOutOfRangeException();
            this.points = points;
            this.xmax = xmax;
            this.ymax = ymax;
            this.xdim = xmax + 1;
            this.ydim = ymax + 1;
        }
    }
    class Program
    {
        static Input readInput(string fileName)
        {
            List<Point> points = new List<Point>();
            string line = null;
            int xmax = 0; int ymax = 0;
            try
            {
                StreamReader reader = new StreamReader(fileName);
                while ((line = reader.ReadLine()) != null)
                {
                    Match m = Regex.Match(line, @"(\d+), (\d+)");
                    int x = int.Parse(m.Groups[1].ToString());
                    int y = int.Parse(m.Groups[2].ToString());
                    if (x > xmax) xmax = x;
                    if (y > ymax) ymax = y;
                    points.Add(new Point(x, y));
                }
                reader.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Environment.Exit(1);
            }
            return new Input(points.ToArray(), xmax, ymax);
        }

        static int manhattan(Point p1, Point p2)
        {
            return Math.Abs(p1.x - p2.x) + Math.Abs(p1.y - p2.y);
        }

        static int getAnswer(Input input)
        {
            Point[] points = input.points;
            int[] ids = new int[points.Length];
            Point p = new Point(0, 0);

            Func<int, int, bool> infinit = (x, y) => x == 0 || y == 0 || x == input.xmax || y == input.ymax;

            for (int y = 0; y < input.ydim; y++)
            {
                for (int x = 0; x < input.xdim; x++)
                {
                    int mindist = int.MaxValue;
                    int minid = 0;
                    bool same = false;
                    p.x = x; p.y = y;
                    for (int id = 0; id < points.Length; id++)
                    {
                        int dist = manhattan(points[id], p);
                        if (dist < mindist)
                        {
                            mindist = dist;
                            minid = id;
                            same = false;
                        }
                        else if (dist == mindist)
                            same = true;
                    }
                    if (infinit(x, y))
                        ids[minid] = -1;
                    else if (!same && ids[minid] != -1 && !infinit(x, y))
                        ids[minid]++;
                }
            }
            Array.Sort(ids);
            return ids[ids.Length - 1];
        } 
        static void Main(string[] args)
        {
            Stopwatch timing = new Stopwatch();
            int answer = 0;
            Input input = readInput("input.txt");
            timing.Start();
            answer = getAnswer(input);
            timing.Stop();
            Console.WriteLine("answer: {0}", answer);
            Console.WriteLine("timing: {0} ms", timing.ElapsedMilliseconds);
        }
    }
}
