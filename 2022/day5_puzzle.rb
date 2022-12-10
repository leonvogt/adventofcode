def fill_arrays_for(input)
  box_array, mapping_array = [], []
  amount_of_boxes = input.first.split('  ').size
  intital_counter = -3
  amount_of_boxes.times do |index|
    intital_counter += 4
    box_array       << []
    mapping_array   << intital_counter
  end

  return box_array, mapping_array
end

def puzzle(input, box_to_move_command)
  box_array, mapping_array = fill_arrays_for(input)
  
  input.each do |line|
    if line.include?('[')
      mapping_array.each_with_index do |mapping, index|
        box_naming = line[mapping]
        box_array[index].push(box_naming) if !box_naming.strip.empty?
      end
    elsif line.include?('move')
      amount, from, to  = line.scan(/\d+/).map(&:to_i)
      box_from          = box_array[from - 1]
      box_to            = box_array[to - 1]

      boxes_to_move     = box_from.shift(amount)
      box_array[to - 1] = boxes_to_move.send(box_to_move_command).concat(box_to)
    end
  end

  box_array.map { |box| box[0] }.join('')
end


input = File.read('day5_input.txt').split("\n")

puts "Puzzle 1 => #{puzzle(input, 'reverse')}" # CrateMover 9000 kehrt die Boxen um
puts "Puzzle 2 => #{puzzle(input, 'flatten')}" # CrateMover 9001 ist stärker und muss die Boxen nicht umkehren