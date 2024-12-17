# Day 13: Claw Contraption

class LineIntersection
  def initialize(line_a, line_b, point)
    @a_dx, @a_dy = line_a
    @b_dx, @b_dy = line_b
    @p_x, @p_y = point
  end

  def solve()
    det = @a_dx * @b_dy - @a_dy * @b_dx
    return nil if det.zero?

    x = (@b_dy * @p_x - @b_dx * @p_y) / det.to_f
    y = (-@a_dy * @p_x + @a_dx * @p_y) / det.to_f
    return nil if x % 1 != 0 || y % 1 != 0

    [x.to_i, y.to_i]
  end
end

class Problem
  BUTTON_PATTERN = /Button (A|B): X\+(\d+), Y\+(\d+)/
  PRIZE_PATTERN = /Prize: X=(\d+), Y=(\d+)/

  attr_accessor :intersections

  def initialize(file_path, prize_offset = 0)
    lines = File.read(file_path).split("\n")

    @intersections = []

    button_a = button_b = nil

    lines.each do |line|
      case line
      when BUTTON_PATTERN
        button = [$2.to_i, $3.to_i]
        $1 == "A" ? button_a = button : button_b = button
      when PRIZE_PATTERN
        prize = [$1.to_i + prize_offset, $2.to_i + prize_offset]
        if button_a && button_b
          intersections << LineIntersection.new(button_a, button_b, prize)
        end
      else
        button_a = button_b = nil
      end
    end
  end
end

def solver(problem)
  sum = 0
  problem.intersections.each do |intersection|
    solution = intersection.solve()
    if solution != nil
      sum += 3 * solution[0] + solution[1]
    end
  end
  return sum
end

part1_input = Problem.new("input.txt")
puts "First part: #{solver(part1_input)}"

part2_input = Problem.new("input.txt", 10_000_000_000_000)
puts "Second part: #{solver(part2_input)}"
