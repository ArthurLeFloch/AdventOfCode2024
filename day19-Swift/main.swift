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
	let regexString = "(" + parts.joined(separator: "|") + ")*"
	let regex = try! Regex(regexString)

	var sum = 0
	for word in words {
		if try! regex.wholeMatch(in: String(word)) != nil {
			sum += 1
		}
	}

	return sum
}

func secondPart(parts: [String], words: [String]) -> Int {
	let cache = NSCache<NSString, NSNumber>()

	func countPossibilities(word: String) -> Int {
		if let cached = cache.object(forKey: word as NSString) {
			return cached.intValue
		}
		if word.isEmpty {
			return 1
		}

		// Make a choice among the available parts
		let sum = parts.reduce(0) { sum, part in
			guard word.count >= part.count, word.hasPrefix(part) else {
				return sum
			}

			// If word[index...] starts with part, we can continue
			return sum + countPossibilities(word: String(word.dropFirst(part.count)))
		}
		cache.setObject(NSNumber(value: sum), forKey: word as NSString)
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
