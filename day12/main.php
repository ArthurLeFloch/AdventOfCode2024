<?php

class Position
{
	public $x, $y;

	function __construct($x, $y)
	{
		$this->x = $x;
		$this->y = $y;
	}

	public function add(Position $v)
	{
		$this->x += $v->x;
		$this->y += $v->y;
	}
}

class Problem
{
	public $map;
	public $array;
	public $size;

	function __construct(string $file_path)
	{
		$this->array = file($file_path);
		$locations = array();
		$this->size = count($this->array);
		for ($i = 0; $i < $this->size; $i++) {
			$line = $this->array[$i];
			for ($j = 0; $j < $this->size; $j++) {
				$pos = new Position($i, $j);
				if (array_key_exists($line[$j], $locations)) {
					$locations[$line[$j]][] = $pos;
				} else {
					$locations[$line[$j]] = array($pos);
				}
			}
		}
		$this->map = $locations;
	}

	// For debug
	function show_map()
	{
		foreach (array_keys($this->map) as $key) {
			print ($key . ":\n");
			foreach ($this->map[$key] as $pos) {
				print ("(" . $pos->x . ", " . $pos->y . "), ");
			}
			print ("\n");
		}
	}

	function is_same_key(Position $pos, string $key): bool
	{
		if ($this->is_off($pos))
			return false;
		if ($this->array[$pos->x][$pos->y] != $key)
			return false;
		return true;
	}

	function key(Position $pos): string
	{
		return $this->array[$pos->x][$pos->y];
	}

	// hor = true : horizontal
	function is_off(Position $pos): bool
	{
		if ($pos->x < 0 || $pos->y < 0)
			return true;
		if ($pos->x >= $this->size || $pos->y >= $this->size)
			return true;
		return false;
	}

}

class AreaPerimeter
{
	public int $area;
	public int $perimeter;
	public function __construct(int $area, int $perimeter)
	{
		$this->area = $area;
		$this->perimeter = $perimeter;
	}

	public function add(AreaPerimeter $other)
	{
		$this->area += $other->area;
		$this->perimeter += $other->perimeter;
	}
}

function recursive_count(Problem $p, Position $pos, array &$seen, string $key): AreaPerimeter
{
	$res = new AreaPerimeter(0, 0);
	if ($seen[$pos->x][$pos->y])
		return $res;
	$seen[$pos->x][$pos->y] = true;

	$others = array(
		new Position($pos->x, $pos->y - 1),
		new Position($pos->x + 1, $pos->y),
		new Position($pos->x, $pos->y + 1),
		new Position($pos->x - 1, $pos->y)
	);

	$res->area = 1;

	foreach ($others as $other) {
		if ($p->is_same_key($other, $key)) {
			$res->add(recursive_count($p, $other, $seen, $key));
		} else {
			$res->perimeter++;
		}
	}

	return $res;
}

function first_part(Problem $p): int
{
	$sum = 0;
	foreach (array_keys($p->map) as $key) {
		$positions = $p->map[$key];
		$first_pos = $positions[0];
		$key = $p->array[$first_pos->x][$first_pos->y];
		$seen = array_fill(0, $p->size, array_fill(0, $p->size, false));

		foreach ($positions as $pos) {
			if ($seen[$pos->x][$pos->y])
				continue;

			$area_perimeter = recursive_count($p, $pos, $seen, $key);
			$sum += $area_perimeter->area * $area_perimeter->perimeter;
		}
	}
	return $sum;
}


function recursive_search(Problem $p, array &$seen, Position $pos, string $key): array
{
	$seen[$pos->x][$pos->y] = true;

	$others = array(
		new Position($pos->x, $pos->y - 1),
		new Position($pos->x + 1, $pos->y),
		new Position($pos->x, $pos->y + 1),
		new Position($pos->x - 1, $pos->y)
	);

	$res = array();
	$res[] = $pos;

	foreach ($others as $other) {
		if (!$p->is_same_key($other, $key))
			continue;
		if ($seen[$other->x][$other->y])
			continue;
		$to_add = recursive_search($p, $seen, $other, $key);
		$res = array_merge($res, $to_add);
	}
	return $res;
}

function find_cluster_side_count(Problem $p, array $cluster, string $key): int
{
	$x_indexed = array();
	$y_indexed = array();

	foreach ($cluster as $pos) {
		$x_indexed[$pos->x][] = $pos->y;
		$y_indexed[$pos->y][] = $pos->x;
	}

	foreach ($cluster as $pos) {
		sort($x_indexed[$pos->x]);
		sort($y_indexed[$pos->y]);
	}

	$x_count = count_sides($p, $x_indexed, $key, true);
	$y_count = count_sides($p, $y_indexed, $key, false);

	return $x_count + $y_count;
}

function count_sides(Problem $p, array $indexed, string $key, bool $is_x): int
{
	$count = 0;

	foreach (array_keys($indexed) as $index) {
		if ($is_x) {
			$vectors = array(new Position(-1, 0), new Position(1, 0));
		} else {
			$vectors = array(new Position(0, -1), new Position(0, 1));
		}
		foreach ($vectors as $v) {
			$found_first = false;
			$last = null;
			foreach ($indexed[$index] as $pos) {
				$position = $is_x ? new Position($index, $pos) : new Position($pos, $index);
				$position->add($v);
				$cond = $p->is_off($position) || $p->key($position) != $key;
				if ($cond && ($last === null || $pos === $last + 1)) {
					if (!$found_first) {
						$found_first = true;
						$count++;
					}
				} else if ($cond) {
					$found_first = true;
					$count++;
				} else {
					$found_first = false;
				}
				$last = $pos;
			}
		}
	}

	return $count;
}

function find_clusters(Problem $p, array &$seen, string $key): array
{
	$clusters = array();
	foreach ($p->map[$key] as $pos) {
		if ($seen[$pos->x][$pos->y])
			continue;
		$clusters[] = recursive_search($p, $seen, $pos, $key);
	}
	return $clusters;
}

function second_part(Problem $p): int
{
	$sum = 0;

	foreach (array_keys($p->map) as $key) {
		$seen = array_fill(0, $p->size, array_fill(0, $p->size, false));

		$clusters = find_clusters($p, $seen, $key);

		foreach ($clusters as $cluster) {
			$sides = find_cluster_side_count($p, $cluster, $key);
			$sum += count($cluster) * $sides;
		}
	}
	return $sum;
}


$input = new Problem("input.txt");
print ("First part : " . first_part($input) . "\n");

print ("Second part : " . second_part($input) . "\n");