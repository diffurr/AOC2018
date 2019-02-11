import java.io.IOException;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

public class d5b {
    // not safe, buffer size converted from long to int
    // next time BufferedReader;)
    private static ArrayList<Byte> readPolymer(String fileName) {
        final File file = new File(fileName);
        final long size = file.length();
        ArrayList<Byte> array = new ArrayList<>((int) size);
        char[] buffer = new char[(int) size];
        try {
            final FileReader freader = new FileReader(file);
            freader.read(buffer);
            freader.close();
        } catch (IOException e) {
            System.out.println(e.getMessage());
        }
        for (int i = 0; i < size; i++) {
            array.add((byte) buffer[i]);
        }
        return array;
    }

    private static boolean react(byte a, byte b) {
        int diff = a - b;
        return (diff == 32 || diff == -32);
    }
    //TODO
    private static long reaction(final ArrayList<Byte> inputPolymer) {
        ArrayList<Byte> polyA = new ArrayList<Byte>(inputPolymer.size());
        ArrayList<Byte> polyB = new ArrayList<Byte>(inputPolymer);
        ArrayList<Byte> temp = null;

        do {
            temp = polyA;
            polyA = polyB;
            polyB = temp;
            polyB.clear();

            int i;
            for (i = 0; i < polyA.size() - 1; i++) {
                if (react(polyA.get(i), polyA.get(i + 1))) ++i;
                else {
                    polyB.add(polyA.get(i));
                }
            } 
            if (i == polyA.size() - 1) polyB.add(polyA.get(i));
        } while (polyA.size() != polyB.size());
        return polyA.size();
    }

    private static ArrayList<Byte> filter(ArrayList<Byte> lst, byte elem) {
        final ArrayList<Byte> in = lst;
        ArrayList<Byte> out = new ArrayList<>();
        for (byte c : in) {
            if (c != elem && c != elem + 32) out.add(c);
        }
        return out;
    }

    public static void main(String[] args) {
        long answer = 0;

        long start = System.nanoTime();
        final ArrayList<Byte> polymer = readPolymer("input.txt");
        final ArrayList<Character> elements = new ArrayList<>(Arrays.asList('A', 'B', 'C', 'D', 'E',
             'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'));
        ArrayList<Long> lens = new ArrayList<>();

        for (char elem : elements) {
            lens.add(reaction(filter(polymer, (byte) elem)));
        }
        answer = Collections.min(lens);
        long end = System.nanoTime() - start;

        System.out.println("Answer:   " + Long.toString(answer));
        System.out.println("time:   " + end / 1000000 + " ms");
    }
}