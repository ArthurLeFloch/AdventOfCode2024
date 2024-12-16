// Day 16: Reindeer Maze

const std = @import("std");

const WALL = 0;
const EMPTY = 1;
const END = 2;

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

const MoveFrom = struct {
    dir: Direction,
    pos: Position,
    priority: usize,
    from: Move,

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

    // const result2 = try second_part(problem, allocator);
    // std.debug.print("Second part: {d}\n", .{result2});

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

const Checked = struct {
    north: bool,
    south: bool,
    east: bool,
    west: bool,
};

fn is_checked(p: Problem, visited: []Checked, move: Move) bool {
    if (move.dir == Direction.NORTH) {
        return visited[move.pos.row * p.size + move.pos.col].north;
    } else if (move.dir == Direction.SOUTH) {
        return visited[move.pos.row * p.size + move.pos.col].south;
    } else if (move.dir == Direction.EAST) {
        return visited[move.pos.row * p.size + move.pos.col].east;
    } else if (move.dir == Direction.WEST) {
        return visited[move.pos.row * p.size + move.pos.col].west;
    }
    return false;
}

fn set_checked(p: Problem, visited: []Checked, move: Move) void {
    if (move.dir == Direction.NORTH) {
        visited[move.pos.row * p.size + move.pos.col].north = true;
    } else if (move.dir == Direction.SOUTH) {
        visited[move.pos.row * p.size + move.pos.col].south = true;
    } else if (move.dir == Direction.EAST) {
        visited[move.pos.row * p.size + move.pos.col].east = true;
    } else if (move.dir == Direction.WEST) {
        visited[move.pos.row * p.size + move.pos.col].west = true;
    }
}

const TileDistance = struct {
    north: u64,
    south: u64,
    east: u64,
    west: u64,
};

fn get_tile_distance(p: Problem, distances: []TileDistance, pos: Position, dir: Direction) u64 {
    if (dir == Direction.NORTH) {
        return distances[pos.row * p.size + pos.col].north;
    } else if (dir == Direction.SOUTH) {
        return distances[pos.row * p.size + pos.col].south;
    } else if (dir == Direction.EAST) {
        return distances[pos.row * p.size + pos.col].east;
    } else if (dir == Direction.WEST) {
        return distances[pos.row * p.size + pos.col].west;
    }
    return 0;
}

fn set_tile_distance(p: Problem, distances: []TileDistance, pos: Position, dir: Direction, value: u64) void {
    if (dir == Direction.NORTH) {
        distances[pos.row * p.size + pos.col].north = value;
    } else if (dir == Direction.SOUTH) {
        distances[pos.row * p.size + pos.col].south = value;
    } else if (dir == Direction.EAST) {
        distances[pos.row * p.size + pos.col].east = value;
    } else if (dir == Direction.WEST) {
        distances[pos.row * p.size + pos.col].west = value;
    }
}

pub fn first_part(p: Problem, allocator: std.mem.Allocator) !u64 {
    const PriorityQueue = std.PriorityQueue(Move, void, compareFn);
    var pq = PriorityQueue.init(allocator, {});
    defer pq.deinit();

    var distances = try allocator.alloc(TileDistance, p.size * p.size);
    defer allocator.free(distances);
    const maxi = 1e9;
    for (distances) |*d| {
        d.* = TileDistance{ .north = maxi, .south = maxi, .east = maxi, .west = maxi };
    }

    distances[p.start.row * p.size + p.start.col] = TileDistance{ .north = maxi, .south = maxi, .east = maxi, .west = maxi };
    const start_move = Move{ .dir = Direction.EAST, .pos = p.start, .priority = 0 };
    try pq.add(start_move);

    while (pq.count() > 0) {
        const current: Move = pq.remove();
        const current_dist = current.priority;

        const distance = get_tile_distance(p, distances, current.pos, current.dir);
        if (current_dist >= distance) {
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
