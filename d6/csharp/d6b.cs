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

        static int getAnswer(Input input, int maxdist)
        {
            Point[] points = input.points;
            Point p2 = new Point(0, 0);
            int regions = 0;

            for (int y = 0; y < input.ydim; y++)
            {
                for (int x = 0; x < input.xdim; x++)
                {
                    int sumdist = 0;
                    p2.x = x; p2.y = y;
                    regions++;
                    for (int p = 0; p < points.Length; p++)
                    {
                        sumdist += manhattan(points[p], p2);
                        if (sumdist >= maxdist)
                        {
                            regions--;
                            break;
                        }
                    }
                }
            }
            return regions;
        }
        static void Main(string[] args)
        {
            Stopwatch timing = new Stopwatch();
            int answer = 0;
            Input input = readInput("input.txt");
            timing.Start();
            answer = getAnswer(input, 10000);
            timing.Stop();
            Console.WriteLine("answer: {0}", answer);
            Console.WriteLine("timing: {0} ms", timing.ElapsedMilliseconds);
        }
    }
}
