package com.alfloch.aoc2024;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class Problem {

    int[][] map;
    int size;

    Problem(String filePath) {
        File file = new File(filePath);
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line = reader.readLine();
            size = line.length();
            map = new int[size][size];
            int i = 0;
            while (line != null) {
                for (int j = 0; j < size; j++) {
                    map[i][j] = Integer.parseInt(String.valueOf(line.charAt(j)));
                }
                i++;
                line = reader.readLine();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    int getSize() {
        return size;
    }

    int[][] getMap() {
        return map;
    }
}
