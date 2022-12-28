require 'pry'
require 'rspec/autorun'

class Tetris
  attr_accessor :grid, :shapes
  MIN_SPACE_TO_BOTTOM = 3
  GRID_WIDTH = 7
  SHAPE_SIGN = '@'
  STONE_SIGN = '#'

  def initialize
    @grid   = [ Array.new(GRID_WIDTH) { '#' } ] # add just the bottom row for now
    @shapes = initialize_shapes.freeze
  end

  def initialize_shapes
    shapes = []
    shapes << [
      [nil, nil, '@', '@', '@', '@', nil]
    ]
    shapes << [
      [nil, nil, nil, '@', nil, nil, nil],
      [nil, nil, '@', '@', '@', nil, nil],
      [nil, nil, nil, '@', nil, nil, nil]
    ]
    shapes << [
      [nil, nil, nil, nil, '@', nil, nil],
      [nil, nil, nil, nil, '@', nil, nil],
      [nil, nil, '@', '@', '@', nil, nil]
    ]
    shapes << [
      [nil, nil, '@', nil, nil, nil, nil],
      [nil, nil, '@', nil, nil, nil, nil],
      [nil, nil, '@', nil, nil, nil, nil],
      [nil, nil, '@', nil, nil, nil, nil]
    ]
    shapes << [
      [nil, nil, '@', '@', nil, nil, nil],
      [nil, nil, '@', '@', nil, nil, nil]
    ]
    shapes
  end

  def print_grid
    @grid.each do |row|
      print '|'
      print row.map { |e| e.nil? ? '.' : e }.join
      print '|'
      puts
    end
  end

  def collides?(current_col, next_col)
    next_col == SHAPE_SIGN || next_col == STONE_SIGN
  end

  def spawn_shape(shape)
    # prepend rows to the grid, so the new shape can be added to the top of the grid
    MIN_SPACE_TO_BOTTOM.times { @grid.prepend(Array.new(GRID_WIDTH)) }

    # place the shape on the grid
    shape.reverse_each { |row| @grid.prepend(row) }
  end

  def replace_shape_with_stones(shape, shape_start_index: 0, debug: false)
    shape.size.times do |row_index|
      # replace all the SHAPE_SIGNs with STONE_SIGNs
      @grid[shape_start_index + row_index].map! { |col| col == SHAPE_SIGN ? STONE_SIGN : col }
    end
  end

  def would_collides_down?(shape, shape_start_index: 0, debug: false)
    shape_end_index = shape_start_index + shape.size
    fake_grid = @grid[shape_start_index..shape_end_index].map { |row| row.dup }
    (shape_start_index..shape_end_index).each_with_index do |count, row_index|
      current_row_index = shape_end_index - count
      next_row_index    = current_row_index + 1
      fake_grid[current_row_index].each_with_index do |col, col_index|
        next if col.nil? || col == STONE_SIGN
        next_col = fake_grid[next_row_index][col_index]

        return true if collides?(col, next_col)
      end
      # remove all the SHAPE_SIGNs from the current row
      new_current_row = fake_grid[current_row_index].map { |col| col == SHAPE_SIGN ? nil : col }
      fake_grid[next_row_index - 1 ] = new_current_row
    end
    return false
  end

  def move_shape_down(shape, shape_start_index: 0, debug: false)
    if would_collides_down?(shape, shape_start_index: shape_start_index, debug: debug)
      replace_shape_with_stones(shape, shape_start_index: shape_start_index, debug: debug)
      throw :collides
    end

    shape_end_index = shape_start_index + shape.size - 1
    (shape_start_index..shape_end_index).each_with_index do |count, row_index|
      # begin at the end of the shape and move each row down
      current_row_index = shape_end_index - row_index
      next_row_index    = current_row_index + 1
      @grid[current_row_index].each_with_index do |col, col_index|
        next if col.nil? || col == STONE_SIGN
        @grid[next_row_index][col_index] = col
      end

      # remove all the SHAPE_SIGNs from the current row
      new_current_row = @grid[current_row_index].map { |col| col == SHAPE_SIGN ? nil : col }
      @grid[current_row_index] = new_current_row
    end

    # remove first row of the grid, if it's empty
    if @grid.first.all?(&:nil?)
      @grid.shift
      return shape_start_index
    else
      return shape_start_index + 1
    end
  end


  def would_collides_left?(shape, shape_start_index: 0, debug: false)
    # get first three rows of the grid as a fake grid (to avoid modifying the real grid)
    shape_end_index = shape_start_index + shape.size - 1
    fake_grid = @grid[shape_start_index..shape_end_index].map { |row| row.dup }

    (shape_start_index..shape_end_index).each_with_index do |count, row_index|
      current_row_index = shape_end_index - count
      fake_grid[current_row_index].each_with_index do |col, col_index|
        next if col.nil? || col == STONE_SIGN || col_index == 0
        prev_col = fake_grid[current_row_index][col_index - 1]
        return true if collides?(col, prev_col)
        fake_grid[current_row_index][col_index - 1] = col
        fake_grid[current_row_index][col_index] = nil
      end
    end
    return false
  end

  def would_collides_right?(shape, shape_start_index: 0, debug: false)
    # get first three rows of the grid as a fake grid (to avoid modifying the real grid)
    shape_end_index = shape_start_index + shape.size - 1
    fake_grid = @grid[shape_start_index..shape_end_index].map { |row| row.dup }

    (shape_start_index..shape_end_index).each_with_index do |count, row_index|
      current_row_index = shape_end_index - count
      fake_grid[current_row_index].to_enum.with_index.reverse_each do |col, col_index|
        next if col.nil? || col == STONE_SIGN || col_index == GRID_WIDTH - 1
        next_col = fake_grid[current_row_index][col_index + 1]
        return true if collides?(col, next_col)
        fake_grid[current_row_index][col_index + 1] = col
        fake_grid[current_row_index][col_index] = nil
      end
    end
    return false
  end

  def maybe_move_shape_left(shape, shape_start_index: 0, debug: false)
    return if would_collides_left?(shape, shape_start_index: shape_start_index, debug: debug)
    shape_end_index = shape_start_index + shape.size - 1
    (shape_start_index..shape_end_index).each_with_index do |count, row_index|
      current_row_index = shape_end_index - row_index
      @grid[current_row_index].each_with_index do |col, col_index|
        next if col.nil? || col == STONE_SIGN || col_index == 0
        # shift the current col to the left
        @grid[current_row_index][col_index - 1] = col
        @grid[current_row_index][col_index] = nil
      end
    end
  end

  def maybe_move_shape_right(shape, shape_start_index: 0, debug: false)
    return if would_collides_right?(shape, shape_start_index: shape_start_index, debug: debug)
    shape_end_index = shape_start_index + shape.size - 1
    (shape_start_index..shape_end_index).each_with_index do |count, row_index|
      current_row_index = shape_end_index - row_index

      @grid[current_row_index].to_enum.with_index.reverse_each do |col, col_index|
        next if col.nil? || col == STONE_SIGN || col_index == GRID_WIDTH - 1
        # shift the current col to the right
        @grid[current_row_index][col_index + 1] = col
        @grid[current_row_index][col_index] = nil
      end
    end
  end

  def puzzle_1(amount_of_stopped_rocks:)
    original_input = File.read('day17_input.txt').chomp.split('')
    shapes_copy   = @shapes.dup.map { |shape| shape.dup.map(&:dup) }
    input_copy    = original_input.dup

    current_shape = shapes_copy.shift
    spawn_shape(current_shape)
    current_shape = current_shape.dup.map(&:dup)
    shape_start_index = 0
    stopped_rocks = 0
    while true
      # create new array on the fly for unlimited input and shapes
      input_copy  = original_input.dup if input_copy.empty?
      shapes_copy = @shapes.dup.map { |shape| shape.dup.map(&:dup) } if shapes_copy.empty?

      # try to move shape left or right
      direction = input_copy.shift
      maybe_move_shape_left(current_shape, shape_start_index: shape_start_index) if direction == '<'
      maybe_move_shape_right(current_shape, shape_start_index: shape_start_index) if direction == '>'
      begin
        # try to move shape one row down
        shape_start_index = move_shape_down(current_shape, shape_start_index: shape_start_index)
      rescue
        # if collides
        stopped_rocks += 1

        # SOLUTION -> subtract 1 because the bottom row is not counted
        return @grid.size - 1 if stopped_rocks == amount_of_stopped_rocks

        # spawn a new shape
        current_shape = shapes_copy.shift
        shape_start_index = 0
        spawn_shape(current_shape)
      end
    end
  end
