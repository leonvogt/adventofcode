class Colorize
  def self.red(text)
    "\033[31m#{text}\033[0m"
  end

  def self.green(text)
    "\e[32m#{text}\e[0m"
  end

  def self.blue(text)
    "\e[94m#{text}\e[0m"
  end
end

class JungleWalk
  DIRECTION_POINTS = {
    'up' => 3,
    'down' => 1,
    'left' => 2,
    'right' => 0,
  }
  def initialize
    @map  = []
    @instructions = []
  end

  def fill_map(input)
    input.each_with_index do |line, row_index|
      if line.match(/\d/) # if line includes a number
        @instructions = line.split('')
      else
        @map << line.split('')
      end
    end
  end

  def print_map(desired_row = nil, desired_col = nil, current_row = nil, current_col = nil)
    @map.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        if col_index == desired_col && row_index == desired_row
          print Colorize.red('X')
        elsif col_index == current_col && row_index == current_row
          print Colorize.blue('X')
        else
          print col
        end
      end
      puts
    end
  end

  def assemble_next_instruction
    return 'finished' if @instructions == []

    instruction = @instructions.shift

    if instruction.match(/\d/) # if instruction is a number
      if !@instructions[0].nil? && @instructions[0].match(/\d/) # if next instruction is also a number
        return instruction + @instructions.shift # return the two numbers
      else
        return instruction
      end
    end

    return instruction # return the direction instruction
  end

  def move(current_position, direction, amount_of_steps)
    row, col = current_position
    case direction
    when 'up'
      amount_of_steps.times do
        next_row = row - 1
        # loop from the end of the map to the current row
        # and find the other side of the map
        if @map[next_row][col].nil? || @map[next_row][col] == ' '
          (@map.size - 1).downto(row) do |row_index|
            if !@map[row_index][col].nil? && @map[row_index][col] != ' '
              next_row = row_index
              break
            end
          end
        end
        break if @map[next_row][col] == '#'

        @map[next_row][col] = '^'
        row = next_row
      end
    when 'down'
      amount_of_steps.times do
        next_row = row + 1
        if @map[next_row][col].nil? || @map[next_row][col] == ' '
          # loop from the beginning of the map to the current row
          # and find the other side of the map
          (0..row).each do |row_index|
            if !@map[row_index][col].nil? && @map[row_index][col] != ' '
              next_row = row_index
              break
            end
          end
        end
        break if @map[next_row][col] == '#'

        @map[next_row][col] = 'v'
        row = next_row
      end
    when 'left'
      amount_of_steps.times do
        next_col = col - 1
        if @map[row][next_col].nil? || @map[row][next_col] == ' ' || next_col < 0
          # if next position is out of bounds
          # find the next col that is empty or a wall
          @map[row].to_enum.with_index.reverse_each do |col, col_index|
            if !col.nil? && col != ' '
              next_col = col_index
              break
            end
          end
        end
        break if @map[row][next_col] == '#'

        @map[row][next_col] = '<'
        col = next_col
      end
    when 'right'
      amount_of_steps.times do
        next_col = col + 1
        if @map[row][next_col].nil? || @map[row][next_col] == ' '
          # if next position is out of bounds
          # find the next col that is empty or a wall
          next_col = @map[row].find_index { |col| !col.nil? && col != ' ' }
        end
        break if @map[row][next_col] == '#' # if next position is a wall

        @map[row][next_col] = '>'
        col = next_col
      end
    end

    return [row, col]
  end

  def change_direction(current_direction, instruction)
    case current_direction
    when 'up'
      return 'right' if instruction == 'R'
      return 'left'  if instruction == 'L'
    when 'down'
      return 'left'  if instruction == 'R'
      return 'right' if instruction == 'L'
    when 'left'
      return 'up'    if instruction == 'R'
      return 'down'  if instruction == 'L'
    when 'right'
      return 'down'  if instruction == 'R'
      return 'up'    if instruction == 'L'
    end
  end

  def walk_through_map
    current_position = [0, @map[0].find_index('.')]
    current_direction = 'right'
    instruction = assemble_next_instruction

    until instruction == 'finished'
      if instruction.match(/\d/)
        current_position = move(current_position, current_direction, instruction.to_i)
      else
        current_direction = change_direction(current_direction, instruction)
      end
      instruction = assemble_next_instruction
    end

    row_score = current_position[0] + 1
    col_score = current_position[1] + 1
    dir_score = DIRECTION_POINTS[current_direction]
    return (1000 * row_score) + (4 * col_score) + dir_score
  end
end

jungle_walk = JungleWalk.new
jungle_walk.fill_map(File.read('day22_input.txt').split("\n"))
puts "Part 1: #{jungle_walk.walk_through_map}"
