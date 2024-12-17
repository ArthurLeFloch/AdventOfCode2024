// Day 10: Hoof It

package com.alfloch.aoc2024;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

class Position {
    int x;
    int y;

    Position(int x, int y) {
        this.x = x;
        this.y = y;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) return true;
        if (!(obj instanceof Position p)) return false;
        return p.x == x && p.y == y;
    }

    @Override
    public int hashCode() {
        return x * 257 + y * 65537;
    }
}

public class Main {

    private Set<Position> recurseHikingTrails(int[][] arr, Position p, int current) {
        if (current == 9) {
            Set<Position> result = new HashSet<>();
            result.add(p);
            return result;
        }

        Set<Position> result = new HashSet<>();

        Position newPosition = new Position(p.x + 1, p.y);
        if (newPosition.x < arr.length && arr[newPosition.x][newPosition.y] == current + 1) {
            result.addAll(recurseHikingTrails(arr, newPosition, current + 1));
        }
        newPosition = new Position(p.x - 1, p.y);
        if (newPosition.x >= 0 && arr[newPosition.x][newPosition.y] == current + 1) {
            result.addAll(recurseHikingTrails(arr, newPosition, current + 1));
        }
        newPosition = new Position(p.x, p.y + 1);
        if (newPosition.y < arr.length && arr[newPosition.x][newPosition.y] == current + 1) {
            result.addAll(recurseHikingTrails(arr, newPosition, current + 1));
        }
        newPosition = new Position(p.x, p.y - 1);
        if (newPosition.y >= 0 && arr[newPosition.x][newPosition.y] == current + 1) {
            result.addAll(recurseHikingTrails(arr, newPosition, current + 1));
        }
        return result;
    }

    private List<Position> findZeros(int[][] arr) {
        List<Position> zeros = new ArrayList<>();
        for (int i = 0; i < arr.length; i++) {
            for (int j = 0; j < arr.length; j++) {
                if (arr[i][j] == 0) {
                    zeros.add(new Position(i, j));
                }
            }
        }
        return zeros;
    }

    private long firstPart(Problem p) {
        int[][] map = p.getMap();

        long sum = 0;
        for (Position pos : findZeros(map)) {
            Set<Position> endOfTrails = recurseHikingTrails(map, pos, 0);
            sum += endOfTrails.size();
        }
        return sum;
    }

    private long secondRecurseHikingTrails(int[][] arr, Position p, int current) {
        if (current == 9) {
            return 1;
        }

        long result = 0;

        Position newPosition = new Position(p.x + 1, p.y);
        if (newPosition.x < arr.length && arr[newPosition.x][newPosition.y] == current + 1) {
            result += secondRecurseHikingTrails(arr, newPosition, current + 1);
        }
        newPosition = new Position(p.x - 1, p.y);
        if (newPosition.x >= 0 && arr[newPosition.x][newPosition.y] == current + 1) {
            result += secondRecurseHikingTrails(arr, newPosition, current + 1);
        }
        newPosition = new Position(p.x, p.y + 1);
        if (newPosition.y < arr.length && arr[newPosition.x][newPosition.y] == current + 1) {
            result += secondRecurseHikingTrails(arr, newPosition, current + 1);
        }
        newPosition = new Position(p.x, p.y - 1);
        if (newPosition.y >= 0 && arr[newPosition.x][newPosition.y] == current + 1) {
            result += secondRecurseHikingTrails(arr, newPosition, current + 1);
        }
        return result;
    }

    private long secondPart(Problem p) {
        int[][] map = p.getMap();

        long sum = 0;
        for (Position pos : findZeros(map)) {
            sum += secondRecurseHikingTrails(map, pos, 0);
        }
        return sum;
    }

    public static void main(String[] args) {
        Problem problem = new Problem("src/main/resources/input.txt");

        Main main = new Main();
        System.out.println("First part:" + main.firstPart(problem));
        System.out.println("Second part:" + main.secondPart(problem));
    }
}