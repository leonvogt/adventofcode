require 'pry'
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

class TaxiCabGeometry
  MAX_X = 4000000
  MAX_Y = 4000000

  def initialize
    @map = {}
    @no_beacon_positions = []
  end
  
  # Calcs the shortest distance between two points (TaxiCab Geometry)
  def shortest_distance(x1, y1, x2, y2)
    (x1 - x2).abs + (y1 - y2).abs
  end

  def fill_no_beacon_positions(sensor_x, sensor_y, beacon_x, beacon_y)
    distance = shortest_distance(sensor_x, sensor_y, beacon_x, beacon_y)

    start_x = sensor_x - distance
    stop_x  = sensor_x + distance
    start_y = sensor_y - distance
    stop_y  = sensor_y + distance
    
    # bottom_corner = [sensor_x, sensor_y + distance]
    # top_corner    = [sensor_x, sensor_y - distance]
    # right_corner  = [sensor_x + distance, sensor_y]
    # left_corner   = [sensor_x - distance, sensor_y]
    
    # @map[sensor][:top_corner] = top_corner
    # @map[sensor][:bottom_corner] = bottom_corner
    # @map[sensor][:right_corner] = right_corner
    # @map[sensor][:left_corner] = left_corner

    (start_x..stop_x).each do |no_beacon_x|
      (start_y..stop_y).each do |no_beacon_y|
        no_beacon_pos = [no_beacon_x, no_beacon_y]
        if @map[no_beacon_pos].nil? && shortest_distance(sensor_x, sensor_y, no_beacon_x, no_beacon_y) <= distance
          @no_beacon_positions << no_beacon_pos
        end
      end
    end

    # fill line from top corner to right corner
    # y = top_corner[1]
    # (top_corner[0] + 1..right_corner[0]).each do |x|
    #   @map[[x, y += 1]] = 'border'
    # end

    # # fill line from right corner to bottom corner
    # x = right_corner[0]
    # (right_corner[1] + 1..bottom_corner[1]).each do |y|
    #   @map[[x -= 1, y]] = 'border'
    # end

    # # fill line from left corner to bottom corner
    # x = left_corner[0]
    # (left_corner[1] + 1..bottom_corner[1]).each do |y|
    #   @map[[x += 1, y]] = 'border'
    # end

    # # fill line from left corner to top corner
    # y = left_corner[1]
    # (left_corner[0] + 1..top_corner[0]).each do |x|
    #   @map[[x, y -= 1]] = 'border'
    # end
  end

  def check_if_four_points_are_parallel?(point1, point2, point3, point4)
    (point2[1] - point1[1]) * (point4[0] - point3[0]) == (point4[1] - point3[1]) * (point2[0] - point1[0])
  end

  def fill_map(input)
    input.each.with_index(1) do |line, index|
      puts "Processing line #{index}"
      time_start = Time.now
      sensor_info, beacon_info = line.split(':')
      sensor_x, sensor_y, beacon_x, beacon_y = line.match(/Sensor at x=(?<x>[-\d]+), y=(?<y>[-\d]+): closest beacon is at x=(?<beacon_x>[-\d]+), y=(?<beacon_y>[-\d]+)/).captures.map(&:to_i)
  
      #@map["sensor_#{index}"] = { coords: [sensor_x, sensor_y], sees_beacon: [beacon_x, beacon_y] }    
      
      #if sensor_x == 8 && sensor_y == 7
      fill_no_beacon_positions(sensor_x, sensor_y, beacon_x, beacon_y)
      #end

      @map[[sensor_x, sensor_y]] = 'sensor'
      @map[[beacon_x, beacon_y]] = 'beacon'

      puts "FINISH with line #{index} in #{Time.now - time_start} seconds"
    end
  end

  def print_map
    max_x = @map.keys.map(&:first).max
    max_y = @map.keys.map(&:last).max
    min_x = @map.keys.map(&:first).min
    min_y = @map.keys.map(&:last).min
    (min_y..max_y).each do |y|
      if y < 0
        print " #{y} " 
      elsif y >= 10
        print " #{y} "
      else
        print "  #{y} "
      end
      (min_x..max_x).each do |x|
        if @map[[x, y]] == 'sensor'
          print 'S'
        elsif @map[[x, y]] == 'beacon'
          print 'B'
        elsif @map[[x, y]] == 'no_beacon'
          print '#'
        elsif @map[[x, y]] == 'border'
          print Colorize.red('@')
        elsif @map[[x, y]]&.match(/corner/)
          print Colorize.blue('@')
        else
          print '.'
        end
      end
      puts
    end    
  end

  def find_parallel_lines
    parallel_lines = []
    @map.each do |sensor, values|
      top_corner    = values[:top_corner]
      right_corner  = values[:right_corner]
      left_corner   = values[:left_corner]
      bottom_corner = values[:bottom_corner]

      @map.each do |sensor2, values2|
        next if sensor == sensor2
        top_corner2    = values2[:top_corner]
        right_corner2  = values2[:right_corner]
        left_corner2   = values2[:left_corner]
        bottom_corner2 = values2[:bottom_corner]

        #if check_if_four_points_are_parallel?(top_corner, right_corner, left_corner2, bottom_corner2)
          # check if the two lines are one point away from each other
        #end
      end
    end
    puts parallel_lines.uniq.inspect
  end

  def puzzle_2(input)
    fill_map(input)
    (0..MAX_Y).each do |y|
      (0..MAX_X).each do |x|
        if @no_beacon_positions.index([x, y]).nil?
          puts "X-#{x} Y-#{y}"
          return x * 4_000_000 + y
        end
      end
    end
    #print_map
    #@map.select { |key, value| key[1] == @row_to_check && value == "no_beacon" }.size 
    # top = @map.select { |key, value| value == "top_corner" }.keys[0]
    # right = @map.select { |key, value| value == "right_corner" }.keys[0]
    # left = @map.select { |key, value| value == "left_corner" }.keys[0]
    # bottom = @map.select { |key, value| value == "bottom_corner" }.keys[0]
    #find_parallel_lines
    #check_if_four_points_are_parallel?(top, right, bottom, left)
  end
end

input = File.read('day15_input.txt').split("\n")
puts "Puzzle 2: #{TaxiCabGeometry.new.puzzle_2(input)}"
