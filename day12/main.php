<?php

class Position
{
	public function __construct(public int $x, public int $y)
	{
	}

	public function add(Position $v): void
	{
		$this->x += $v->x;
		$this->y += $v->y;
	}
}

class Problem
{
	public array $map;
	public array $array;
	public int $size;

	public function __construct(string $file_path)
	{
		$this->array = file($file_path);
		$this->size = count($this->array);
		$this->map = [];

		for ($i = 0; $i < $this->size; $i++) {
			$line = $this->array[$i];
			for ($j = 0; $j < $this->size; $j++) {
				$pos = new Position($i, $j);
				$this->map[$line[$j]][] = $pos;
			}
		}
	}

	public function is_same_key(Position $pos, string $key): bool
	{
		return !$this->is_off($pos) && $this->array[$pos->x][$pos->y] === $key;
	}

	public function key(Position $pos): string
	{
		return $this->array[$pos->x][$pos->y];
	}

	public function is_off(Position $pos): bool
	{
		return $pos->x < 0 || $pos->y < 0 || $pos->x >= $this->size || $pos->y >= $this->size;
	}
}

class AreaPerimeter
{
	public function __construct(public int $area, public int $perimeter)
	{
	}

	public function add(AreaPerimeter $other): void
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

	$others = [
		new Position($pos->x, $pos->y - 1),
		new Position($pos->x + 1, $pos->y),
		new Position($pos->x, $pos->y + 1),
		new Position($pos->x - 1, $pos->y)
	];

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
	foreach ($p->map as $key => $positions) {
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

	$others = [
		new Position($pos->x, $pos->y - 1),
		new Position($pos->x + 1, $pos->y),
		new Position($pos->x, $pos->y + 1),
		new Position($pos->x - 1, $pos->y)
	];

	$res = [$pos];

	foreach ($others as $other) {
		if (!$p->is_same_key($other, $key) || $seen[$other->x][$other->y])
			continue;
		$res = array_merge($res, recursive_search($p, $seen, $other, $key));
	}
	return $res;
}

function find_cluster_side_count(Problem $p, array $cluster, string $key): int
{
	$x_indexed = [];
	$y_indexed = [];

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

	foreach ($indexed as $index => $positions) {
		$vectors = $is_x ? [new Position(-1, 0), new Position(1, 0)] : [new Position(0, -1), new Position(0, 1)];
		foreach ($vectors as $v) {
			$found_first = false;
			$last = null;
			foreach ($positions as $pos) {
				$position = $is_x ? new Position($index, $pos) : new Position($pos, $index);
				$position->add($v);
				$cond = $p->is_off($position) || $p->key($position) !== $key;
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
	$clusters = [];
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

	foreach ($p->map as $key => $positions) {
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
