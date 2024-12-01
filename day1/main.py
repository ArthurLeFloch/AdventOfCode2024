# Day 1: Historian Hysteria
from collections import Counter

# Parsing
first_list, second_list = [], []

with open('input.txt') as f:
	input_lines = f.readlines()
	
	for line in input_lines:
		numbers = line.split()
		first_list.append(int(numbers[0]))
		second_list.append(int(numbers[1]))

## Part 1 : distance
first_list.sort()
second_list.sort()

distance = sum(abs(first - second) for first, second in zip(first_list, second_list))
print("Distance between lists :", distance)

## Part 2 : similarity
occurrences = Counter(second_list)
similarity = sum(first * occurrences.get(first, 0) for first in first_list)

print("Similarity between lists :", similarity)