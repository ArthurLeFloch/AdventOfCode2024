// Day 19: Linen Layout

import Foundation

func parseInput(filePath: String) -> ([String], [String]) {
	let fileData = FileManager.default.contents(atPath: filePath)
	let fileContentString = String(data: fileData!, encoding: .utf8)
	let lines = fileContentString!.components(separatedBy: "\n").filter { $0 != "" }
	let parts = lines[0].components(separatedBy: ", ")
	let words = lines[1...]
	return (parts, Array(words))
}

func firstPart(parts: [String], words: [String]) -> Int {
	var regex = "("
	for part in parts {
		regex += part + "|"
	}
	regex.removeLast()
	regex += ")*"

	let actualRegex = try! Regex(regex)

	var sum = 0
	for word in words {
		if try! actualRegex.wholeMatch(in: String(word)) != nil {
			sum += 1
		}
	}

	return sum
}

func secondPart(parts: [String], words: [String]) -> Int {
	var cache = [String: Int]()

	func countPossibilities(word: String) -> Int {
		if let cached = cache[word] {
			return cached
		}
		if word.count == 0 {
			return 1
		}

		var sum = 0
		// Make a choice among the available parts
		for part in parts {
			if word.count < part.count {
				continue
			}

			// If word[index...] starts with part, we can continue
			let startIndex = word.index(word.startIndex, offsetBy: part.count)
			if word.hasPrefix(part) {
				sum += countPossibilities(word: String(word[startIndex...]))
			}
		}
		cache[word] = sum
		return sum
	}

	var res = 0
	for word in words {
		res += countPossibilities(word: word)
	}
	return res
}

var filePath = "input.txt"
var (parts, words) = parseInput(filePath: filePath)
print("First part: \(firstPart(parts: parts, words: words))")
print("Second part: \(secondPart(parts: parts, words: words))")
