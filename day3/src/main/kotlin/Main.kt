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
    val content = readFile()
    val first = firstPart(content)
    println("Result with all multiplications: $first")
    val second = secondPart(content)
    println("Result with only enabled multiplications: $second")
}