require "pry"

lines = File.readlines(File.dirname(__FILE__) + "/day6_input.txt", chomp: true)
tracked_times = lines[0].scan(/\d+/)
tracked_distances = lines[1].scan(/\d+/)

statistic = {}
tracked_times.length.times { |i| statistic[tracked_times[i]] = tracked_distances[i].to_i }

def win_simulator_9000(hold_time, distance_record)
  number_of_possible_wins = 0
  hold_time.times do |i|
    seconds = i + 1
    rest_time = hold_time.to_i - seconds
    total_distance = rest_time * seconds

    number_of_possible_wins += 1 if total_distance > distance_record
  end
  number_of_possible_wins
end

total_puzzle_1 = tracked_times.map do |tracked_time|
  win_simulator_9000(tracked_time.to_i, statistic[tracked_time])
end

total_puzzle_2 = win_simulator_9000(tracked_times.join.to_i, tracked_distances.join.to_i)

puts "Puzzle 1: #{total_puzzle_1.inject(:*)}"
puts "Puzzle 2: #{total_puzzle_2}"
