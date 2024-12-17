// Day 3: Mull It Over
package com.alfloch.aoc2024

import java.io.File

// Using regular expressions
fun firstPart(input: String): Long {
    val pattern = Regex("mul\\((\\d{1,3}),(\\d{1,3})\\)")
    return pattern.findAll(input).map {
        it.groupValues[1].toInt() * it.groupValues[2].toInt() * 1L
    }.sum()
}

// Without regex
// Less readable than using regex, but ~5 times faster on the given input
// Possible with regex because pattern.findAll finds the next match iteratively
fun secondPart(input: String): Long {
    // Avoid writing checks for out of bounds
    // len("mul(111,111)") - len("mul(1,1)") = 4
    val padded = input.plus(" ".repeat(4))
    var res: Long = 0

    var canCompute = true

    // At least mul(1,1) which is 8 chars. "don't()" and "do()" are both below 8 chars
    var i = 0
    while (i <= input.length - 8) {
        val expectedNumberIndex = i + 4
        if (padded.startsWith("do()", i)) {
            canCompute = true
            i += 4
            continue
        }
        if (!canCompute) {
            i++
            continue
        }
        if (padded.startsWith("don't()", i)) {
            canCompute = false
            i += 7
            continue
        }


        if (!padded.startsWith("mul(", i)) {
            i++
            continue
        }

        // Here, there is still at least,1) to scan because i + 8 <= n
        // Even if there's only one digit, we will not get out of bounds
        if (!padded[expectedNumberIndex].isDigit()) {
            i = expectedNumberIndex
            continue
        }
        var digitsCount = 1
        if (padded[expectedNumberIndex + 1].isDigit()) {
            digitsCount++
            if (padded[expectedNumberIndex + 2].isDigit()) {
                digitsCount++
            }
        }

        val expectedCommaIndex = expectedNumberIndex + digitsCount

        if (padded[expectedCommaIndex] != ',') {
            i = expectedCommaIndex
            continue
        }

        val a = padded.substring(expectedNumberIndex, expectedCommaIndex).toInt()

        val expectedSecondNumberIndex = expectedCommaIndex + 1
        if (!padded[expectedSecondNumberIndex].isDigit()) {
            i = expectedSecondNumberIndex
            continue
        }
        digitsCount = 1
        // Check that there is at least two characters left (number and closing parenthesis)
        if (padded[expectedSecondNumberIndex + 1].isDigit()) {
            digitsCount++

            if (padded[expectedSecondNumberIndex + 2].isDigit()) {
                digitsCount++
            }
        }

        val b = padded.substring(expectedSecondNumberIndex, expectedSecondNumberIndex + digitsCount).toInt()

        if (padded[expectedSecondNumberIndex + digitsCount] != ')') {
            i = expectedSecondNumberIndex + digitsCount
            continue
        }

        res += a * b
        i = expectedSecondNumberIndex + digitsCount + 1
    }

    return res
}

fun main() {
    val content = File("src/main/resources/input.txt").readText()
    val first = firstPart(content)
    println("Result with all multiplications: $first")
    val second = secondPart(content)
    println("Result with only enabled multiplications: $second")
}