def check_if_the_first_elve_pair_contains_the_second(operation)
  "(first_elve_first_section.to_i..first_elve_second_section.to_i).include?(second_elve_first_section.to_i) #{operation} 
   (first_elve_first_section.to_i..first_elve_second_section.to_i).include?(second_elve_second_section.to_i)"
end

def check_if_the_second_elve_pair_contains_the_first(operation)
  "(second_elve_first_section.to_i..second_elve_second_section.to_i).include?(first_elve_first_section.to_i) #{operation} 
   (second_elve_first_section.to_i..second_elve_second_section.to_i).include?(first_elve_second_section.to_i)"
end

def first_puzzle(pairs)
  fully_contains_assignments = 0
  pairs.each do |pair|
    first_elve_first_section, first_elve_second_section, second_elve_first_section, second_elve_second_section = pair.gsub(',', '-').split('-')
    if eval(check_if_the_first_elve_pair_contains_the_second("&&"))
      fully_contains_assignments += 1
      next
    end

    if eval(check_if_the_second_elve_pair_contains_the_first("&&"))
      fully_contains_assignments += 1
    end
  end
  fully_contains_assignments
end

def second_puzzle(pairs)
  fully_contains_assignments = 0
  pairs.each do |pair|
    first_elve_first_section, first_elve_second_section, second_elve_first_section, second_elve_second_section = pair.gsub(',', '-').split('-') 
    if eval(check_if_the_first_elve_pair_contains_the_second("||"))
      fully_contains_assignments += 1
      next
    end

    if eval(check_if_the_second_elve_pair_contains_the_first("||"))
      fully_contains_assignments += 1
    end
  end
  fully_contains_assignments
end

input = File.read('day4_input.txt')
pairs = input.split("\n")

puts first_puzzle(pairs)
puts second_puzzle(pairs)