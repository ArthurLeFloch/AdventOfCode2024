use std::fs;

// Day 15: Warehouse Woes

#[derive(Clone, Copy, PartialEq)]
enum Cell {
    Wall,
    Empty,
    Box,
    // Additional cells for the second part
    BoxLeft,
    BoxRight,
}

#[derive(Clone)]
struct Vector {
    x: usize,
    y: usize,
}

#[derive(Clone)]
struct Direction {
    x: i8,
    y: i8,
}

// Using & to avoid taking ownership of the vectors
fn add(v: &Vector, d: &Direction) -> Vector {
    return Vector {
        x: ((v.x as i8) + d.x) as usize,
        y: ((v.y as i8) + d.y) as usize,
    };
}

#[derive(Clone)]
struct Problem {
    robot: Vector,
    map: Vec<Vec<Cell>>,
    moves: Vec<Direction>,
}

fn main() {
    let file_path: &str = "input.txt";

    println!("First part: {}", first_part(file_path));
    println!("Second part: {}", second_part(file_path));
}

fn first_part(file_path: &str) -> i64 {
    fn get_size(first_line: &str) -> (usize, usize) {
        let width = first_line.len();
        return (width, width);
    }
    fn read(problem: &mut Problem, c: char, i: usize, j: usize) {
        problem.map[i][j] = match c {
            '.' | '@' => Cell::Empty,
            '#' => Cell::Wall,
            'O' => Cell::Box,
            e => panic!("Invalid character in input file: {}", e),
        };
        if c == '@' {
            problem.robot.x = j;
            problem.robot.y = i;
        }
    }
    let problem = parse_input(file_path, get_size, read);
    return solve(problem, forward_simple);
}

fn second_part(file_path: &str) -> i64 {
    fn get_size_doubled_width(first_line: &str) -> (usize, usize) {
        let height = first_line.len();
        return (height * 2, height);
    }
    fn read_doubled_width(problem: &mut Problem, c: char, i: usize, j: usize) {
        let pos = Vector { x: 2 * j, y: i };

        if c == '@' {
            problem.robot = pos.clone();
        }

        if c == '.' || c == '@' {
            problem.map[pos.y][pos.x] = Cell::Empty;
            problem.map[pos.y][pos.x + 1] = Cell::Empty;
        } else if c == '#' {
            problem.map[pos.y][pos.x] = Cell::Wall;
            problem.map[pos.y][pos.x + 1] = Cell::Wall;
        } else if c == 'O' {
            problem.map[pos.y][pos.x] = Cell::BoxLeft;
            problem.map[pos.y][pos.x + 1] = Cell::BoxRight;
        } else {
            panic!("Invalid character in input file: {}", c);
        }
    }
    let problem = parse_input(file_path, get_size_doubled_width, read_doubled_width);
    return solve(problem, forward_second);
}

fn parse_input(
    file_path: &str,
    get_size: fn(&str) -> (usize, usize),
    read: fn(&mut Problem, char, usize, usize),
) -> Problem {
    let content = fs::read_to_string(file_path).expect("Error reading file");

    let first_line = content.lines().next().unwrap();
    let (width, height) = get_size(first_line);

    let mut problem = Problem {
        robot: Vector { x: 0, y: 0 },
        map: vec![vec![Cell::Empty; width]; height],
        moves: Vec::new(),
    };

    for (i, line) in content.lines().enumerate() {
        let mut count = 0;
        for (j, c) in line.chars().enumerate() {
            count += 1;
            read(&mut problem, c, i, j);
        }
        if count == 0 {
            // Start reading the moves
            break;
        }
    }

    println!("Start at {}, {}", problem.robot.x, problem.robot.y);

    for line in content.lines().skip(height) {
        for c in line.chars() {
            let mut x: i8 = 0;
            let mut y: i8 = 0;
            match c {
                '^' => y = -1,
                '>' => x = 1,
                'v' => y = 1,
                '<' => x = -1,
                e => panic!("Invalid character in input file: {}", e),
            }
            problem.moves.push(Direction { x, y });
        }
    }

    return problem;
}

fn forward_simple(map: &mut Vec<Vec<Cell>>, pos: &Vector, dir: &Direction) -> Vector {
    // Assumes that the cell in front of the robot is a box!
    // Returns the new position of the robot

    let current = pos.clone();
    let front = add(pos, dir);

    let mut cell: Cell = map[front.y][front.x];
    if cell == Cell::Wall {
        return current;
    }
    if cell == Cell::Empty {
        return front;
    }

    let mut res = add(pos, dir);
    cell = map[res.y][res.x];
    while cell != Cell::Wall {
        res = add(&res, dir);
        cell = map[res.y][res.x];
        if cell == Cell::Empty {
            map[front.y][front.x] = Cell::Empty;
            map[res.y][res.x] = Cell::Box;
            return front;
        }
    }
    return current;
}

fn get_cell(map: &Vec<Vec<Cell>>, pos: &Vector) -> Cell {
    return map[pos.y][pos.x];
}

