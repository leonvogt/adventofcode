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

  def fill_no_beacon_positions(sensor)
    sensor_x, sensor_y = @map[sensor][:coords]
    beacon_x, beacon_y = @map[sensor][:sees_beacon]

    distance = shortest_distance(sensor_x, sensor_y, beacon_x, beacon_y)
    
    @map[sensor][:top_corner] = [sensor_x, sensor_y - distance]
    @map[sensor][:bottom_corner] = [sensor_x, sensor_y + distance]
    @map[sensor][:right_corner] = [sensor_x + distance, sensor_y]
    @map[sensor][:left_corner] = [sensor_x - distance, sensor_y]
  end

  def check_if_four_points_are_parallel?(point1, point2, point3, point4)
    (point2[1] - point1[1]) * (point4[0] - point3[0]) == (point4[1] - point3[1]) * (point2[0] - point1[0])
  end

  def fill_map(input)
    input.each.with_index(1) do |line, index|
      sensor_info, beacon_info = line.split(':')
      sensor_x, sensor_y, beacon_x, beacon_y = line.match(/Sensor at x=(?<x>[-\d]+), y=(?<y>[-\d]+): closest beacon is at x=(?<beacon_x>[-\d]+), y=(?<beacon_y>[-\d]+)/).captures.map(&:to_i)
  
      @map["sensor_#{index}"] = { coords: [sensor_x, sensor_y], sees_beacon: [beacon_x, beacon_y] }    
      
      fill_no_beacon_positions("sensor_#{index}")
    end
  end

  def ranges_overlap?(range_a, range_b)
    range_b.begin <= range_a.end && range_a.begin <= range_b.end 
  end 

  def get_overlapping_range(range_a, range_b)
    [range_a.begin, range_b.begin].max..[range_a.end, range_b.end].min
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

        # create a line from each corner
        line_start = top_corner
        line_end = right_corner
        line_start2 = top_corner2
        line_end2 = right_corner2

        # check if the lines are parallel
        if check_if_four_points_are_parallel?(line_start, line_end, line_start2, line_end2)
          # check if the lines overlap
          x_range = get_overlapping_range((line_start[0]..line_end[0]), (line_start2[0]..line_end2[0]))
          y_range = get_overlapping_range((line_start[1]..line_end[1]), (line_start2[1]..line_end2[1]))

          if ranges_overlap?(x_range, y_range)
            # check if lines have a distance of 1
            if shortest_distance(line_start[0], line_start[1], line_start2[0], line_start2[1]) == 1
              parallel_lines << [line_start, line_end, line_start2, line_end2]
            end
          end
        end

        line_start = right_corner
        line_end = bottom_corner
        line_start2 = right_corner2
        line_end2 = bottom_corner2
        if check_if_four_points_are_parallel?(line_start, line_end, line_start2, line_end2)
          # check if the lines overlap
          x_range = get_overlapping_range((line_start[0]..line_end[0]), (line_start2[0]..line_end2[0]))
          y_range = get_overlapping_range((line_start[1]..line_end[1]), (line_start2[1]..line_end2[1]))

          if ranges_overlap?(x_range, y_range)
            # check if lines have a distance of 1
            if shortest_distance(line_start[0], line_start[1], line_start2[0], line_start2[1]) == 1
              parallel_lines << [line_start, line_end, line_start2, line_end2]
            end
          end
        end

        line_start = bottom_corner
        line_end = left_corner
        line_start2 = bottom_corner2
        line_end2 = left_corner2
        if check_if_four_points_are_parallel?(line_start, line_end, line_start2, line_end2)
          # check if the lines overlap
          x_range = get_overlapping_range((line_start[0]..line_end[0]), (line_start2[0]..line_end2[0]))
          y_range = get_overlapping_range((line_start[1]..line_end[1]), (line_start2[1]..line_end2[1]))

          if ranges_overlap?(x_range, y_range)
            # check if lines have a distance of 1
            if shortest_distance(line_start[0], line_start[1], line_start2[0], line_start2[1]) == 1
              parallel_lines << [line_start, line_end, line_start2, line_end2]
            end
          end
        end
      end
    end
    puts parallel_lines.uniq.inspect
  end

  def puzzle_2(input)
    fill_map(input)
    find_parallel_lines
  end
end

input = File.read('day15_input.txt').split("\n")
puts "Puzzle 2: #{TaxiCabGeometry.new.puzzle_2(input)}"
