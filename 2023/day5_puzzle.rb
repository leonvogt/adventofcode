require "pry"

lines = File.readlines(File.dirname(__FILE__) + "/day5_input.txt", chomp: true)
seeds = lines.shift.split("seeds: ").last.split(" ").map(&:to_i)

@instructions = {}
latest_instruction = nil
lines.reject(&:empty?).each.with_index(1) do |line, index|
  if line.include?("map")
    latest_instruction = line.split(" map:").first
    @instructions[latest_instruction] = {}
    next
  end

  destination_range_start, source_range_start, range_length = line.split(" ").map(&:to_i)
  range_length = range_length.to_i - 1

  source_range_end = source_range_start + range_length
  difference = destination_range_start - source_range_start

  @instructions[latest_instruction][[source_range_start, source_range_end]] = difference
end

def search_instructions(amount, from:, to:)
  instructions = @instructions[[from, to].join("-to-")]
  difference = instructions.find { |instruction| amount.between?(*instruction.first) }&.last
  return amount if difference.nil?
  amount + difference
end

locations = []
seeds.each do |seed|
  amount = search_instructions(seed, from: "seed", to: "soil")
  amount = search_instructions(amount, from: "soil", to: "fertilizer")
  amount = search_instructions(amount, from: "fertilizer", to: "water")
  amount = search_instructions(amount, from: "water", to: "light")
  amount = search_instructions(amount, from: "light", to: "temperature")
  amount = search_instructions(amount, from: "temperature", to: "humidity")
  amount = search_instructions(amount, from: "humidity", to: "location")
  locations << amount
end

puts "Puzzle 1: #{locations.min}"