// Should be called with the position of the box
fn can_move_rec(map: &Vec<Vec<Cell>>, pos: &Vector, dir: &Direction) -> bool {
    let front = add(pos, dir);

    // Moving horizontally
    if dir.y == 0 {
        let front_cell = get_cell(map, &front);
        return match front_cell {
            Cell::Empty => true,                 // Can move into an empty cell
            Cell::Wall => false,                 // Cannot move into a wall
            _ => can_move_rec(map, &front, dir), // Recurse for other cell types
        };
    }

    // Moving vertically
    let cell = get_cell(map, pos);
    let other = if cell == Cell::BoxLeft {
        Vector {
            x: pos.x + 1,
            y: pos.y,
        }
    } else {
        Vector {
            x: pos.x - 1,
            y: pos.y,
        }
    };

    // Calculate the next positions for both the current and adjacent cells
    let first = add(pos, dir);
    let second = add(&other, dir);

    let first_cell = get_cell(map, &first);
    let second_cell = get_cell(map, &second);

    if first_cell == Cell::Empty && second_cell == Cell::Empty {
        return true;
    }
    if first_cell == Cell::Wall || second_cell == Cell::Wall {
        return false;
    }

    // Recurse for any boxes that need to be moved
    if (first_cell == Cell::BoxLeft || first_cell == Cell::BoxRight)
        && !can_move_rec(map, &first, dir)
    {
        return false;
    }
    if (second_cell == Cell::BoxLeft || second_cell == Cell::BoxRight)
        && !can_move_rec(map, &second, dir)
    {
        return false;
    }

    true
}

fn move_box_left(map: &mut Vec<Vec<Cell>>, from: &Vector) {
    map[from.y][from.x - 1] = Cell::BoxLeft;
    map[from.y][from.x] = Cell::BoxRight;
    map[from.y][from.x + 1] = Cell::Empty;
}
fn move_box_right(map: &mut Vec<Vec<Cell>>, pos: &Vector) {
    map[pos.y][pos.x + 1] = Cell::BoxRight;
    map[pos.y][pos.x] = Cell::BoxLeft;
    map[pos.y][pos.x - 1] = Cell::Empty;
}

fn move_rec(map: &mut Vec<Vec<Cell>>, pos: &Vector, dir: &Direction) {
    let cell = map[pos.y][pos.x];
    let front = add(pos, dir);

    // Horizontal moving
    if dir.y == 0 {
        let front_cell = map[front.y][front.x];

        if front_cell == Cell::Empty {
            return match dir.x {
                -1 => move_box_left(map, pos),
                1 => move_box_right(map, pos),
                _ => (),
            };
        }

        // We need to get to the other side of the box compared to the direction
        if (front_cell == Cell::BoxLeft && dir.x == -1)
            || (front_cell == Cell::BoxRight && dir.x == 1)
        {
            move_rec(map, &front, dir);
            return;
        }

        // If there's a box in front of the box, move it first
        if front_cell == Cell::BoxLeft || front_cell == Cell::BoxRight {
            move_rec(map, &front, dir);
            return match dir.x {
                -1 => move_box_left(map, pos),
                1 => move_box_right(map, pos),
                _ => (),
            };
        }
        return;
    } else {
        let other = if cell == Cell::BoxLeft {
            Vector {
                x: pos.x + 1,
                y: pos.y,
            }
        } else {
            Vector {
                x: pos.x - 1,
                y: pos.y,
            }
        };
        let other_cell = map[other.y][other.x];

        let first = add(pos, dir);
        let second = add(&other, dir);

        let first_cell = map[first.y][first.x];
        let second_cell = map[second.y][second.x];

        if first_cell == Cell::Empty && second_cell == Cell::Empty {
            // Do nothing
        } else if cell == second_cell && other_cell == first_cell {
            // If there is two boxes to push, move_rec twice
            move_rec(map, &first, dir);
            move_rec(map, &second, dir);
        } else if cell == second_cell {
            // If there is only one box to push, move_rec only once
            move_rec(map, &second, dir);
        } else {
            // Either there's a box aligned, or slightly off
            move_rec(map, &first, dir);
        }

        map[first.y][first.x] = cell;
        map[second.y][second.x] = other_cell;
        map[pos.y][pos.x] = Cell::Empty;
        map[other.y][other.x] = Cell::Empty;
    }
}

fn forward_second(map: &mut Vec<Vec<Cell>>, pos: &Vector, dir: &Direction) -> Vector {
    // Assumes that the cell in front of the robot is a box!
    // Returns the new position of the robot

    let current = pos.clone();
    let front = add(pos, dir);

    let cell: Cell = map[front.y][front.x];
    if cell == Cell::Wall {
        return current;
    }
    if cell == Cell::Empty {
        return front;
    }

    if !can_move_rec(map, &front, dir) {
        return current;
    }

    move_rec(map, &front, dir);

    return front;
}

fn solve(
    mut problem: Problem,
    forward: fn(map: &mut Vec<Vec<Cell>>, pos: &Vector, dir: &Direction) -> Vector,
) -> i64 {
    let mut pos = problem.robot.clone();

    for vector in problem.moves.iter() {
        pos = forward(&mut problem.map, &pos, vector);
    }

    let mut sum: i64 = 0;
    for (i, line) in problem.map.iter().enumerate() {
        for (j, cell) in line.iter().enumerate() {
            if *cell == Cell::Box || *cell == Cell::BoxLeft {
                sum += 100 * (i as i64) + (j as i64);
            }
        }
    }

    return sum;
}
