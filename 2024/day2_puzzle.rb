puzzle_1_total, puzzle_2_total = 0, 0

def check_numbers(number_array)
  pairs = number_array.each_cons(2).to_a
  correct_in_or_decrease = pairs.all? { |a, b| a < b } || pairs.all? { |a, b| a > b }
  correct_diffs = pairs.all? { |a, b| (b-3).upto((b -1)).include?(a) } || pairs.all? { |a, b| (b + 3).downto((b + 1)).include?(a) }

  correct_in_or_decrease && correct_diffs
end

File.readlines(File.dirname(__FILE__) + "/day2_input.txt", chomp: true).each do |line|
  numbers = line.split(" ").map(&:to_i)

  if check_numbers(numbers)
    puzzle_1_total += 1
    puzzle_2_total += 1
  else
    numbers.each_with_index do |_, index|
      dup = numbers.dup
      dup.delete_at(index)
      if check_numbers(dup)
        puzzle_2_total += 1
        break
      end
    end
  end
end

puts "Puzzle 1: #{puzzle_1_total}"
puts "Puzzle 2: #{puzzle_2_total}"
