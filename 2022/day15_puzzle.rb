require 'pry'
class TaxiCabGeometry
  def initialize(row_to_check:)
    @map = {}
    @row_to_check = row_to_check
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

    return unless @row_to_check.between?(start_y, stop_y)

    (start_x..stop_x).each do |no_beacon_x|
      no_beacon_pos = [no_beacon_x, @row_to_check]
      if @map[no_beacon_pos].nil? && shortest_distance(sensor_x, sensor_y, no_beacon_x, @row_to_check) <= distance
        @map[no_beacon_pos] = "no_beacon" 
      end
    end
  end

  def fill_map(input)
    input.each.with_index(1) do |line, index|
      sensor_info, beacon_info = line.split(':')
      
      sensor_x, sensor_y, beacon_x, beacon_y = line.match(/Sensor at x=(?<x>[-\d]+), y=(?<y>[-\d]+): closest beacon is at x=(?<beacon_x>[-\d]+), y=(?<beacon_y>[-\d]+)/).captures.map(&:to_i)

      fill_no_beacon_positions(sensor_x, sensor_y, beacon_x, beacon_y)
      
      @map[[sensor_x, sensor_y]] = 'sensor'
      @map[[beacon_x, beacon_y]] = 'beacon'
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
        else
          print '.'
        end
      end
      puts
    end    
  end

  def puzzle_1(input)
    fill_map(input)
    print_map if @row_to_check <= 10
    @map.select { |key, value| key[1] == @row_to_check && value == "no_beacon" }.size 
  end
end

input = File.read('day15_input.txt').split("\n")
taxi_cab = TaxiCabGeometry.new(row_to_check: 10)
puts "Puzzle 1: #{taxi_cab.puzzle_1(input)}"
