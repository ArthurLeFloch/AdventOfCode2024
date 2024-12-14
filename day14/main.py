# Day 14: Restroom Redoubt

import re


def parse_input(input_file):
    with open(input_file, 'r') as f:
        lines = f.read().splitlines()
        robots = []
        for line in lines:
            matcher = re.match(r'p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)', line)
            pos = [int(matcher.group(1)), int(matcher.group(2))]
            vel = [int(matcher.group(3)), int(matcher.group(4))]
            robots.append((pos, vel))
        return robots


width = 101
height = 103


def next_pos(pos, vel, times=1):
    return [(pos[0] + times * vel[0]) % width, (pos[1] + times * vel[1]) % height]


def first_part(robots, width, height):
    top_left = 0
    top_right = 0
    bottom_left = 0
    bottom_right = 0
    for robot in robots:
        robot = (next_pos(robot[0], robot[1], 100), robot[1])
        x = robot[0][0]
        y = robot[0][1]
        center_x = int((width - 1) / 2)
        center_y = int((height - 1) / 2)
        if x < center_x and y < center_y:
            top_left += 1
        elif x > center_x and y < center_y:
            top_right += 1
        elif x < center_x and y > center_y:
            bottom_left += 1
        elif x > center_x and y > center_y:
            bottom_right += 1
    return top_left * top_right * bottom_left * bottom_right


def is_tree(grid, robots, expected):
    # If vertical line of length > 10, return
    for robot in robots:
        pos = robot[0]
        total = 0
        x = pos[0]
        y = pos[1] + 1
        while y < height and grid[y][x] == expected:
            assert grid[y][x] == grid[pos[1]][pos[0]]
            total += 1
            y += 1
        y = pos[1] - 1
        while y >= 0 and grid[y][x] == expected:
            assert grid[y][x] == grid[pos[1]][pos[0]]
            total += 1
            y -= 1
        if total >= 10:
            print("Vertical line of length > 10 from robot", total)
            return True
    return False


def second_part(max_iter):
    grid = [[-1 for _ in range(width)] for _ in range(height)]
    for count in range(max_iter):
        for i in range(len(robots)):
            pos, vel = robots[i]
            pos = next_pos(pos, vel)
            grid[pos[1]][pos[0]] = count
            robots[i] = (pos, vel)
        if not is_tree(grid, robots, count):
            continue
        map = [['.' for _ in range(width)] for _ in range(height)]
        for robot in robots:
            map[robot[0][1]][robot[0][0]] = '#'
        return map, count


robots = parse_input('input.txt')

first = first_part(robots, width, height)
map, second = second_part(10_000)

for i in range(height):
    print(''.join(map[i]))

print(f"First part: {first}")
print(f"Second part: {second}")
