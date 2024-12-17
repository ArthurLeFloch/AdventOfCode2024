// Day 17: Chronospatial Computer

import 'dart:io';

class Memory {
  int a;
  int b;
  int c;

  Memory(this.a, this.b, this.c);

  get(int literal) {
    if (literal <= 3) return literal;
    if (literal == 4) return a;
    if (literal == 5) return b;
    if (literal == 6) return c;

    throw Exception('Invalid literal');
  }

  setA(int value) {
    a = value;
  }

  getA() {
    return a;
  }

  setB(int value) {
    b = value;
  }

  getB() {
    return b;
  }

  setC(int value) {
    c = value;
  }

  getC() {
    return c;
  }
}
(Memory, List<int>) parseInput(String filePath) {
  List<String> lines = File(filePath).readAsLinesSync();

  var registerRegex = RegExp(r'Register [A-Z]: (\d+)');

  var a = int.parse(registerRegex.firstMatch(lines[0])!.group(1)!);
  var b = int.parse(registerRegex.firstMatch(lines[1])!.group(1)!);
  var c = int.parse(registerRegex.firstMatch(lines[2])!.group(1)!);
  var memory = Memory(a, b, c);

  var opRegex = RegExp(r'Program: ([\d,?]*)');

  var operations = opRegex
      .firstMatch(lines[4])!
      .group(1)!
      .split(',')
      .map((e) => int.parse(e))
      .toList();

  return (memory, operations);
}

void main(List<String> arguments) {
  var (memory, operations) = parseInput('input.txt');

  print('First part: ${firstPart(memory, operations)}');
}

String firstPart(Memory m, List<int> ops) {
	List<int> output = [];
	var n = ops.length;
	var sp = 0; // Instruction pointer
  while (sp < n) {
    var x = ops[sp + 1];
		if (sp + 1 == n) {
			print('Operation has no operand');
			return '';
		}
		switch (ops[sp]) {
			case 0: m.setA(m.getA() ~/ (1 << m.get(x))); break;
			case 1: m.setB(m.getB() ^ x); break;
			case 2: m.setB(m.get(x) % 8); break;
			case 4: m.setB(m.getB() ^ m.getC()); break;
			case 5: output.add(m.get(x) % 8); break;
			case 6: m.setB(m.getA() ~/ (1 << m.get(x))); break;
			case 7: m.setC(m.getA() ~/ (1 << m.get(x))); break;
			
		}
		if (ops[sp] == 3) {
			if (m.getA() == 0) {
				sp += 2;
			} else {
				sp = x;
			}
		} else {
			sp += 2;
		}
  }

  return output.join(',');
}
