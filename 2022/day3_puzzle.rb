ALPHABET = ('a'..'z').to_a

def points_for_letter(char)
  point = ALPHABET.index(char.downcase) + 1
  point += 26 if char == char.upcase
  point
end

def get_total_of_priorities_points(rucksacks)
  total = 0

  rucksacks.each do |rucksack|
    half        = rucksack.length / 2
    first_half  = rucksack.slice(0, half)
    second_half = rucksack.slice(half, rucksack.length)
  
    common_chars      = first_half.chars & second_half.chars
    priorities_points = common_chars.map { |char| points_for_letter(char) }
    total            += priorities_points.sum
  end
  total
end

def get_total_of_priorities_points_for_each_group_of_three(rucksacks)
  total = 0

  rucksacks_in_groups = rucksacks.each_slice(3).to_a
  rucksacks_in_groups.each do |rucksack_group|
    common_chars      = rucksack_group[0].split('') & rucksack_group[1].split('') & rucksack_group[2].split('')
    priorities_points = common_chars.map { |char| points_for_letter(char) }
    total            += priorities_points.sum
  end
  total
end

input     = File.read('day3_input.txt')
rucksacks = input.split("\n")

puts get_total_of_priorities_points(rucksacks)
puts get_total_of_priorities_points_for_each_group_of_three(rucksacks)