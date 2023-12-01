require "pry"

@writtenout_digits = {}
["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"].each.with_index(1) do |outwrite_digit, digit|
  @writtenout_digits[outwrite_digit] = digit
  @writtenout_digits[outwrite_digit.reverse] = digit
end

puzzle_part_one_values = []
puzzle_part_two_values = []

def find_digit(chars)
  5.times do |i|
    return chars[i].to_i if chars[i] =~ /\d/ # If it's a digit

    regex_pattern = "(#{@writtenout_digits.keys.join("|")})"
    chars[0..i].join.gsub(/#{regex_pattern}/) do |match|
      return @writtenout_digits[match] # If it's a word like "one" or "two" | "eno" or "owt"
    end
  end
  nil
end

File.readlines("day1_input.txt").each do |line|
  chars = line.chomp.chars

  # Puzzle Part 1
  first_digit = chars.find { |c| c =~ /\d/ }
  last_digit = chars.reverse.find { |c| c =~ /\d/ }
  puzzle_part_one_values << [first_digit, last_digit].join.to_i

  # Puzzle Part 2
  values = []
  slice_length = chars.length > 5 ? 5 : chars.length
  chars.each_cons(slice_length) do |cons|
    next if values.size == 1
    digit = find_digit(cons)
    values << digit if digit
  end

  chars.reverse.each_cons(slice_length) do |cons|
    next if values.size == 2
    digit = find_digit(cons)
    values << digit if digit
  end

  puzzle_part_two_values << values.join.to_i
end

puts "Puzzle 1: #{puzzle_part_one_values.sum}"
puts "Puzzle 2: #{puzzle_part_two_values.sum}"
