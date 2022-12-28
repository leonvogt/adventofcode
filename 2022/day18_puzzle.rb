require 'pry'
cubes = []
input = File.read('day18_input.txt').split("\n")
input.each do |line|
  x, y, z = line.split(',').map(&:to_i)
  cubes << [x, y, z]
end

sides_that_arent_touching = 0
minus = 0
cubes.each do |cube|
  x, y, z = cube
  cubes_to_check = cubes.reject { |c| c == cube }
  right_is_touching  = cubes_to_check.include?([x + 1, y, z])
  left_is_touching   = cubes_to_check.include?([x - 1, y, z])
  front_is_touching  = cubes_to_check.include?([x, y + 1, z])
  back_is_touching   = cubes_to_check.include?([x, y - 1, z])
  top_is_touching    = cubes_to_check.include?([x, y, z + 1])
  bottom_is_touching = cubes_to_check.include?([x, y, z - 1])

  if right_is_touching && left_is_touching && front_is_touching && back_is_touching
    minus += 6
  end
  sides_that_arent_touching += 1 if !right_is_touching
  sides_that_arent_touching += 1 if !left_is_touching
  sides_that_arent_touching += 1 if !front_is_touching
  sides_that_arent_touching += 1 if !back_is_touching
  sides_that_arent_touching += 1 if !top_is_touching
  sides_that_arent_touching += 1 if !bottom_is_touching
end

puts "Puzzle 1: #{sides_that_arent_touching}"
puts "Puzzle 2: #{sides_that_arent_touching - minus}"
# right, left, front, back, top, bottom