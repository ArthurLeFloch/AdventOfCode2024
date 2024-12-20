parse_input <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  size <- length(lines)
  map <- matrix(0, nrow = size, ncol = size, byrow = TRUE)

  # Will be modified later
  start <- c(0, 0)
  end <- c(0, 0)

  # R's arrays are 1-indexed
  for (i in 1:size) {
    for (j in 1:size) {
      char <- substr(lines[i], j, j)
      if (char == "#") {
        map[i, j] <- 1
      } else if (char == "S") {
        start <- c(i, j)
      } else if (char == "E") {
        end <- c(i, j)
      }
    }
  }

  return(list(map = map, start = start, end = end, size = size))
}

debug_map <- function(map, size) {
  cat("Map(size=", size, ")\n")
  for (i in 1:size) {
    for (j in 1:size) {
      if (map[i, j] == 1) {
        cat("#")
      } else {
        cat(".")
      }
    }
    cat("\n")
  }
}

pos_equal <- function(pos1, pos2) {
  return(pos1[[1]] == pos2[[1]] && pos1[[2]] == pos2[[2]])
}
map_empty <- function(map, pos) {
  return(map[pos[[1]], pos[[2]]] == 0)
}
out_of_bounds <- function(pos, size) {
  return(pos[[1]] < 1 || pos[[1]] > size || pos[[2]] < 1 || pos[[2]] > size)
}

next_pos <- function(map, pos, old_pos) {
  top <- c(pos[[1]], pos[[2]] - 1)
  bottom <- c(pos[[1]], pos[[2]] + 1)
  right <- c(pos[[1]] + 1, pos[[2]])
  left <- c(pos[[1]] - 1, pos[[2]])
  if (map_empty(map, top) && !pos_equal(top, old_pos)) {
    return(top)
  }
  if (map_empty(map, bottom) && !pos_equal(bottom, old_pos)) {
    return(bottom)
  }
  if (map_empty(map, right) && !pos_equal(right, old_pos)) {
    return(right)
  }
  if (map_empty(map, left) && !pos_equal(left, old_pos)) {
    return(left)
  }
  return(NULL)
}


find_path <- function(map, start, end) {
  pos <- start
  old_pos <- start
  acc <- list(pos)
  while (TRUE) {
    tmp <- pos
    pos <- next_pos(map, pos, old_pos)
    old_pos <- tmp
    acc <- c(acc, list(pos))
    if (pos_equal(pos, end)) {
      return(acc)
    }
  }
}

cheat_positions <- function(map, size, pos, time) {
  res <- list()
  for (i in seq(-time, time)) {
    for (j in seq(-time, time)) {
      if (abs(i) + abs(j) <= 1 || (abs(i) + abs(j) > time)) {
        next
      }
      cpos <- c(pos[[1]] + i, pos[[2]] + j)
      if (!out_of_bounds(cpos, size) && map_empty(map, cpos)) {
        res <- c(res, list(cpos))
      }
    }
  }
  return(res)
}

first_part <- function(map, size, start, end) {
  path <- find_path(map, start, end)
  dist <- matrix(-Inf, nrow = size, ncol = size, byrow = TRUE)
  for (i in seq_along(path)) {
    pos <- path[[i]]
    dist[[pos[[1]], pos[[2]]]] <- i
  }
  sum <- 0

  for (pos in path) {
    cheat <- cheat_positions(map, size, pos, 2)
    current_dist <- dist[[pos[[1]], pos[[2]]]]
    for (cpos in cheat) {
      cheat_dist <- dist[[cpos[[1]], cpos[[2]]]]
      if (cheat_dist - 100 >= current_dist + 2) {
        sum <- sum + 1
      }
    }
  }

  return(sum)
}

second_part <- function(map, size, start, end) {
  path <- find_path(map, start, end)
  dist <- matrix(-Inf, nrow = size, ncol = size, byrow = TRUE)
  for (i in seq_along(path)) {
    pos <- path[[i]]
    dist[[pos[[1]], pos[[2]]]] <- i
  }
  sum <- 0

  for (pos in path) {
    cheat <- cheat_positions(map, size, pos, 20)
    current_dist <- dist[[pos[[1]], pos[[2]]]]
    for (cpos in cheat) {
      path_length <- abs(cpos[[1]] - pos[[1]]) + abs(cpos[[2]] - pos[[2]])
      cheat_dist <- dist[[cpos[[1]], cpos[[2]]]]
      if (cheat_dist - 100 >= current_dist + path_length) {
        sum <- sum + 1
      }
    }
  }

  return(sum)
}

data <- parse_input("input.txt")
debug_map(data$map, data$size)
map <- data$map
size <- data$size
start <- data$start
end <- data$end


cat("First part: ", first_part(map, size, start, end), "\n")
cat("Second part: ", second_part(map, size, start, end), "\n")
