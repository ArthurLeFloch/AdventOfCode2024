// Day 7: Bridge Repair

package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type Equation struct {
	result  int
	numbers []int
}

type EquationSet []Equation

func parseInput(filePath string) EquationSet {
	content, err := os.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}

	equations := EquationSet{}

	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		if line == "" {
			continue
		}
		values := strings.Split(line, ":")
		expected, _ := strconv.Atoi(values[0])

		equation :=
			Equation{
				result:  expected,
				numbers: []int{},
			}

		for _, value := range strings.Fields(values[1]) {
			number, _ := strconv.Atoi(value)
			equation.numbers = append(equation.numbers, number)
		}

		equations = append(equations, equation)
	}

	return equations
}

func canSolve(equation *Equation, index int, partialSum int) bool {
	if index == len(equation.numbers) {
		return partialSum == equation.result
	}
	if partialSum > equation.result {
		return false
	}
	nextNumber := equation.numbers[index]

	return canSolve(equation, index+1, partialSum+nextNumber) ||
		canSolve(equation, index+1, partialSum*nextNumber)
}

func firstPart(equations *EquationSet) int {
	sum := 0
	for _, equation := range *equations {
		if canSolve(&equation, 1, equation.numbers[0]) {
			sum += equation.result
		}
	}
	return sum
}

func canSolveExtended(equation *Equation, index int, partialSum int) bool {
	if index == len(equation.numbers) {
		return partialSum == equation.result
	}
	if partialSum > equation.result {
		return false
	}
	nextNumber := equation.numbers[index]

	concatenated := strconv.Itoa(partialSum) + strconv.Itoa(nextNumber)
	newPartialSum, _ := strconv.Atoi(concatenated)

	return canSolveExtended(equation, index+1, partialSum+nextNumber) ||
		canSolveExtended(equation, index+1, partialSum*nextNumber) ||
		canSolveExtended(equation, index+1, newPartialSum)

}

func secondPart(equations *EquationSet) int {
	sum := 0
	for _, equation := range *equations {
		if canSolveExtended(&equation, 1, equation.numbers[0]) {
			sum += equation.result
		}
	}
	return sum
}

func main() {
	equations := parseInput("input.txt")

	fmt.Println("First part:", firstPart(&equations))
	fmt.Println("Second part:", secondPart(&equations))
}