end

tetris = Tetris.new
puts "Part 1: #{tetris.puzzle_1(amount_of_stopped_rocks: 2022)}"               # =>  0.167 seconds
# puts "Part 2: #{tetris.puzzle_1(amount_of_stopped_rocks: 1_000_000_000_000)}"  # ≈> 19.025 years


RSpec.describe Tetris do
  it 'works for part 1' do
    expect(described_class.new.puzzle_1(amount_of_stopped_rocks: 2022)).to eq(3055)
  end

  describe '#collides?' do
    context 'down' do
      it 'detects bottom' do
        expect(described_class.new.collides?(nil, '#')).to eq(true)
      end
      it 'detects shape' do
        expect(described_class.new.collides?('@', '#')).to eq(true)
      end

      it 'detects that the next row is clear' do
        expect(described_class.new.collides?('@', nil)).to eq(false)
      end
    end
  end

  describe '#spawn_shape' do
    it 'spawns shape 1' do
      t = described_class.new
      t.spawn_shape(t.shapes[0])
      expect(t.grid).to eq(
        [
          [nil, nil, '@', '@', '@', '@', nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'spawns shape 2' do
      t = described_class.new
      t.spawn_shape(t.shapes[1])
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'spawns shape 3' do
      t = described_class.new
      t.spawn_shape(t.shapes[2])
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'spawns shape 4' do
      t = described_class.new
      t.spawn_shape(t.shapes[3])
      expect(t.grid).to eq(
        [
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'spawns shape 5' do
      t = described_class.new
      t.spawn_shape(t.shapes[4])
      expect(t.grid).to eq(
        [
          [nil, nil, '@', '@', nil, nil, nil],
          [nil, nil, '@', '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end
  end

  describe '#move_shape_down' do
    it 'moves a shape down' do
      t = described_class.new
      shape = t.shapes[1]
      t.spawn_shape(shape)
      t.move_shape_down(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.move_shape_down(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      t.move_shape_down(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      expect { t.move_shape_down(shape) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '#', nil, nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'moves a shape down besides a bigger one' do
      t = described_class.new
      shape = t.shapes[3]
      t.spawn_shape(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      expect { t.move_shape_down(shape) }.to raise_error(UncaughtThrowError)

      shape = t.shapes[3]
      t.spawn_shape(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      expect { t.move_shape_down(shape) }.to raise_error(UncaughtThrowError)

      shape = t.shapes[4]
      t.spawn_shape(shape)
      t.maybe_move_shape_right(shape)
      t.maybe_move_shape_right(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '@', '@', nil],
          [nil, nil, nil, nil, '@', '@', nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      new_start_index = t.move_shape_down(shape)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, '@', '@', nil],
          [nil, nil, '#', nil, '@', '@', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      expect { t.move_shape_down(shape, shape_start_index: new_start_index) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, '#', '#', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      shape = t.shapes[1]
      t.spawn_shape(shape)
      t.maybe_move_shape_right(shape)
      t.maybe_move_shape_right(shape)
      new_start_index = t.move_shape_down(shape)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      new_start_index = t.move_shape_down(shape, shape_start_index: new_start_index)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, '@', nil],
          [nil, nil, '#', nil, '@', '@', '@'],
          [nil, nil, '#', nil, nil, '@', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      t.maybe_move_shape_right(shape, shape_start_index: new_start_index)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, '@', nil],
          [nil, nil, '#', nil, '@', '@', '@'],
          [nil, nil, '#', nil, nil, '@', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      t.maybe_move_shape_left(shape, shape_start_index: new_start_index, debug: true)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, '@', nil, nil],
          [nil, nil, '#', '@', '@', '@', nil],
          [nil, nil, '#', nil, '@', nil, nil],
          [nil, nil, '#', nil, '#', '#', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_left(shape, shape_start_index: new_start_index, debug: true)
      t.maybe_move_shape_left(shape, shape_start_index: new_start_index, debug: true)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, '@', nil, nil],
          [nil, nil, '#', '@', '@', '@', nil],
          [nil, nil, '#', nil, '@', nil, nil],
          [nil, nil, '#', nil, '#', '#', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_right(shape, shape_start_index: new_start_index, debug: true)
      t.maybe_move_shape_right(shape, shape_start_index: new_start_index, debug: true)
      t.maybe_move_shape_right(shape, shape_start_index: new_start_index, debug: true)
      expect(t.grid).to eq(
        [
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, nil, nil],
          [nil, nil, '#', nil, nil, '@', nil],
          [nil, nil, '#', nil, '@', '@', '@'],
          [nil, nil, '#', nil, nil, '@', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          [nil, nil, '#', nil, '#', '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end
  end

  describe 'detect collision while going down' do
    it 'with the second and third shape' do
      t = described_class.new
      second_shape = t.shapes[1]
      t.spawn_shape(second_shape)
      t.move_shape_down(second_shape)
      t.move_shape_down(second_shape)
      t.move_shape_down(second_shape)
      expect { t.move_shape_down(second_shape) }.to raise_error(UncaughtThrowError)

      third_shape = t.shapes[2]
      t.spawn_shape(third_shape)
      t.move_shape_down(third_shape)
      t.move_shape_down(third_shape)
      t.move_shape_down(third_shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      expect { t.move_shape_down(third_shape) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '#', nil, nil],
          [nil, nil, nil, nil, '#', nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'with the second and third shape, different positions' do
      t = described_class.new
      second_shape = t.shapes[1]
      t.spawn_shape(second_shape)
      t.maybe_move_shape_right(second_shape)
      t.maybe_move_shape_right(second_shape)
      t.move_shape_down(second_shape)
      t.move_shape_down(second_shape)
      t.move_shape_down(second_shape)
      expect { t.move_shape_down(second_shape) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, nil, '#', nil],
          [nil, nil, nil, nil, '#', '#', '#'],
          [nil, nil, nil, nil, nil, '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      third_shape = t.shapes[2]
      t.spawn_shape(third_shape)
      t.move_shape_down(third_shape)
      t.move_shape_down(third_shape)
      t.move_shape_down(third_shape)
      t.move_shape_down(third_shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, '@', '@', '@', '#', nil],
          [nil, nil, nil, nil, '#', '#', '#'],
          [nil, nil, nil, nil, nil, '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]

        ]
      )
      expect { t.move_shape_down(third_shape) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '#', nil, nil],
          [nil, nil, nil, nil, '#', nil, nil],
          [nil, nil, '#', '#', '#', '#', nil],
          [nil, nil, nil, nil, '#', '#', '#'],
          [nil, nil, nil, nil, nil, '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]

        ]
      )

      shape = t.shapes[3]
      t.spawn_shape(shape)
      t.maybe_move_shape_right(shape)
      t.maybe_move_shape_right(shape)
      t.maybe_move_shape_right(shape)
      t.maybe_move_shape_right(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      expect { t.move_shape_down(shape) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, nil, nil, '#'],
          [nil, nil, nil, nil, '#', nil, '#'],
          [nil, nil, nil, nil, '#', nil, '#'],
          [nil, nil, '#', '#', '#', '#', '#'],
          [nil, nil, nil, nil, '#', '#', '#'],
          [nil, nil, nil, nil, nil, '#', nil],
          ["#", "#", "#", "#", "#", "#", "#"]

        ]
      )
    end
  end


  describe '#maybe_move_shape_left' do
    it 'tries to move a shape left' do
      t = described_class.new
      shape = t.shapes[1]
      t.spawn_shape(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_left(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, '@', '@', '@', nil, nil, nil],
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_left(shape)
      expect(t.grid).to eq(
        [
          [nil, '@', nil, nil, nil, nil, nil],
          ['@', '@', '@', nil, nil, nil, nil],
          [nil, '@', nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_left(shape)
      expect(t.grid).to eq(
        [
          [nil, '@', nil, nil, nil, nil, nil],
          ['@', '@', '@', nil, nil, nil, nil],
          [nil, '@', nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end
  end

  describe '#maybe_move_shape_right' do
    it 'tries to move a shape right' do
      t = described_class.new
      shape = t.shapes[1]
      t.spawn_shape(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_right(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, nil, '@', '@', '@', nil],
          [nil, nil, nil, nil, '@', nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_right(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, nil, '@', nil],
          [nil, nil, nil, nil, '@', '@', '@'],
          [nil, nil, nil, nil, nil, '@', nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.maybe_move_shape_right(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, nil, nil, '@', nil],
          [nil, nil, nil, nil, '@', '@', '@'],
          [nil, nil, nil, nil, nil, '@', nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end

    it 'detects collision while moving shape right' do
      t = described_class.new
      shape = t.shapes[1]
      t.spawn_shape(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, '@', '@', '@', nil, nil],
          [nil, nil, nil, '@', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      expect { t.move_shape_down(shape) }.to raise_error(UncaughtThrowError)
      expect(t.grid).to eq(
        [
          [nil, nil, nil, '#', nil, nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      shape = t.shapes[2]
      t.spawn_shape(shape)
      t.maybe_move_shape_left(shape)
      t.maybe_move_shape_left(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      t.move_shape_down(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, '@', nil, nil, nil, nil],
          ['@', '@', '@', '#', nil, nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )

      t.maybe_move_shape_right(shape)
      expect(t.grid).to eq(
        [
          [nil, nil, '@', nil, nil, nil, nil],
          [nil, nil, '@', nil, nil, nil, nil],
          ['@', '@', '@', '#', nil, nil, nil],
          [nil, nil, '#', '#', '#', nil, nil],
          [nil, nil, nil, '#', nil, nil, nil],
          ["#", "#", "#", "#", "#", "#", "#"]
        ]
      )
    end
  end
end
