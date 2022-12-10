def get_uniq_number(input, size)
  packets = []
  input.split('').each_cons(size) { |chunk| packets.push(chunk) }
  packets.find_index { |packet| packet.uniq.count >= size } + size
end

input = File.read('day6_input.txt')
puts get_uniq_number(input, 4)
puts get_uniq_number(input, 14)