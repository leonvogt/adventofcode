require "pry"

class Grid
  attr_reader :grid_array, :numbers_data, :gear_ratios

  def initialize
    @grid_array = []
    @numbers_data = []
    @gear_ratios = []
  end

  def set_tile(x, y, content)
    @grid_array[x] ||= []
    @grid_array[x][y] = content
  end

  def tile_at(x, y)
    return nil if x < 0 || y < 0 # Out of bounds

    row = @grid_array[x] || []
    row[y] || nil
  end

  def neighbour(x, y, direction, with_coordinates: false)
    x, y = case direction
    when :north
      [x - 1, y]
    when :south
      [x + 1, y]
    when :west
      [x, y - 1]
    when :east
      [x, y + 1]
    when :north_west
      [x - 1, y - 1]
    when :north_east
      [x - 1, y + 1]
    when :south_west
      [x + 1, y - 1]
    when :south_east
      [x + 1, y + 1]
    end

    tile = tile_at(x, y)
    with_coordinates ? {tile: tile, x: x, y: y} : tile
  end

  def neighbours(x, y, with_coordinates: false)
    directions = [:north, :north_east, :east, :south_east, :south, :south_west, :west, :north_west]
    directions.map { |direction| neighbour(x, y, direction, with_coordinates:) }
  end

  def is_number?(string)
    true if Float(string)
  rescue
    false
  end

  def is_symbol?(string)
    return false if string.nil? || string == "." || is_number?(string)
    true
  end

  def set_numbers
    @grid_array.each_with_index do |row, row_index|
      tmp_digit_data = []
      row.each_with_index do |col, col_index|
        next_col_is_a_number = is_number?(neighbour(row_index, col_index, :east))
        current_col_is_a_number = is_number?(col)

        # Store all digits we encounter in a row
        if current_col_is_a_number
          tmp_digit_data << {digit: col, x: row_index, y: col_index}
        end

        # If the next column is not a number, our number is complete
        if current_col_is_a_number && !next_col_is_a_number
          number_is_adjacent_to_symbol = tmp_digit_data.any? { |data| neighbours(data[:x], data[:y]).any? { |neighbour| is_symbol?(neighbour) } }
          if number_is_adjacent_to_symbol
            complete_number = tmp_digit_data.map { |data| data[:digit] }.join.to_i

            @numbers_data << {number: complete_number, x: tmp_digit_data.first[:x], start_y: tmp_digit_data.first[:y], end_y: tmp_digit_data.last[:y]}
          end
        end

        if !current_col_is_a_number
          tmp_digit_data = []
        end
      end
      tmp_digit_data = []
    end
    @numbers_data
  end

  GEAR_RATIO_SYMBOL = "*"
  GEAR_RATIO_NUMBER_AMOUNT = 2
  def set_gear_ratios
    @grid_array.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        next unless col == GEAR_RATIO_SYMBOL
        numbers_data = Set.new

        # Go through all neighbours and find all numbers
        neighbours(row_index, col_index, with_coordinates: true).each do |neighbour_data|
          tile, x, y = neighbour_data[:tile], neighbour_data[:x], neighbour_data[:y]
          next unless is_number?(tile)

          numbers_data << @numbers_data.find { |data| data[:x] == x && y.between?(data[:start_y], data[:end_y]) }
        end

        if numbers_data.size == GEAR_RATIO_NUMBER_AMOUNT
          @gear_ratios << numbers_data.map { |data| data[:number] }.inject(:*)
        end
      end
    end
  end
end

grid = Grid.new
File.read("day3_input.txt").split("\n").each_with_index do |line, row_index|
  line.chars.each_with_index do |char, col_index|
    grid.set_tile(row_index, col_index, char)
  end
end

grid.set_numbers
grid.set_gear_ratios

puts "Puzzle 1: #{grid.numbers_data.map { |data| data[:number] }.sum}"
puts "Puzzle 2: #{grid.gear_ratios.sum}"
