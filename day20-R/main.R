parse_input <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  size <- length(lines)
  map <- matrix(0, nrow = size, ncol = size, byrow = TRUE)

  # Will be modified later
  start <- list(0, 0)
  end <- list(0, 0)

  # R's arrays are 1-indexed
  for (i in 1:size) {
    for (j in 1:size) {
      char <- substr(lines[i], j, j)
      if (char == "#") {
        map[i, j] <- 1
      } else if (char == "S") {
        start <- list(i, j)
      } else if (char == "E") {
        end <- list(i, j)
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

first_part <- function(map, size, start, end) {
  pos_equal <- function(pos1, pos2) {
    return(pos1[[1]] == pos2[[1]] && pos1[[2]] == pos2[[2]])
  }
  map_empty <- function(pos) {
    return(map[pos[[1]], pos[[2]]] == 0)
  }

  out_of_bounds <- function(pos) {
    return(pos[[1]] < 1 || pos[[1]] > size || pos[[2]] < 1 || pos[[2]] > size)
  }

  next_pos <- function(pos, old_pos) {
    top <- list(pos[[1]], pos[[2]] - 1)
    bottom <- list(pos[[1]], pos[[2]] + 1)
    right <- list(pos[[1]] + 1, pos[[2]])
    left <- list(pos[[1]] - 1, pos[[2]])
    if (map_empty(top) && !pos_equal(top, old_pos)) {
      return(top)
    }
    if (map_empty(bottom) && !pos_equal(bottom, old_pos)) {
      return(bottom)
    }
    if (map_empty(right) && !pos_equal(right, old_pos)) {
      return(right)
    }
    if (map_empty(left) && !pos_equal(left, old_pos)) {
      return(left)
    }
    return(NULL)
  }

  find_path <- function() {
    pos <- start
    old_pos <- start
    acc <- list(pos)
    while (TRUE) {
      tmp <- pos
      pos <- next_pos(pos, old_pos)
      old_pos <- tmp
      acc <- c(acc, list(pos))
      if (pos_equal(pos, end)) {
        return(acc)
      }
    }
  }

  cheat_positions <- function(pos) {
    res <- list()

    # Straight lines
    res <- c(res, list(list(pos[[1]], pos[[2]] - 2)))
    res <- c(res, list(list(pos[[1]] + 2, pos[[2]])))
    res <- c(res, list(list(pos[[1]], pos[[2]] + 2)))
    res <- c(res, list(list(pos[[1]] - 2, pos[[2]])))

    # Diagonals
    res <- c(res, list(list(pos[[1]] + 1, pos[[2]] - 1)))
    res <- c(res, list(list(pos[[1]] + 1, pos[[2]] + 1)))
    res <- c(res, list(list(pos[[1]] - 1, pos[[2]] + 1)))
    res <- c(res, list(list(pos[[1]] - 1, pos[[2]] - 1)))

    return(res)
  }

  path <- find_path()
  dist <- matrix(-Inf, nrow = size, ncol = size, byrow = TRUE)
  for (i in seq_along(path)) {
    pos <- path[[i]]
    dist[[pos[[1]], pos[[2]]]] <- i
  }
  sum <- 0

  for (pos in path) {
    cheat <- cheat_positions(pos)
    for (cpos in cheat) {
      if (out_of_bounds(cpos)) {
        next
      }
      if (dist[[cpos[[1]], cpos[[2]]]] - 100 >= dist[[pos[[1]], pos[[2]]]] + 2) {
        sum <- sum + 1
      }
    }
  }

  return(sum)
}

second_part <- function(map, size, start, end) {
  pos_equal <- function(pos1, pos2) {
    return(pos1[[1]] == pos2[[1]] && pos1[[2]] == pos2[[2]])
  }
  map_empty <- function(pos) {
    return(map[pos[[1]], pos[[2]]] == 0)
  }

  out_of_bounds <- function(pos) {
    return(pos[[1]] < 1 || pos[[1]] > size || pos[[2]] < 1 || pos[[2]] > size)
  }

  next_pos <- function(pos, old_pos) {
    top <- list(pos[[1]], pos[[2]] - 1)
    bottom <- list(pos[[1]], pos[[2]] + 1)
    right <- list(pos[[1]] + 1, pos[[2]])
    left <- list(pos[[1]] - 1, pos[[2]])
    if (map_empty(top) && !pos_equal(top, old_pos)) {
      return(top)
    }
    if (map_empty(bottom) && !pos_equal(bottom, old_pos)) {
      return(bottom)
    }
    if (map_empty(right) && !pos_equal(right, old_pos)) {
      return(right)
    }
    if (map_empty(left) && !pos_equal(left, old_pos)) {
      return(left)
    }
    return(NULL)
  }

  find_path <- function() {
    pos <- start
    old_pos <- start
    acc <- list(pos)
    while (TRUE) {
      tmp <- pos
      pos <- next_pos(pos, old_pos)
      old_pos <- tmp
      acc <- c(acc, list(pos))
      if (pos_equal(pos, end)) {
        return(acc)
      }
    }
  }

  cheat_positions <- function(pos, maxi) {
    res <- list()
    for (i in seq(-maxi, maxi)) {
      for (j in seq(-maxi, maxi)) {
        if (abs(i) + abs(j) <= 1 || (abs(i) + abs(j) > maxi)) {
          next
        }
        cpos <- list(pos[[1]] + i, pos[[2]] + j)
        if (!out_of_bounds(cpos) && map_empty(cpos)) {
          res <- c(res, list(cpos))
        }
      }
    }
    return(res)
  }

  path <- find_path()
  dist <- matrix(-Inf, nrow = size, ncol = size, byrow = TRUE)
  for (i in seq_along(path)) {
    pos <- path[[i]]
    dist[[pos[[1]], pos[[2]]]] <- i
  }
  sum <- 0

  for (pos in path) {
    cheat <- cheat_positions(pos, 20)
    for (cpos in cheat) {
      distance <- abs(cpos[[1]] - pos[[1]]) + abs(cpos[[2]] - pos[[2]])
      if (dist[[cpos[[1]], cpos[[2]]]] - 100 >= dist[[pos[[1]], pos[[2]]]] + distance) {
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
