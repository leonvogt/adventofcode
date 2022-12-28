require 'pry'
require 'rspec/autorun'
def puzzle_1
  original_array  = File.read('day20_input.txt').split("\n").map(&:to_i)
  duplicate_array_with_index = original_array.map.with_index { |number, index| [number, index] }
  original_array_size = original_array.size

  coordinate_stater = [0, original_array.index(0)] # find the index of the number 0

  original_array.each_with_index do |number, index|
    next if number == 0

    current_index_position_of_number = duplicate_array_with_index.index([number, index])
    # calculate the new index
    if number > 0
      new_index = current_index_position_of_number + number
    else
      new_index = current_index_position_of_number - number.abs
      new_index -= 1
    end

    # mod the index if it is out of bounds
    if new_index > original_array_size
      new_index = new_index % original_array_size
      new_index += 1
    elsif new_index < -original_array_size
      new_index = new_index % original_array_size
      new_index -= 1
    end

    # swap the numbers
    duplicate_array_with_index.insert(new_index, duplicate_array_with_index.delete_at(current_index_position_of_number))

    # if we are at the end of the array, calc the coordinates
    if index == original_array_size - 1
      start_coordinate  = duplicate_array_with_index.index(coordinate_stater)
      first_coordinate  = (start_coordinate + 1000) % original_array_size
      second_coordinate = (start_coordinate + 2000) % original_array_size
      third_coordinate  = (start_coordinate + 3000) % original_array_size

      first_value   = duplicate_array_with_index[first_coordinate].first
      second_value  = duplicate_array_with_index[second_coordinate].first
      third_value   = duplicate_array_with_index[third_coordinate].first
      return first_value + second_value + third_value
    end
  end
end

puts "Part 1: #{puzzle_1}"

RSpec.describe 'puzzle_1' do
  it 'returns the correct answer' do
    expect(puzzle_1).to eq(3)
  end
end
