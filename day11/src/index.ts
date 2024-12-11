const fs = require("fs");

function parseInput() {
  return fs
    .readFileSync("input.txt", "utf-8")
    .trim()
    .split(" ")
    .map((num: string) => parseInt(num));
}

const cache = new Map();
function countStones(numbers: number[], depth: number): number {
  if (depth == 0) return numbers.length;
  let sum = 0;
  for (const num of numbers) {
    const cacheKey = `${num}-${depth}`;
    if (cache.has(cacheKey)) {
      sum += cache.get(cacheKey);
      continue;
    }

    let nextNumbers = [];
    if (num == 0) {
      nextNumbers.push(1);
    } else if (num.toString().length % 2 == 0) {
      const str = num.toString();
      const middle = str.length / 2;
      nextNumbers.push(parseInt(str.slice(0, middle)));
      nextNumbers.push(parseInt(str.slice(middle)));
    } else {
      nextNumbers.push(2024 * num);
    }
    const partial = countStones(nextNumbers, depth - 1);
    cache.set(cacheKey, partial);
    sum += partial;
  }

  return sum;
}

const input = parseInput();

console.log("First part:", countStones(input, 25));
console.log("Second part:", countStones(input, 75));
