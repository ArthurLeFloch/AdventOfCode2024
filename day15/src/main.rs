use std::fs;

// TODO: Function as parameter to factorize code ?

#[derive(Clone)] // TODO: Find out how it works
#[derive(Copy)] // TODO: Find out how it works
#[derive(PartialEq)] // TODO: Find out how it works
#[derive(Debug)] // TODO: Find out how it works
enum Cell {
    Wall,
    Empty,
    Box,
    Robot,

    // Additional cells for the second part
    BoxLeft,
    BoxRight,
}

#[derive(Clone)]
struct Vector {
    x: i64,
    y: i64,
}

fn add(v1: &Vector, v2: &Vector) -> Vector {
    // Avoid add taking ownership of the vectors
    return Vector {
        x: v1.x + v2.x,
        y: v1.y + v2.y,
    };
}

#[derive(Clone)]
struct Problem {
    robot: Vector,
    map: Vec<Vec<Cell>>,
    moves: Vec<Vector>,
}

fn main() {
    let file_path: &str = "input.txt";

    let p = parse_input(file_path);
    println!("Start: {}, {}", p.robot.x, p.robot.y);
    println!("First part: {}", first_part(p.clone()));

    let p = parse_second_input(file_path);
    println!("Start: {}, {}", p.robot.x, p.robot.y);
    println!("Second part: {}", second_part(p.clone()));
}

fn parse_input(file_path: &str) -> Problem {
    let content = fs::read_to_string(file_path).expect("Error reading file");

    let first_line = content.lines().next().unwrap();
    let width = first_line.len();
    let height = width;

    let mut array: Vec<Vec<Cell>> = vec![vec![Cell::Empty; width]; height];

    let mut start = Vector { x: 0, y: 0 };

    for (i, line) in content.lines().enumerate() {
        let mut count = 0;
        for (j, c) in line.chars().enumerate() {
            count += 1;
            array[i][j] = match c {
                '.' => Cell::Empty,
                '#' => Cell::Wall,
                'O' => Cell::Box,
                '@' => Cell::Robot,
                e => panic!("Invalid character in input file: {}", e),
            };
            if c == '@' {
                start.x = j as i64;
                start.y = i as i64;
            }
        }
        if count == 0 {
            // Start reading the moves
            break;
        }
    }

    let mut moves: Vec<Vector> = Vec::new();
    for line in content.lines().skip(height) {
        for c in line.chars() {
            let mut x = 0;
            let mut y = 0;
            match c {
                '^' => y = -1,
                '>' => x = 1,
                'v' => y = 1,
                '<' => x = -1,
                e => panic!("Invalid character in input file: {}", e),
            }
            moves.push(Vector { x, y });
        }
    }

    return Problem {
        robot: start,
        map: array,
        moves,
    };
}

fn forward(map: &mut Vec<Vec<Cell>>, pos: &Vector, vector: &Vector) -> Vector {
    // Assumes that the cell in front of the robot is a box!
    // Returns the new position of the robot

    let current = pos.clone();
    let front = add(pos, vector);

    let mut cell: Cell = map[front.y as usize][front.x as usize];
    if cell == Cell::Wall {
        return current;
    }
    if cell == Cell::Empty {
        return front;
    }

    let mut res = add(pos, vector);
    cell = map[res.y as usize][res.x as usize];
    while cell != Cell::Wall {
        res = add(&res, vector);
        cell = map[res.y as usize][res.x as usize];
        if cell == Cell::Empty {
            map[front.y as usize][front.x as usize] = Cell::Empty;
            map[res.y as usize][res.x as usize] = Cell::Box;
            return front;
        }
    }
    return current;
}

fn first_part(mut problem: Problem) -> i64 {
    // First part takes ownership of the problem given
    let mut pos = problem.robot.clone();

    // We do not care about the @ in the map
    problem.map[pos.y as usize][pos.x as usize] = Cell::Empty;

    for vector in problem.moves.iter() {
        pos = forward(&mut problem.map, &pos, vector);
    }

    let mut sum: i64 = 0;
    for (i, line) in problem.map.iter().enumerate() {
        for (j, cell) in line.iter().enumerate() {
            if *cell == Cell::Box {
                sum += 100 * (i as i64) + (j as i64);
            }
        }
    }

    return sum;
}

