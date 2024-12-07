require 'strscan'

NUMBERS_REGEX = /mul\((\d+),(\d+)\)/
puzzle_1_total, puzzle_2_total = 0, 0

def multiply_all_instructions(instructions)
  numbers_array = instructions.scan(NUMBERS_REGEX)
  numbers_array.sum { |numbers| numbers.map(&:to_i).inject(:*) }
end

input = File.readlines(File.dirname(__FILE__) + "/day3_input.txt", chomp: true).join

# Puzzle 1
puzzle_1_total = multiply_all_instructions(input)

# Puzzle 2
scanner = StringScanner.new(input)
while scanner.rest?
  actual_instructions = scanner.scan_until(/don't\(\)/)

  # When there is no upcoming "dont()", take the remaining string
  if actual_instructions.nil? && scanner.rest?
    actual_instructions = scanner.rest
    scanner.clear
  end

  puzzle_2_total += multiply_all_instructions(actual_instructions)
  scanner.scan_until(/do\(\)/)
end

puts "Puzzle 1: #{puzzle_1_total}"
puts "Puzzle 2: #{puzzle_2_total}"
