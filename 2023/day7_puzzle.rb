require "pry"

RANKS = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]

def contains_pair(cards, pair_length: 2)
  cards.each do |card|
    return true if cards.join.scan(card).count == pair_length
  end
  false
end

def remove_pair(cards, pair_length: 2)
  cards.each do |card|
    return cards.join.delete(card).chars if cards.join.scan(card).count == pair_length
  end
  cards
end

played_hands_data = []
File.readlines(File.dirname(__FILE__) + "/day7_input.txt", chomp: true).each do |line|
  cards, bit = line.split(" ")
  played_hands_data << {cards: cards, bit: bit.to_i, rank: 1}
end

played_hands_data.each do |hands_data|
  cards = hands_data[:cards].chars

  if contains_pair(cards, pair_length: 5) # Five of a kind
    hands_data[:rank] = 7
    next
  end

  if contains_pair(cards, pair_length: 4) # Four of a kind
    hands_data[:rank] = 6
    next
  end

  if contains_pair(cards, pair_length: 3) # Three of a kind
    remaining_cards = remove_pair(cards, pair_length: 3)
    hands_data[:rank] = if contains_pair(remaining_cards, pair_length: 2) # Full house
      5 # Full house
    else
      4 # Three of a kind
    end
    next
  end

  if contains_pair(cards, pair_length: 2)
    remaining_cards = remove_pair(cards, pair_length: 2)
    hands_data[:rank] = if contains_pair(remaining_cards, pair_length: 2)
      3 # Two pairs
    else
      2 # One pair
    end
  end
end

final_hands = []
played_hands_data.sort_by! { |hands_data| hands_data[:rank] }
played_hands_data.group_by { |hands_data| hands_data[:rank] }.each do |rank, hands_data|
  final_hands << hands_data.sort_by { |hands_data|
    hands_data[:cards].chars.map { |card| RANKS.index(card) }
  }.reverse
end

total_puzzle_1 = final_hands.flatten.map.with_index(1) do |hands_data, index|
  hands_data[:bit] * index
end.sum

puts "Puzzle 1: #{total_puzzle_1}"
