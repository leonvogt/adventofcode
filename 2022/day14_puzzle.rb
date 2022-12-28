class SandScanner
  START_POINT = [500, 0]

  def initialize(puzzle)
    @map = {}
    @puzzle = puzzle
    @border_bottom = nil
  end

  def fill_in_between(from_x, from_y, to_x, to_y)
    (from_x..to_x).each do |x|
      (from_y..to_y).each do |y|
        @map[[x, y]] = 'rock'
      end
    end

    (to_x..from_x).each do |x|
      (to_y..from_y).each do |y|
        @map[[x, y]] = 'rock'
      end
    end
  end

  def fill_in_rocks(input)
    input.each do |line|
      coordinates = line.split(' -> ')
      coordinates.each_cons(2) do |from, to|
        from_x, from_y = from.split(',').map(&:to_i)
        to_x, to_y = to.split(',').map(&:to_i)

        # fill in every point between from and to
        fill_in_between(from_x, from_y, to_x, to_y)
      end
    end
  end

  def could_be_placed_at?(falling_sand_prediction)
    return @map[falling_sand_prediction].nil? if @puzzle == 'puzzle_1'
    
    @map[falling_sand_prediction].nil? && falling_sand_prediction.last < @border_bottom
  end

  def fill_in_sand(falling_sand)
    current_x, current_y = falling_sand
    
    # if sand is falling out of the map, stop the recursion
    throw :done if current_y > @border_bottom 
    
    one_down = [current_x, current_y + 1]
    if could_be_placed_at?(one_down)
      fill_in_sand(one_down)
    end    
    
    one_down_left = [current_x - 1, current_y + 1]
    if could_be_placed_at?(one_down_left)
      fill_in_sand(one_down_left)
    end
    
    one_down_right = [current_x + 1, current_y + 1]
    if could_be_placed_at?(one_down_right)
      fill_in_sand(one_down_right)
    end
    
    # If everything above is not possible, the sand comes to rest
    @map[falling_sand] = 'sand'
  end
  
  def solution(input)
    fill_in_rocks(input)

    @border_bottom = @map.keys.map(&:last).sort.last
    @border_bottom += 2 if @puzzle == 'puzzle_2'

    catch(:done) do
      fill_in_sand(START_POINT)
    end
    
    return "Sand Amount: #{@map.select { |key, value| value == 'sand' }.size}"
  end
end

input = File.read('day14_input.txt').split("\n")
puts SandScanner.new('puzzle_1').solution(input)
puts SandScanner.new('puzzle_2').solution(input)
