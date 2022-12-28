require 'pry'
require 'ruby-progressbar'

class TaxiCabGeometry
  MAX_X = 4000000
  MAX_Y = 4000000

  def initialize
    @map = {}
    @sensors = []
    @no_beacon_positions = {}
  end
  
  # Calcs the shortest distance between two points (TaxiCab Geometry)
  def shortest_distance(x1, y1, x2, y2)
    (x1 - x2).abs + (y1 - y2).abs
  end

  def fill_sensor_info(sensor_x, sensor_y, beacon_x, beacon_y)
    distance = shortest_distance(sensor_x, sensor_y, beacon_x, beacon_y)

    start_x = sensor_x - distance
    stop_x  = sensor_x + distance
    start_y = sensor_y - distance
    stop_y  = sensor_y + distance

    @sensors << { 
                  distance: distance,
                  sensor_x: sensor_x, sensor_y: sensor_y,
                  start_x: start_x, stop_x: stop_x, start_y: start_y, stop_y: stop_y 
                }
  end

  def fill_map(input)
    input.each.with_index(1) do |line, index|
      sensor_info, beacon_info = line.split(':')

      sensor_x, sensor_y, beacon_x, beacon_y = line.match(/Sensor at x=(?<x>[-\d]+), y=(?<y>[-\d]+): closest beacon is at x=(?<beacon_x>[-\d]+), y=(?<beacon_y>[-\d]+)/).captures.map(&:to_i)
      fill_sensor_info(sensor_x, sensor_y, beacon_x, beacon_y)
      @map[[sensor_x, sensor_y]] = 'sensor'
      @map[[beacon_x, beacon_y]] = 'beacon'

    end
  end

  def calc_result
    progressbar = ProgressBar.create(title: "4'000'000 ROWs scannen", total: MAX_Y, format: '%t %p%% %B %a')
    (0..MAX_Y).each do |current_y|
      progressbar.increment
      found = false
      @sensors.select { |sensor| sensor[:start_y] <= current_y && sensor[:stop_y] >= current_y }.each do |sensor|
        start_x = sensor[:start_x] < 0 ? 0 : sensor[:start_x]
        stop_x  = sensor[:stop_x] > MAX_X ? MAX_X : sensor[:stop_x]
        (start_x..stop_x).each do |no_beacon_x|
          no_beacon_pos = [no_beacon_x, current_y]
          if shortest_distance(sensor[:sensor_x], sensor[:sensor_y], no_beacon_x, current_y) <= sensor[:distance]
            #@no_beacon_positions[no_beacon_pos] = true
          end
        end
      end
      if @no_beacon_positions.size != MAX_X + 1
        (0..MAX_X).each do |x|
          if @no_beacon_positions[[x, current_y]].nil?
            puts "X-#{x} Y-#{current_y}"
            return x * 4_000_000 + current_y
          end
        end
      end
      @no_beacon_positions = {}
    end
  end

  def puzzle_2(input)
    fill_map(input)
    calc_result
  end
end

input = File.read('day15_input.txt').split("\n")
puts "Puzzle 2: #{TaxiCabGeometry.new.puzzle_2(input)}"
