package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type Problem struct {
	expected int
	list     []int
}

func parseInput(filePath string) []Problem {
	content, err := os.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}

	problems := []Problem{}

	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		if line == "" {
			continue
		}
		values := strings.Split(line, ":")
		expected, _ := strconv.Atoi(values[0])

		problem :=
			Problem{
				expected: expected,
				list:     []int{},
			}

		for _, value := range strings.Split(strings.TrimSpace(values[1]), " ") {
			number, _ := strconv.Atoi(value)
			problem.list = append(problem.list, number)
		}

		problems = append(problems, problem)
	}

	return problems
}

func recursiveCheck(problem Problem, index int, partialSum int) bool {
	if index == len(problem.list) {
		return partialSum == problem.expected
	}
	if partialSum > problem.expected {
		return false
	}

	return recursiveCheck(problem, index+1, partialSum+problem.list[index]) ||
		recursiveCheck(problem, index+1, partialSum*problem.list[index])

}

func firstPart(problems []Problem) int {
	sum := 0
	for _, problem := range problems {
		if recursiveCheck(problem, 1, problem.list[0]) {
			sum += problem.expected
		}
	}
	return sum
}

func recursiveCheckWithConcat(problem Problem, index int, partialSum int) bool {
	if index == len(problem.list) {
		return partialSum == problem.expected
	}
	if partialSum > problem.expected {
		return false
	}

	concatenated := strconv.Itoa(partialSum) + strconv.Itoa(problem.list[index])
	newPartialSum, _ := strconv.Atoi(concatenated)

	return recursiveCheckWithConcat(problem, index+1, partialSum+problem.list[index]) ||
		recursiveCheckWithConcat(problem, index+1, partialSum*problem.list[index]) ||
		recursiveCheckWithConcat(problem, index+1, newPartialSum)

}

func secondPart(problems []Problem) int {
	sum := 0
	for _, problem := range problems {
		if recursiveCheckWithConcat(problem, 1, problem.list[0]) {
			sum += problem.expected
		}
	}
	return sum
}

func main() {
	problems := parseInput("input.txt")

	fmt.Println("First part:", firstPart(problems))
	fmt.Println("Second part:", secondPart(problems))
}
