# Day 1: Historian Hysteria
from collections import Counter

# Parsing
first_list, second_list = [], []

with open('input.txt') as f:
    for line in f.readlines():
        numbers = line.split()
        first_list.append(int(numbers[0]))
        second_list.append(int(numbers[1]))

# Part 1 : distance
first_list.sort()
second_list.sort()

distance = sum(abs(a - b) for a, b in zip(first_list, second_list))
print("Distance between lists :", distance)

# Part 2 : similarity
occurrences = Counter(second_list)
similarity = sum(x * occurrences[x] for x in first_list)
print("Similarity between lists :", similarity)
