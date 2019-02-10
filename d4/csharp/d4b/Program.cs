using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;

namespace d4b
{
    static class Date
    {
        private static int[] days_in_mon = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
        private const long sec_in_year = 31557600;
        private const int sec_in_day = 86400;
        private const int sec_in_hour = 3600;
            
        public static long epoch(int year, int month, int day, int hour, int minute)
        {
            long total = 0;
            total = (year - 1900) * sec_in_year;
            for (int i = 0; i < month - 1; i++)
            {
                total += days_in_mon[i] * sec_in_day;
            }
            total += day * sec_in_day;
            total += hour * sec_in_hour;
            total += minute * 60;
            return total;
        }
    }

    class Record : IComparable<Record>
    {
        public readonly int id;
        public readonly int minute;
        readonly long elapsed;

        public Record(string line)
        {
            int year = int.Parse(line.Substring(1, 4));
            int month = int.Parse(line.Substring(6, 2));
            int day = int.Parse(line.Substring(9, 2));
            int hour = int.Parse(line.Substring(12, 2));
            this.minute = int.Parse(line.Substring(15, 2));

            if (line.Length < 40 || !int.TryParse(line.Substring(26, 4), out this.id))
                this.id = -1;

            this.elapsed = Date.epoch(year, month, day, hour, minute);
        }

        public int CompareTo(Record rec)
        {
            return this.elapsed.CompareTo(rec.elapsed);
        }
    }

    class Program
    {
        static Stopwatch parseTime = new Stopwatch();
        static Stopwatch sortTime = new Stopwatch();
        static Stopwatch updateTime = new Stopwatch();
        static Stopwatch answerTime = new Stopwatch();
        static StreamReader input = null;
        static List<Record> records = null;
        static Dictionary<int, short[]> timeTables = null;
        static int answer = 0;

        static void Main(string[] args)
        {
            input = new StreamReader("input.txt");

            parseTime.Start();
            records = parse(input);
            parseTime.Stop();

            sortTime.Start();
            records.Sort();
            sortTime.Stop();

            updateTime.Start();
            timeTables = update(records);
            updateTime.Stop();

            answerTime.Start();
            answer = getAnswer(timeTables);
            answerTime.Stop();

            Console.WriteLine("Answer: " + answer);
            if (Stopwatch.IsHighResolution)
            {
                Console.WriteLine("High-resolution timer.");
            }
            else
            {
                Console.WriteLine("Standard timer.");
            }
            Console.WriteLine("parse:  " + parseTime.ElapsedTicks * 1000000L / Stopwatch.Frequency);
            Console.WriteLine("sort:   " + sortTime.ElapsedTicks * 1000000L / Stopwatch.Frequency);
            Console.WriteLine("update: " + updateTime.ElapsedTicks * 1000000L / Stopwatch.Frequency);
            Console.WriteLine("answer: " + answerTime.ElapsedTicks * 1000000L / Stopwatch.Frequency);
        }

        static int getAnswer(Dictionary<int, short[]> timeTables)
        {
            short[] ttable = null;
            int bestid = -1;
            int bestminute = -1;
            int bestfreq = -1;

            //foreach (int id in timeTables.Keys)
            //{
            //    ttable = timeTables[id];
            //    for (int minute = 0; minute < ttable.Length; minute++)
            //    {
            //        if (ttable[minute] > bestfreq)
            //        {
            //            bestfreq = ttable[minute];
            //            bestminute = minute;
            //            bestid = id;
            //        }
            //    }
            //}
            foreach (KeyValuePair<int, short[]> id in timeTables)
            {
                ttable = id.Value;
                for (int minute = 0; minute < ttable.Length; minute++)
                {
                    if (ttable[minute] > bestfreq)
                    {
                        bestfreq = ttable[minute];
                        bestminute = minute;
                        bestid = id.Key;
                    }
                }
            }

            return bestid * bestminute;
        }

        static void markMinutes(short[] ttable, int begin, int end)
        {
            for (int i = begin; i < end; i++)
            {
                ttable[i]++;
            }
        }

        static void initArray<T>(T[] arr, T val)
        {
            for (int i = 0; i < arr.Length; i++)
            {
                arr[i] = val; 
            }
        }

        static Dictionary<int, short[]> update(List<Record> records)
        {
            Dictionary<int, short[]> timeTables = new Dictionary<int, short[]>();
            short[] ttable = null;
            int id = -1;
            int begin = -1;

            foreach(Record record in records)
            {
                if (record.id >= 0) id = record.id;
                else if (begin < 0) begin = record.minute;
                else
                {
                    if (timeTables.TryGetValue(id, out ttable))
                    {
                        markMinutes(ttable, begin, record.minute);
                    }
                    else
                    {
                        ttable = new short[60];
                        initArray<short>(ttable, 0);
                        markMinutes(ttable, begin, record.minute);
                        timeTables.Add(id, ttable);
                    }
                    begin = -1;
                }
            }

            return timeTables;
        }

        static List<Record> parse(StreamReader input)
        {
            List<Record> records = new List<Record>();
            string line = null;

            while((line = input.ReadLine()) != null)
            {
                records.Add(new Record(line));
            }

            return records;
        }
    }
}
