class Part
  attr_accessor :x, :y, :next_part
  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Snake
  attr_accessor :parts, :visited_fields

  def initialize
    @visited_fields = {"0-0" => true}
    part_amount     = ARGV[0].to_i
    raise "WRONG Part Amount given! Pass part_amount as param, when calling this script! For example: `ruby day9_puzzle.rb 10`" if part_amount < 1
    
    @parts = Array.new(part_amount) { Part.new(0, 0) }
    @parts.inject do |previous_part, part|
      previous_part.next_part = part
      part
    end
  end
  
  def move(direction, distance)
    distance.times do |i|
      case direction
      when 'U' then parts[0].y += 1;
      when 'D' then parts[0].y -= 1;
      when 'L' then parts[0].x -= 1;
      when 'R' then parts[0].x += 1;
      end

      parts.each do |part|
        move_part(direction, part) if part_need_to_move?(part)
      end
    end
  end

  def move_part(direction, part)
    previous_part = part
    part_to_move  = part.next_part
    return if part_to_move.nil?

    part_to_move.x += 1 if previous_part.x - part_to_move.x >= 1
    part_to_move.y += 1 if previous_part.y - part_to_move.y >= 1
    
    part_to_move.x -= 1 if previous_part.x - part_to_move.x <= -1
    part_to_move.y -= 1 if previous_part.y - part_to_move.y <= -1
    
    # if part_to_move is the last part -> save visited field
    visited_fields["#{part_to_move.x}-#{part_to_move.y}"] = true if part_to_move.next_part.nil?
  end

  def part_need_to_move?(part)
    return true  if part.next_part.nil?
    return false if (-1..1).include?(part.next_part.y - part.y) && (-1..1).include?(part.next_part.x - part.x)
    return true
  end

  def puzzle(input)
    input.each do |line|
      direction, distance = line.split(' ')
      move(direction, distance.to_i)
    end
    puts "Visited fields: #{visited_fields.size}"
  end
end

input = File.read('day9_input.txt').split("\n")
Snake.new.puzzle(input)