list_1, list_2 = [], []
puzzle_1_total, puzzle_2_total = 0, 0

File.readlines(File.dirname(__FILE__) + "/day1_input.txt", chomp: true).each do |line|
  first, second = line.split(" ").map(&:to_i)
  list_1 << first
  list_2 << second
end

list_1.sort!
list_2.sort!
list_1_copy = list_1.dup
list_2_copy = list_2.dup

list_1.length.times do |i|
  # Puzzle 1
  first_num = list_1.shift
  second_num = list_2.shift
  diff = (first_num - second_num).abs
  puzzle_1_total += diff

  # Puzzle 2
  first_num = list_1_copy[i]
  occurrences = list_2_copy.count(first_num)
  puzzle_2_total += first_num * occurrences
end

puts "Puzzle 1: #{puzzle_1_total}"
puts "Puzzle 2: #{puzzle_2_total}"
