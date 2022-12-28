def calc_solution(original_array, duplicated_array_with_index)
  coordinate_stater = [0, original_array.index(0)] # find the index of the number 0

  start_coordinate  = duplicated_array_with_index.index(coordinate_stater)
  first_coordinate  = (start_coordinate + 1000) % original_array.size
  second_coordinate = (start_coordinate + 2000) % original_array.size
  third_coordinate  = (start_coordinate + 3000) % original_array.size

  first_value   = duplicated_array_with_index[first_coordinate].first
  second_value  = duplicated_array_with_index[second_coordinate].first
  third_value   = duplicated_array_with_index[third_coordinate].first

  return first_value + second_value + third_value
end

def rearrange_array(original_array, duplicated_array_with_index)
  max_original_array_index = original_array.size - 1

  original_array.each_with_index do |number, index|
    next if number == 0

    current_number_index = duplicated_array_with_index.index([number, index])
    new_index = current_number_index + number

    # mod the new_index to make sure it's within the array
    new_index = new_index % max_original_array_index

    # swap the numbers
    duplicated_array_with_index.insert(new_index, duplicated_array_with_index.delete_at(current_number_index))

    return duplicated_array_with_index if index == max_original_array_index
  end
end

def puzzle_1
  original_array  = File.read('day20_input.txt').split("\n").map(&:to_i)
  duplicated_array_with_index = original_array.map.with_index { |number, index| [number, index] }

  duplicated_array_with_index = rearrange_array(original_array, duplicated_array_with_index)
  calc_solution(original_array, duplicated_array_with_index)
end

def puzzle_2
  original_array  = File.read('day20_input.txt').split("\n").map { |number| number.to_i * 811589153 }
  duplicated_array_with_index = original_array.map.with_index { |number, index| [number, index] }

  10.times do
    duplicated_array_with_index = rearrange_array(original_array, duplicated_array_with_index)
  end

  calc_solution(original_array, duplicated_array_with_index)
end

puts "Part 1: #{puzzle_1}"
puts "Part 2: #{puzzle_2}"
