total_paper, total_ribbon = 0, 0
File.read("day2_input.txt").each_line do |line|
  dimensions = line.split("x").map(&:to_i) # [2, 3, 4]
  length, width, height = dimensions
  surfaces = [width * length, width * height, height * length]

  total_paper += 2 * surfaces.sum
  total_paper += surfaces.min

  total_ribbon += dimensions.sort[0..1].sum * 2
  total_ribbon += dimensions.reduce(:*)
end

puts "Puzzle 1: #{total_paper}"
puts "Puzzle 2: #{total_ribbon}"
