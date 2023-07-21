UP = "("
DOWN = ")"
current_floor = 0
basement_encountered = false
basement_encountered_at = 0

File.read("day1_input.txt").each_char.with_index(1) do |char, index|
  current_floor += 1 if char == UP
  current_floor -= 1 if char == DOWN

  if current_floor == -1 && !basement_encountered
    basement_encountered = true
    basement_encountered_at = index
  end
end

puts "Puzzle 1: #{current_floor}"
puts "Puzzle 2: #{basement_encountered_at}"
