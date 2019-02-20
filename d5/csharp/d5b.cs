using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Diagnostics;

namespace d5b
{
    class Program
    {
        static Stopwatch timing = new Stopwatch();
        static List<byte> polymer = null;
        static List<long> lens = null;
        static char[] elements = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
                'X', 'Y', 'Z'};

        static void Main(string[] args)
        {
            long answer = 0;
            timing.Start();
            polymer = readPolymer("input.txt");
            lens = new List<long>();
            foreach (char c in elements)
            {
                lens.Add(reaction1(remove(polymer, c)));
            }
            answer = lens.Min();
            timing.Stop();
            Console.WriteLine("Answer:  " + answer);
            Console.WriteLine("time:  " + timing.ElapsedMilliseconds + " ms");
            Console.ReadKey();
        }

        private static List<byte> remove(List<byte> poly, char elem)
        {
            List<byte> result = new List<byte>(poly);

            result.RemoveAll(x => x == elem || x == elem + 32);
            return result;
        }

        private static bool react(byte a, byte b)
        {
            return a - b == 32 || a - b == -32;
        }

        private static long reaction1(List<byte> polymer)
        {
            List<byte> polyA = new List<byte>(polymer.Count);
            List<byte> polyB = new List<byte>(polymer);
            List<byte> temp = null;

            do
            {
                temp = polyA;
                polyA = polyB;
                polyB = temp;
                polyB.Clear();

                int i;
                for (i = 0; i < polyA.Count - 1; i++)
                {
                    if (react(polyA[i], polyA[i + 1])) ++i;
                    else polyB.Add(polyA[i]);
                }
                if (i == polyA.Count - 1) polyB.Add(polyA[i]);
            } while (polyA.Count != polyB.Count);

            return polyA.Count;
        }

        private static List<byte> readPolymer(String fileName)
        {
            List<byte> list = new List<byte>();
            char[] data = null;
            try
            {
                data = new StreamReader(fileName).ReadToEnd().ToCharArray();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Environment.Exit(666);
            }

            foreach (char c in data)
            {
                list.Add((byte)c);
            }

            return list;
        }
    }
}
