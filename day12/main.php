<?php

class Position
{
	public $x, $y;

	function __construct($x, $y)
	{
		$this->x = $x;
		$this->y = $y;
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
		if ($pos->x < 0 || $pos->y < 0)
			return false;
		if ($pos->x >= $this->size || $pos->y >= $this->size)
			return false;
		if ($this->array[$pos->x][$pos->y] != $key)
			return false;
		return true;
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


$input = new Problem("input.txt");
print ("First part : " . first_part($input) . "\n");

?>