# Day 18: RAM Run

struct Point
    x::Int
    y::Int
end

function parse_input(file_path)
    points = Vector{Point}()
    open(file_path, "r") do f
        for line in eachline(f)
            x, y = parse.(Int, split(line, ","))
            push!(points, Point(x + 1, y + 1)) # Julia is 1-indexed, offset needed for arrays later
        end
    end
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
    return point.x >= 1 && point.x <= map_size && point.y >= 1 && point.y <= map_size
end

function dijkstra(map, map_size)
    from = Point(1, 1)
    dest = Point(map_size, map_size)

    visited = falses(map_size, map_size)
    distances = fill(Inf, map_size, map_size)
    distances[from.y, from.x] = 0

    prev = Dict{Point,Point}()

    stack = [from]

    while !isempty(stack)
        pos = popfirst!(stack)
        visited[pos.y, pos.x] = true

        if pos == dest
            break
        end

        neighbors = [Point(pos.x + 1, pos.y), Point(pos.x - 1, pos.y),
            Point(pos.x, pos.y + 1), Point(pos.x, pos.y - 1)]
        next_dist = distances[pos.y, pos.x]
        for nb in neighbors
            if !is_valid(nb, map_size) || map[nb.y, nb.x]
                continue
            end

            if visited[nb.y, nb.x] || next_dist >= distances[nb.y, nb.x]
                continue
            end

            distances[nb.y, nb.x] = next_dist
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
        map[points[i].y, points[i].x] = true
    end

	debug_map(map, map_size)

    path = dijkstra(map, map_size)
    return size(path, 1)
end

function second_part(points, map_size)
    map = falses(map_size, map_size)

    for p in points
        map[p.y, p.x] = true
        if dijkstra(map, map_size) == []
            return p
        end
    end
end


const FILE_PATH = "input.txt"
const MAP_SIZE = 71
const MAXI = 1024

points = parse_input(FILE_PATH)

println("First part: $(first_part(points, MAP_SIZE, MAXI))")
point = second_part(points, MAP_SIZE)
println("Second part: ($(point.x - 1), $(point.y - 1))")