fn parse_second_input(file_path: &str) -> Problem {
    let content = fs::read_to_string(file_path).expect("Error reading file");

    let first_line = content.lines().next().unwrap();
    let height = first_line.len();
    let width = height * 2;

    let mut array: Vec<Vec<Cell>> = vec![vec![Cell::Empty; width]; height];

    let mut start = Vector { x: 0, y: 0 };

    for (i, line) in content.lines().enumerate() {
        let mut count = 0;
        for (j, c) in line.chars().enumerate() {
            count += 1;

            let pos = Vector {
                x: 2 * j as i64,
                y: i as i64,
            };
            if c == '@' {
                start = pos.clone();
                array[pos.y as usize][pos.x as usize] = Cell::Robot;
                array[pos.y as usize][pos.x as usize + 1] = Cell::Empty;
                continue;
            } else if c == '#' {
                array[pos.y as usize][pos.x as usize] = Cell::Wall;
                array[pos.y as usize][pos.x as usize + 1] = Cell::Wall;
                continue;
            } else if c == '.' {
                array[pos.y as usize][pos.x as usize] = Cell::Empty;
                array[pos.y as usize][pos.x as usize + 1] = Cell::Empty;
                continue;
            } else if c == 'O' {
                array[pos.y as usize][pos.x as usize] = Cell::BoxLeft;
                array[pos.y as usize][pos.x as usize + 1] = Cell::BoxRight;
                continue;
            } else {
                panic!("Invalid character in input file: {}", c);
            }
        }
        if count == 0 {
            // Start reading the moves
            break;
        }
    }

    let mut moves: Vec<Vector> = Vec::new();
    for line in content.lines().skip(height) {
        for c in line.chars() {
            let mut x = 0;
            let mut y = 0;
            match c {
                '^' => y = -1,
                '>' => x = 1,
                'v' => y = 1,
                '<' => x = -1,
                e => panic!("Invalid character in input file: {}", e),
            }
            moves.push(Vector { x, y });
        }
    }

    return Problem {
        robot: start,
        map: array,
        moves,
    };
}

fn get_cell(map: &Vec<Vec<Cell>>, pos: &Vector) -> Cell {
    return map[pos.y as usize][pos.x as usize];
}

