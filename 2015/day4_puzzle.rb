require "digest"

PUZZLE_1_PREFIX = "00000"
PUZZLE_2_PREFIX = "000000"
super_secret_key = File.read("day4_input.txt").chomp
addional_key = 0

loop do
  md5_result = Digest::MD5.hexdigest [super_secret_key, addional_key].join
  if md5_result.start_with? PUZZLE_1_PREFIX
    puts "Puzzle 1: #{addional_key}"
  end

  if md5_result.start_with? PUZZLE_2_PREFIX
    puts "Puzzle 2: #{addional_key}"
    break
  end

  addional_key += 1
end
