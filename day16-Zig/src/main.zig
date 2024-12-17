// Day 16: Reindeer Maze

const std = @import("std");

const Tile = enum {
    WALL,
    EMPTY,
    END,
};

const Position = struct { row: usize, col: usize };

const Direction = enum {
    NORTH,
    SOUTH,
    EAST,
    WEST,
};

const Move = struct {
    dir: Direction,
    pos: Position,
    priority: usize,

    fn debug(move: Move) void {
        if (move.dir == Direction.NORTH) {
            std.debug.print("North ({d} {d}) {d}\n", .{ move.pos.row, move.pos.col, move.priority });
        } else if (move.dir == Direction.SOUTH) {
            std.debug.print("South ({d} {d}) {d}\n", .{ move.pos.row, move.pos.col, move.priority });
        } else if (move.dir == Direction.EAST) {
            std.debug.print("East ({d} {d}) {d}\n", .{ move.pos.row, move.pos.col, move.priority });
        } else if (move.dir == Direction.WEST) {
            std.debug.print("West ({d} {d}) {d}\n", .{ move.pos.row, move.pos.col, move.priority });
        }
    }
};

const Problem = struct {
    array: []Tile,
    size: usize,
    start: Position,
    end: Position,

    fn get(p: Problem, pos: Position) Tile {
        return p.array[pos.row * p.size + pos.col];
    }

    fn set(p: Problem, pos: Position, value: Tile) void {
        p.array[pos.row * p.size + pos.col] = value;
    }

    fn debug(p: Problem) void {
        var i: usize = 0;
        while (i < p.size) : (i += 1) {
            var j: usize = 0;
            while (j < p.size) : (j += 1) {
                const value = p.get(Position{ .row = i, .col = j });
                if (value == Tile.WALL) {
                    std.debug.print("#", .{});
                } else if (value == Tile.EMPTY) {
                    std.debug.print(".", .{});
                } else if (value == Tile.END) {
                    std.debug.print("E", .{});
                } else {
                    std.debug.print("?", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn parse_input(allocator: std.mem.Allocator) !Problem {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // Find size by finding the first newline
    var size: usize = 0;
    var i: usize = 0;
    while (i != buffer.len) {
        if (buffer[i] == '\n') {
            break;
        }
        size += 1;
        i += 1;
    }

    const array = try allocator.alloc(Tile, size * size);

    const nullPos = Position{ .row = 0, .col = 0 };
    var p = Problem{ .array = array, .size = size, .start = nullPos, .end = nullPos };

    i = 0;
    var j: usize = 0;

    var k: usize = 0;
    while (k != buffer.len) {
        const c = buffer[k];
        if (c == '\n') {
            j = 0;
            i += 1;
        } else {
            if (c == '#') {
                p.set(Position{ .row = i, .col = j }, Tile.WALL);
            } else if (c == '.') {
                p.set(Position{ .row = i, .col = j }, Tile.EMPTY);
            } else if (c == 'E') {
                p.set(Position{ .row = i, .col = j }, Tile.END);
                p.end = Position{ .row = i, .col = j };
            } else if (c == 'S') {
                p.set(Position{ .row = i, .col = j }, Tile.EMPTY);
                p.start = Position{ .row = i, .col = j };
            }
            j += 1;
        }
        k += 1;
    }

    std.debug.print("Size: {d}\n", .{size});

    return p;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const problem = try parse_input(allocator);

    problem.debug();

    const result = try first_part(problem, allocator);

    std.debug.print("First part: {d}\n", .{result});

    const result2 = try second_part(problem, allocator, result);
    std.debug.print("Second part: {d}\n", .{result2});

    allocator.free(problem.array);
}

fn compareFn(context: void, a: Move, b: Move) std.math.Order {
    _ = context;
    // Flip for min heap
    return std.math.order(a.priority, b.priority);
}

fn next_position(pos: Position, dir: Direction) Position {
    if (dir == Direction.NORTH) {
        return Position{ .row = pos.row - 1, .col = pos.col };
    } else if (dir == Direction.SOUTH) {
        return Position{ .row = pos.row + 1, .col = pos.col };
    } else if (dir == Direction.EAST) {
        return Position{ .row = pos.row, .col = pos.col + 1 };
    } else if (dir == Direction.WEST) {
        return Position{ .row = pos.row, .col = pos.col - 1 };
    }
    return Position{ .row = 0, .col = 0 };
}

const TileDistance = struct {
    vertical: u64,
    horizontal: u64,
};

fn get_tile_distance(p: Problem, distances: []TileDistance, pos: Position, dir: Direction) u64 {
    if ((dir == Direction.NORTH) or (dir == Direction.SOUTH)) {
        return distances[pos.row * p.size + pos.col].vertical;
    } else {
        return distances[pos.row * p.size + pos.col].horizontal;
    }
}

fn set_tile_distance(p: Problem, distances: []TileDistance, pos: Position, dir: Direction, value: u64) void {
    if ((dir == Direction.NORTH) or (dir == Direction.SOUTH)) {
        distances[pos.row * p.size + pos.col].vertical = value;
    } else {
        distances[pos.row * p.size + pos.col].horizontal = value;
    }
}

pub fn first_part(p: Problem, allocator: std.mem.Allocator) !u64 {
    const PriorityQueue = std.PriorityQueue(Move, void, compareFn);
    var pq = PriorityQueue.init(allocator, {});
    defer pq.deinit();

    const maxi = 1e9;
    const distances = try allocator.alloc(TileDistance, p.size * p.size);
    defer allocator.free(distances);
    for (distances) |*d| {
        d.* = TileDistance{ .vertical = maxi, .horizontal = maxi };
    }

    const start_move = Move{ .dir = Direction.EAST, .pos = p.start, .priority = 0 };
    try pq.add(start_move);

    while (pq.count() > 0) {
        const current: Move = pq.remove();
        const current_dist = current.priority;

        const distance = get_tile_distance(p, distances, current.pos, current.dir);
        if (current_dist > distance) {
            continue;
        }
        set_tile_distance(p, distances, current.pos, current.dir, current_dist);

        if (p.get(current.pos) == Tile.END) {
            return current_dist;
        }

        // Add the potential next moves
        const next = next_position(current.pos, current.dir);
        if (p.get(next) != Tile.WALL) { // Small penalty for moving forward
            try pq.add(Move{ .dir = current.dir, .pos = next, .priority = current_dist + 1 });
        }

        const next_dist = current_dist + 1000; // Heavier penalty for turning
        if ((current.dir == Direction.NORTH) or (current.dir == Direction.SOUTH)) {
            try pq.add(Move{ .dir = Direction.WEST, .pos = current.pos, .priority = next_dist });
            try pq.add(Move{ .dir = Direction.EAST, .pos = current.pos, .priority = next_dist });
        } else if ((current.dir == Direction.EAST) or (current.dir == Direction.WEST)) {
            try pq.add(Move{ .dir = Direction.NORTH, .pos = current.pos, .priority = next_dist });
            try pq.add(Move{ .dir = Direction.SOUTH, .pos = current.pos, .priority = next_dist });
        }
    }
    std.debug.print("No path found\n", .{});
    return 0;
}

const MoveFrom = struct {
    dir: Direction,
    pos: Position,
    priority: u64,
    path: std.ArrayList(Position),
};

fn compareFnFrom(context: void, a: MoveFrom, b: MoveFrom) std.math.Order {
    _ = context;
    // Flip for min heap
    return std.math.order(a.priority, b.priority);
}

pub fn second_part(p: Problem, allocator: std.mem.Allocator, optimal: u64) !u64 {
    const PriorityQueue = std.PriorityQueue(MoveFrom, void, compareFnFrom);
    var pq = PriorityQueue.init(allocator, {});
    defer pq.deinit();

    const distances = try allocator.alloc(TileDistance, p.size * p.size);
    defer allocator.free(distances);

    const maxi = 1e9;
    for (distances) |*d| {
        d.* = TileDistance{ .vertical = maxi, .horizontal = maxi };
    }

    var uniques = std.AutoHashMap(Position, void).init(allocator);

    var current = MoveFrom{ .dir = Direction.EAST, .pos = p.start, .priority = 0, .path = std.ArrayList(Position).init(allocator) };
    try pq.add(current);

    while (pq.count() > 0) {
        current = pq.remove();
        const dist = current.priority;
        try current.path.append(current.pos);

        if (dist > get_tile_distance(p, distances, current.pos, current.dir)) {
            current.path.deinit();
            continue;
        }
        if (dist > optimal) {
            current.path.deinit();
            continue;
        }

        if (p.get(current.pos) == Tile.END) {
            const ancestors = current.path;
            for (ancestors.items) |ancestor| {
                try uniques.put(ancestor, void{});
            }
            current.path.deinit();
            continue;
        }

        const directions = [4]Direction{ Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST };

        // Scan all directions. If it's the same, move forward, otherwise turn
        for (directions) |dir| {
            var next = current.pos;

            var new_dist = current.priority + 1000;
            if (current.dir == dir) {
                next = next_position(current.pos, dir);
                new_dist = current.priority + 1;
            }

            if ((p.get(next) == Tile.WALL) or (new_dist > get_tile_distance(p, distances, next, dir))) {
                continue;
            }
            set_tile_distance(p, distances, next, dir, new_dist);

            // Deep copy, otherwise the path will be shared between all moves
            var path_copy = std.ArrayList(Position).init(allocator);
            for (current.path.items) |pos| {
                try path_copy.append(pos);
            }
            try current.path.append(next);

            const next_move = MoveFrom{ .dir = dir, .pos = next, .priority = new_dist, .path = path_copy };
            try pq.add(next_move);
        }
    }

    return uniques.count();
}
