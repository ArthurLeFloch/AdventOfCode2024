# Day 18: RAM Run

struct Point
    x::Int
    y::Int
end

function parse_input(file_path)
    f = open(file_path, "r")
    points = Vector{Point}()
    while !eof(f)
        s = readline(f)
        values = split(s, ",")
        x = parse(Int, values[1]) # Julia's vectors are 1-indexed
        y = parse(Int, values[2])
        push!(points, Point(x, y))
    end
    close(f)
    return points
end

function debug_map(map, map_size)
    for i in 1:map_size
        for j in 1:map_size
            print(map[i, j] ? "#" : ".")
        end
        println()
    end
end

function is_valid(point, map_size)
    return point.x >= 0 && point.x < map_size && point.y >= 0 && point.y < map_size
end

function dijkstra(map, map_size)
    from = Point(0, 0)
    dest = Point(map_size - 1, map_size - 1)

    # Dijkstra's algorithm
    visited = falses(map_size, map_size)
    distances = ones(map_size, map_size) * Inf
    distances[from.y+1, from.x+1] = 0

    prev = Dict{Point,Point}()

    stack = [from]

    while !isempty(stack)
        pos = popfirst!(stack)
        visited[pos.y+1, pos.x+1] = true

        if pos == dest
            break
        end

        neighbors = [Point(pos.x + 1, pos.y), Point(pos.x - 1, pos.y),
            Point(pos.x, pos.y + 1), Point(pos.x, pos.y - 1)]
        next_dist = distances[pos.y+1, pos.x+1]
        for nb in neighbors
            if !is_valid(nb, map_size) || visited[nb.y+1, nb.x+1] || map[nb.y+1, nb.x+1]
                continue
            end

            if next_dist >= distances[nb.y+1, nb.x+1]
                continue
            end

            distances[nb.y+1, nb.x+1] = next_dist
            prev[nb] = pos
            push!(stack, nb)
        end
    end

    if haskey(prev, dest)
        path = []
        current = dest
        while current != from
            push!(path, current)
            current = prev[current]
        end
        return reverse(path)
    end
    return []
end

function first_part(points, map_size, maxi)
    map = falses(map_size, map_size)
    for i in 1:min(size(points, 1), maxi)
        map[points[i].y+1, points[i].x+1] = true
    end
    

	path = dijkstra(map, map_size)
    return size(path, 1)
end

function second_part(points, map_size)
	map = falses(map_size, map_size)
	
	for i in eachindex(points)
		map[points[i].y+1, points[i].x+1] = true
		path = dijkstra(map, map_size)

		if path == []
			return points[i]
		end
	end
end


file_path = "input.txt"
map_size = 71
maxi = 1024

points = parse_input(file_path)

println("First part: ", first_part(points, map_size, maxi))
println("Second part: ", second_part(points, map_size))
