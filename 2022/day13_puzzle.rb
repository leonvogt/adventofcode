# 5142, 5143, 6133 -> too low
require 'pry'
require 'rspec/autorun'
def in_right_order?(left_array, right_array)
  return if left_array.empty? && right_array.empty?
  return true if left_array.empty?
  return false if right_array.empty?

  answer      = false
  left_value  = left_array.shift
  right_value = right_array.shift

  if left_value.is_a?(Array) && right_value.is_a?(Array)
    # If both values are arrays, start the process over
    answer = in_right_order?(left_value, right_value)
  else 
    begin # If both values are integers
      return true  if left_value < right_value
      return false if left_value > right_value
      answer = in_right_order?(left_array, right_array)
    rescue # If at least one of the values is an array
      right  = right_value.is_a?(Array) ? right_value : [right_value]
      left   = left_value.is_a?(Array)  ? left_value  : [left_value]
      answer = in_right_order?(left, right)
    end
  end

  answer.nil? ? in_right_order?(left_array, right_array) : answer
end

def find_first_value(array)
  array.first.is_a?(Array) ? find_first_value(array.first) : array.first || 0
end

input = File.read('day13_input.txt')

right_order = []
input.split("\n\n").each.with_index(1) do |packets, index|
  left, right = packets.split("\n")
  right_order << index if in_right_order?(eval(left), eval(right))
end
puts "Part 1: #{right_order.sum}"

sorted_packets = input.split("\n").reject(&:empty?).map{ |i| eval(i) }.map { |packet| find_first_value(packet) }.sort
additional_indexes_multiplied = (sorted_packets.partition {|i| i < 2 }.first.size + 1) * (sorted_packets.partition {|i| i < 6 }.first.size + 2)
puts "Part 2: #{additional_indexes_multiplied}"


RSpec.describe 'Day13' do
  it 'returns true' do
    left  = [1,1,3,1,1]
    right = [1,1,5,1,1]
    expect(in_right_order?(left, right)).to eq(true)

    left  = [[1], [2,3,4]]
    right = [[1], 4]
    expect(in_right_order?(left, right)).to eq(true)

    left  = [[1], [2,3,4]]
    right = [[1], 4]
    expect(in_right_order?(left, right)).to eq(true)

    left  = [[4,4],4,4]
    right = [[4,4],4,4,4]
    expect(in_right_order?(left, right)).to eq(true)

    left  = []
    right = [3]
    expect(in_right_order?(left, right)).to eq(true)

    left  = [[1,0],[1],[[],4,[],[],[[10],[],0,[10],[]]],[[]],[6,[[3],3,5,[2,8,8,10]],[1],[[10,8,1],4,[5,0],0],3]]
    right = [[[[9,1,3]]]]
    expect(in_right_order?(left, right)).to eq(true)

    left  = [[[[],[10,7,0],[9,3,9],[1,4,9,10]],9,10,7],[[[8,3,9,3],10],[[10],8,[3,1,0],10,[3]],10],[[2,9,[0],2,8]],[[[4,9],5,1],[0],2,7,4]]
    right = [[5,3,3,[]],[],[],[1,3,[5,9,[2,8,10,10,5]]],[[8,10,1,[0],2],9,0]]
    expect(in_right_order?(left, right)).to eq(true)

    left  = [9]
    right = [[8,7,6]]
    expect(in_right_order?(left, right)).to eq(false)
    
    left  = [7,7,7,7]
    right = [7,7,7]
    expect(in_right_order?(left, right)).to eq(false)
   
    left  = [[[]]]
    right = [[]]
    expect(in_right_order?(left, right)).to eq(false)
   
    left  = [1,[2,[3,[4,[5,6,7]]]],8,9]
    right = [1,[2,[3,[4,[5,6,0]]]],8,9]
    expect(in_right_order?(left, right)).to eq(false)
  end
end