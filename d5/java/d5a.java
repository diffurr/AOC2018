import java.io.IOException;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;

public class d5a {
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

    public static void main(String[] args) {
        long answer = 0;

        final ArrayList<Byte> polymer = readPolymer("input.txt");
        long start = System.nanoTime();
        answer = reaction(polymer);
        long end = System.nanoTime() - start;

        System.out.println("Answer:   " + Long.toString(answer));
        System.out.println("time:   " + end / 1000000 + " ms");
    }
}