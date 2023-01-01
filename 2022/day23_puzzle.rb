class ElveGardening
  def initialize
    @instructions = initialize_instructions
    @elve_move_wishlist = initialize_wishlist
  end

  def initialize_instructions
    [
      {
        :if_condition => ['N', 'NE', 'NW'],
        :then_action => 'N'
      },
      {
        :if_condition => ['S', 'SE', 'SW'],
        :then_action => 'S'
      },
      {
        :if_condition => ['W', 'NW', 'SW'],
        :then_action => 'W'
      },
      {
        :if_condition => ['E', 'NE', 'SE'],
        :then_action => 'E'
      },
    ]
  end

  def initialize_wishlist
    Hash.new { |hash, key| hash[key] = [] }
  end

  def fill_grid(input)
    @grid = []
    input.each_with_index do |line, row_index|
      @grid << line.split('')
    end
  end

  def neighbours_coordinates_for(row_index, col_index)
    {
      :N =>  [row_index - 1, col_index], # north
      :S =>  [row_index + 1, col_index], # south
      :W =>  [row_index, col_index - 1], # west
      :E =>  [row_index, col_index + 1], # east
      :NW => [row_index - 1, col_index - 1], # north west
      :NE => [row_index - 1, col_index + 1], # north east
      :SW => [row_index + 1, col_index - 1], # south west
      :SE => [row_index + 1, col_index + 1], # south east
    }
  end

  def neighbours_for(coordinates)
    coordinates.inject({}) do |neighbours, (direction, (row_index, col_index))|
      neighbours[direction] = @grid[row_index][col_index]
      neighbours
    end
  end

  def prepare_move(row_index, col_index, current_instructions)
    # if there are no elves in the neighborcells -> do not move
    neighbours_coordinates = neighbours_coordinates_for(row_index, col_index)
    neighbours = neighbours_for(neighbours_coordinates)
    return if neighbours.values.count('#') == 0

    current_instructions.each do |instruction|
      # SAMPLE: If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
      # INSTRUCTION: {:if_condition=>["N", "NE", "NW"], :then_action=>"north"}
      if instruction[:if_condition].map { |direction| neighbours[direction.to_sym] }.count('#') == 0
        @elve_move_wishlist[[row_index, col_index]] = neighbours_coordinates[instruction[:then_action].to_sym]
        break
      end
    end
  end

  def extend_grid
    # extend top
    @grid.unshift(['.'] * @grid.first.size)
    # extend bottom
    @grid.push(['.'] * @grid.first.size)
    # extend left
    @grid = @grid.transpose.unshift(['.'] * @grid.size).transpose
    # extend right
    @grid = @grid.transpose.push(['.'] * @grid.size).transpose
  end

  def grid_borders
    [@grid.first, @grid.last, @grid.transpose.first, @grid.transpose.last]
  end

  def shrink_grid
    empty_borders_exist = true
    while empty_borders_exist
      top, bottom, left, right = grid_borders

      # remove borders if they are empty
      @grid.shift if top.count('#') == 0
      @grid.pop if bottom.count('#') == 0
      @grid = @grid.transpose
      @grid.shift if left.count('#') == 0
      @grid.pop if right.count('#') == 0
      @grid = @grid.transpose

      # check if there are still empty borders
      top, bottom, left, right = grid_borders
      empty_borders_exist = top.count('#') == 0 || bottom.count('#') == 0 || left.count('#') == 0 || right.count('#') == 0
    end
  end

  def solution(input:, part:)
    fill_grid(input)
    round = 1
    while true
      extend_grid
      current_instructions = round == 1 ? @instructions : @instructions.rotate!

      # Find out which elve wants to move where
      @grid.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          prepare_move(row_index, col_index, current_instructions) if cell == '#'
        end
      end

      # Move the elve
      @elve_move_wishlist.each do |elve, move_to_coordinates|
        if @elve_move_wishlist.values.count(move_to_coordinates) == 1
          # If its the only elve that wants to move to the desired cell > move the elve
          @grid[move_to_coordinates[0]][move_to_coordinates[1]] = '#'

          # reset the cell where the elve was
          @grid[elve[0]][elve[1]] = '.'
        end
      end

      # if no elve wants to move, or part 1 round limit is reached -> game is over
      break if @elve_move_wishlist.size == 0 || (part == 1 && round == 10)

      # reset the wishlist
      @elve_move_wishlist = initialize_wishlist
      round += 1
    end
    shrink_grid

    return @grid.flatten.count('.') if part == 1
    return round
  end
end

input = File.read('day23_input_rework.txt').split("\n")
puts "Part 1: #{ElveGardening.new.solution(input: input, part: 1)}"
puts "Part 2: #{ElveGardening.new.solution(input: input, part: 2)}"
