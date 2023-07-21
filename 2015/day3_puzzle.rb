NORTH = "^"
SOUTH = "v"
EAST = ">"
WEST = "<"

# Puzzle 1
visited_houses_by_santa_alone = Set.new
solo_santas_position = [0, 0]

# Puzzle 2
visited_houses_by_teamwork = {[0, 0] => "The one and only Santa"}
santas_position, robosantas_position = [0, 0], [0, 0]

def move_santa_move(direction, position)
  case direction
  when NORTH
    position[0] += 1
  when SOUTH
    position[0] -= 1
  when EAST
    position[1] += 1
  when WEST
    position[1] -= 1
  end
end

File.read("day3_input.txt").chomp.chars.each_with_index do |direction, index|
  # Puzzle 1
  move_santa_move(direction, solo_santas_position)
  visited_houses_by_santa_alone << solo_santas_position.dup

  # Puzzle 2
  if index.even?
    position = santas_position
    santa_name = "The one and only Santa"
  else
    position = robosantas_position
    santa_name = "Not the real one but at least smth"
  end
  move_santa_move(direction, position)
  visited_houses_by_teamwork[position.dup] = santa_name
end

puts "Puzzle 1: #{visited_houses_by_santa_alone.size}"
puts "Puzzle 2: #{visited_houses_by_teamwork.size}"