// Should be called with the position of the box
fn can_move_rec(map: &Vec<Vec<Cell>>, pos: &Vector, vector: &Vector) -> bool {
    let front = add(pos, vector);

    // Moving horizontally
    if vector.y == 0 {
        let front_cell = get_cell(map, &front);
        return match front_cell {
            Cell::Empty => true,                    // Can move into an empty cell
            Cell::Wall => false,                    // Cannot move into a wall
            _ => can_move_rec(map, &front, vector), // Recurse for other cell types
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
    let first = add(pos, vector);
    let second = add(&other, vector);

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
        && !can_move_rec(map, &first, vector)
    {
        return false;
    }
    if (second_cell == Cell::BoxLeft || second_cell == Cell::BoxRight)
        && !can_move_rec(map, &second, vector)
    {
        return false;
    }

    true
}

fn move_rec(map: &mut Vec<Vec<Cell>>, pos: &Vector, vector: &Vector) {
    let cell = map[pos.y as usize][pos.x as usize];
    let front = add(pos, vector);

    // Horizontal moving
    if vector.y == 0 {
        let front_cell = map[front.y as usize][front.x as usize];

        if front_cell == Cell::Empty {
            if vector.x == -1 {
                // In this case the current pos should be BoxLeft
                map[front.y as usize][front.x as usize] = Cell::BoxLeft;
                map[pos.y as usize][pos.x as usize] = Cell::BoxRight;
                map[pos.y as usize][(pos.x + 1) as usize] = Cell::Empty; // Leave place for the other boxes to move
                return;
            } else {
                map[front.y as usize][front.x as usize] = Cell::BoxRight;
                map[pos.y as usize][pos.x as usize] = Cell::BoxLeft;
                map[pos.y as usize][(pos.x - 1) as usize] = Cell::Empty;
                return;
            }
        }

        if front_cell == Cell::BoxLeft && vector.x == -1 {
            move_rec(map, &front, vector);
            return;
        } else if front_cell == Cell::BoxRight && vector.x == 1 {
            move_rec(map, &front, vector);
            return;
        }

        if front_cell == Cell::BoxLeft || front_cell == Cell::BoxRight {
            move_rec(map, &front, vector);
            if vector.x == -1 {
                map[front.y as usize][front.x as usize] = Cell::BoxLeft;
                map[pos.y as usize][pos.x as usize] = Cell::BoxRight;
                map[pos.y as usize][(pos.x + 1) as usize] = Cell::Empty;
                return;
            } else {
                map[front.y as usize][front.x as usize] = Cell::BoxRight;
                map[pos.y as usize][pos.x as usize] = Cell::BoxLeft;
                map[pos.y as usize][(pos.x - 1) as usize] = Cell::Empty;
                return;
            }
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
        let other_cell = map[other.y as usize][other.x as usize];

        let first = add(pos, vector);
        let second = add(&other, vector);

        let first_cell = map[first.y as usize][first.x as usize];
        let second_cell = map[second.y as usize][second.x as usize];

        if first_cell == Cell::Empty && second_cell == Cell::Empty {
            map[first.y as usize][first.x as usize] = cell;
            map[second.y as usize][second.x as usize] = other_cell;
            map[pos.y as usize][pos.x as usize] = Cell::Empty;
            map[other.y as usize][other.x as usize] = Cell::Empty;
            return;
        }

        // If there is two boxes to push, move_rec twice
        if cell == second_cell && other_cell == first_cell {
            move_rec(map, &first, vector);
            move_rec(map, &second, vector);
            map[first.y as usize][first.x as usize] = cell;
            map[pos.y as usize][pos.x as usize] = Cell::Empty;
            map[second.y as usize][second.x as usize] = other_cell;
            map[other.y as usize][other.x as usize] = Cell::Empty;
            return;
        } else if cell == second_cell { // If there is only one box to push, move_rec only once
            move_rec(map, &second, vector);
        } else {
            // Either there's a box aligned, or slightly off
            move_rec(map, &first, vector);
        }

        map[first.y as usize][first.x as usize] = cell;
        map[second.y as usize][second.x as usize] = other_cell;
        map[pos.y as usize][pos.x as usize] = Cell::Empty;
        map[other.y as usize][other.x as usize] = Cell::Empty;
    }
}

fn forward2(map: &mut Vec<Vec<Cell>>, pos: &Vector, vector: &Vector) -> Vector {
    // Assumes that the cell in front of the robot is a box!
    // Returns the new position of the robot

    let current = pos.clone();
    let front = add(pos, vector);

    let cell: Cell = map[front.y as usize][front.x as usize];
    if cell == Cell::Wall {
        return current;
    }
    if cell == Cell::Empty {
        return front;
    }

    if !can_move_rec(map, &front, vector) {
        return current;
    }

    move_rec(map, &front, vector);

    return front;
}

fn second_part(mut problem: Problem) -> i64 {
    let mut pos = problem.robot.clone();

    // We do not care about the @ in the map
    problem.map[pos.y as usize][pos.x as usize] = Cell::Empty;

    for vector in problem.moves.iter() {
        pos = forward2(&mut problem.map, &pos, vector);
    }

    let mut sum: i64 = 0;
    for (i, line) in problem.map.iter().enumerate() {
        for (j, cell) in line.iter().enumerate() {
            if *cell == Cell::BoxLeft {
                sum += 100 * (i as i64) + (j as i64);
            }
        }
    }

    return sum;
}
