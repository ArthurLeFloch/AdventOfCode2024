// Day 3: Mull It Over
package com.alfloch.aoc2024

import java.io.File

fun readFile(inputFilePath: String = "src/main/resources/input.txt"): String {
    val inputStream = File(inputFilePath).inputStream()
    val reader = inputStream.bufferedReader()

    // Syntax to close the reader at the end of the block, and return the result of the lambda
    return reader.use { it.readText() }
}

fun parseText(input: String): List<Pair<Int, Int>> {
    // Two groups of 1 to 3 digits separated by a comma
    val pattern = Regex("mul\\((\\d{1,3}),(\\d{1,3})\\)")
    val matches = pattern.findAll(input)
    val res = mutableListOf<Pair<Int, Int>>()
    for (match in matches) {
        val a = match.groupValues[1].toInt()
        val b = match.groupValues[2].toInt()
        res.add(Pair(a, b))
    }
    return res
}

// Using regular expressions
fun firstPart(input: String): Long {
    val pairs = parseText(input)
    var res: Long = 0
    for (pair in pairs) {
        res += pair.first * pair.second
    }
    return res
}

// Without regex
fun secondPart(input: String): Long {
    var res: Long = 0

    var canCompute = true

    val n = input.length
    // At least mul(1,1) which is 8 chars. "don't()" and "do()" are both below 8 chars
    var i = 0
    while (i <= n - 8) {
        val expectedNumberIndex = i + 4
        if (input.startsWith("do()", i)) {
            canCompute = true
            i += 4
            continue
        }
        if (!canCompute) {
            i++
            continue
        }
        if (input.startsWith("don't()", i)) {
            canCompute = false
            i += 7
            continue
        }


        if (!input.startsWith("mul(", i)) {
            i++
            continue
        }

        // Here, there is still at least,1) to scan because i + 8 <= n
        // Even if there's only one digit, we will not get out of bounds
        if (!input[expectedNumberIndex].isDigit()) {
            i = expectedNumberIndex
            continue
        }
        var digits_count = 1
        if (input[expectedNumberIndex + 1].isDigit()) {
            digits_count++
            if (input[expectedNumberIndex + 2].isDigit()) {
                digits_count++
            }
        }

        val expectedCommaIndex = expectedNumberIndex + digits_count

        if (input[expectedCommaIndex] != ',') {
            i = expectedCommaIndex
            continue
        }

        val a = input.substring(expectedNumberIndex, expectedCommaIndex).toInt()

        val expectedSecondNumberIndex = expectedCommaIndex + 1
        if (expectedSecondNumberIndex == n) break
        if (!input[expectedSecondNumberIndex].isDigit()) {
            i = expectedSecondNumberIndex
            continue
        }
        digits_count = 1
        // Check that there is at least two characters left (number and closing parenthesis)
        if (expectedSecondNumberIndex + 1 == n) break
        if (input[expectedSecondNumberIndex + 1].isDigit()) {
            digits_count++

            if (input[expectedSecondNumberIndex + 2].isDigit() and (expectedSecondNumberIndex + 2 != n)) {
                digits_count++
            }
        }

        val b = input.substring(expectedSecondNumberIndex, expectedSecondNumberIndex + digits_count).toInt()

        if (expectedSecondNumberIndex + digits_count == n) break
        if (input[expectedSecondNumberIndex + digits_count] != ')') {
            i = expectedSecondNumberIndex + digits_count
            continue
        }

        res += a * b
        i = expectedSecondNumberIndex + digits_count + 1
    }

    return res
}

fun main() {
    val content = readFile()
    val first = firstPart(content)
    println("Result: $first")
    val second = secondPart(content)
    println("Result: $second")

}