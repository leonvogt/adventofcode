require 'rspec/autorun'

class HeightMapCalculator
  def initialize(height_map)
    @height_map = height_map
  end
  
  def find_char_positions(char)
    positions = []
    @height_map.each_with_index do |row, index|
      positions << [index, row.index(char)] if row.include?(char)
    end
    positions
  end

  # returns ord value of the ASCII character. a = 97, b = 98, c = 99, etc
  def find_value((x, y))
    char = @height_map[x][y]
    char = 'a' if char == 'S'
    char = 'z' if char == 'E'
    char.ord
  end

  def neighbors((x, y))
    # TOP - RIGHT - BOTTOM - LEFT
    [[x - 1, y], [x, y + 1], [x + 1, y], [x, y - 1]].select do |x, y|
      next if @height_map[x].nil?
      if (0..@height_map.size).include?(x) && (0..@height_map[x].size).include?(y)
        @height_map[x][y]
      end
    end
  end

  def possible_directions(current_square)
    neighbors(current_square).select do |x, y|
      find_value([x, y]) <= find_value(current_square) + 1
    end
  end

  def find_path_for(start_positions:, finish_positions:)
    visited = {}
    positions_to_check = []
    start_positions.each do |pos|
      positions_to_check << pos
      visited[pos] = 0
    end

    while positions_to_check.any?
      current = positions_to_check.shift
      
      return visited[current] if finish_positions.include?(current)

      possible_directions(current).each do |neighbor|
        if visited[neighbor].nil?
          visited[neighbor] = visited[current] + 1
          positions_to_check << neighbor
        end
      end
    end
  end
end

height_map = File.read('day12_input.txt').split("\n").map(&:chars)
calculator = HeightMapCalculator.new(height_map)
finish     = calculator.find_char_positions('E')
puts "Part 1: #{calculator.find_path_for(start_positions: calculator.find_char_positions('S'), finish_positions: finish)}"
puts "Part 2: #{calculator.find_path_for(start_positions: calculator.find_char_positions('a'), finish_positions: finish)}"

RSpec.describe HeightMapCalculator do
  before do
    height_map = [
      ["S", "a", "b", "q", "p", "o", "n", "m"], 
      ["a", "b", "c", "r", "y", "x", "x", "l"], 
      ["a", "c", "c", "s", "z", "E", "x", "k"], 
      ["a", "c", "c", "t", "u", "v", "w", "j"], 
      ["a", "b", "d", "e", "f", "g", "h", "i"]
    ]
  end

  it 'gets neighbors' do
    expect(HeightMapCalculator.new(height_map).neighbors([0, 0])).to eq([[0, 1], [1, 0]])
    expect(HeightMapCalculator.new(height_map).neighbors([2, 2])).to eq([[1, 2], [2, 3], [3, 2], [2, 1]])
  end

  it 'possible directions' do
    expect(HeightMapCalculator.new(height_map).possible_directions([0, 0])).to eq([[0, 1], [1, 0]]) 
    expect(HeightMapCalculator.new(height_map).possible_directions([4, 5])).to eq([[4, 6], [4, 4]]) 
  end
end