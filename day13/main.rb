# Day 13: Claw Contraption

class Equation
	attr_accessor :a_dx, :a_dy, :b_dx, :b_dy, :p_x, :p_y
	def initialize(a_dx, a_dy, b_dx, b_dy, p_x, p_y)
		@a_dx = a_dx
		@a_dy = a_dy
		@b_dx = b_dx
		@b_dy = b_dy
		@p_x = p_x
		@p_y = p_y
	end
	def solve()
		det = @a_dx * @b_dy - @a_dy * @b_dx
		if det == 0
			return nil
		end
		x = (@b_dy * @p_x - @b_dx * @p_y) / det.to_f
		y = (-@a_dy * @p_x + @a_dx * @p_y) / det.to_f
		
		if (x % 1 != 0 || y % 1 != 0)
			return nil
		end
		
		return [x.to_i, y.to_i]
	end
end

class Problem
	attr_accessor :equations
	def initialize(file_path, offset = 0)
		lines = File.read(file_path).split("\n")

		@equations = []

		button_matcher = /Button (A|B): X\+(\d+), Y\+(\d+)/
		prize_matcher = /Prize: X=(\d+), Y=(\d+)/

		last_a = nil
		last_b = nil

		lines.each do |line|
			match_button = line.match(button_matcher)
			match_prize = line.match(prize_matcher)
			
			if match_button
				x = match_button[2].to_i
				y = match_button[3].to_i
				if match_button[1] == "A"
					last_a = [x, y]
				else
					last_b = [x, y]
				end
			elsif match_prize
				x = match_prize[1].to_i + offset
				y = match_prize[2].to_i + offset
				@equations.push(Equation.new(last_a[0], last_a[1], last_b[0], last_b[1], x, y))
			else
				last_a = nil
				last_b = nil
			end
		end
	end
end

def first_part(problem)
	sum = 0
	problem.equations.each do |equation|
		solution = equation.solve()
		if solution != nil
			sum += 3 * solution[0] + solution[1]
		end
	end
	return sum
end

problem = Problem.new("input.txt")
puts "First part: #{first_part(problem)}"

second_problem = Problem.new("input.txt", 10000000000000)
puts "Second part: #{first_part(second_problem)}"

# 875318608908 too low
# 875318608908