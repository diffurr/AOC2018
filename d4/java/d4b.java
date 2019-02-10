import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.FileReader;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.lang.System;
import java.util.Set;
import java.util.Map;

class Record implements Comparable<Record> {
    int id;
    int minute;
    private long elapsed;

    Record(String input) {
        int year = Integer.parseInt(input, 1, 5, 10);
        int month = Integer.parseInt(input, 6, 8, 10);
        int day = Integer.parseInt(input, 9, 11, 10);
        int hour = Integer.parseInt(input, 12, 14, 10);
        minute = Integer.parseInt(input, 15, 17, 10);
        if (input.charAt(25) == '#') {
            // String idstr = input.substring(26, 30).strip();
            // id = Integer.parseInt(idstr);
            if (input.charAt(29) == ' ') {
                id = Integer.parseInt(input,26, 29, 10);
            }
            else {
                id = Integer.parseInt(input,26, 30, 10);
            }
        }
        else {
            id = -1;
        }
        elapsed = epoch(year, month, day, hour, minute, 0);
    }

    public int compareTo(Record r) {
        if (elapsed < r.elapsed) return -1;
        if (elapsed > r.elapsed) return 1;
        return 0;
    }

    private static long epoch(int year, int month, int day, int hour, int minute, int sec) {
        final int days_in_mon[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
        final long sec_in_year = 31557600;
        final int sec_in_day = 86400;
        final int sec_in_hour = 3600;
        long total = 0;

        total = (year - 1900) * sec_in_year;
        for (int i = 0; i < month - 1; i++) {
            total += days_in_mon[i] * sec_in_day;
        }
        total += day * sec_in_day;
        total += hour * sec_in_hour;
        total += minute * 60;
        total += sec;
        return total;
    }
}

public class d4b {
    private static ArrayList<Record> parse(BufferedReader in) {
        ArrayList<Record> records = new ArrayList<>();
        String line = null;
        try {
            while ((line = in.readLine()) != null) {
                records.add(new Record(line));
            }
        } catch (IOException e) {
            System.out.println("parse() IOException.");
        }
        return records;
    }

    private static void markMinutes(short ttable[], int begin, int end) {
        for (int i = begin; i < end; i++) {
            ttable[i]++;
        }
    }

    private static HashMap<Integer, short[]> update(ArrayList<Record> records) {
        HashMap<Integer, short[]> timeTables = new HashMap<>(101);
        short ttable[];
        int id = -1;
        int begin = -1;

        for (Record record : records) {
            if (record.id >= 0) id = record.id;
            else if (begin < 0) begin = record.minute;
            else {
                if ((ttable = timeTables.get(id)) != null) {
                    markMinutes(ttable, begin, record.minute);
                }
                else {
                   ttable = new short[60]; 
                   Arrays.fill(ttable, (short) 0);
                   markMinutes(ttable, begin, record.minute);
                   timeTables.put(id, ttable);
                }
                begin = -1;
            }
        } 
        return timeTables;
    }

    private static int getAnswer(HashMap<Integer, short[]> timeTables) {
        Set<Map.Entry<Integer, short[]>> tables = timeTables.entrySet();
        short ttable[] = null;
        int bestid = -1;
        int bestfreq = -1;
        int bestmin = -1; 

        for (Map.Entry<Integer, short[]> id : tables) {
            ttable = id.getValue();
            for (int i = 0; i < ttable.length; i++) {
                if (ttable[i] > bestfreq) {
                    bestfreq = ttable[i];
                    bestmin = i;
                    bestid = id.getKey();
                }
            }
        }
        return bestid * bestmin;
    }

    public static void main(String[] args) {
        BufferedReader in = null;
        ArrayList<Record> records = null;
        HashMap<Integer, short[]> timeTables = null;
        long startTime, parseTime, updateTime, sortTime, answerTime;
        int answer = 0;
        
        try {
        in = new BufferedReader(new FileReader("input.txt"));
        }
        catch (FileNotFoundException e) {
            System.out.println("main() can't open file.");
        }

        startTime = System.nanoTime();
        records = parse(in);
        parseTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        records.sort(null);
        sortTime = System.nanoTime() - startTime;
        
        startTime = System.nanoTime();
        timeTables = update(records);
        updateTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        answer = getAnswer(timeTables);
        answerTime = System.nanoTime() - startTime;

        System.out.println("Answer: " + answer);
        System.out.println("parse:  " + parseTime / 1000 + " us");
        System.out.println("update: " + updateTime / 1000 + " us");
        System.out.println("sort:   " + sortTime / 1000 + " us");
        System.out.println("answer: " + answerTime / 1000 + " us");
    }
}