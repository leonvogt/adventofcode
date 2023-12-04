require "pry"

total_puzzle_1 = 0
cards = {}

File.readlines(File.dirname(__FILE__) + "/day4_input.txt", chomp: true).each do |line|
  card_number_info, rest = line.split(": ")
  card_number = card_number_info.split("Card ").last.to_i
  winning_numbers, my_numbers = rest.split(" | ").map { |numbers| numbers.split(" ").map(&:to_i) }

  cards[card_number] ||= 1

  matches = winning_numbers & my_numbers
  next if matches.empty?

  cards[card_number].times do
    matches.each.with_index(1) do |_, index|
      cards[card_number + index] ||= 1
      cards[card_number + index] += 1
    end
  end

  total_puzzle_1 += 2**(matches.size - 1)
end

puts "Puzzle 1: #{total_puzzle_1}"
puts "Puzzle 2: #{cards.values.sum}"
