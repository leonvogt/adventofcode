require 'pry'
class ElveCalorieCounter
  attr_accessor :total_of_each_elve
  
  def initialize
    @total_of_each_elve = {}
  end

  def fill_the_hash_with_the_calories(calories, elve_index)
    if total_of_each_elve[elve_index].nil?
      total_of_each_elve[elve_index] = calories
    else
      total_of_each_elve[elve_index] = total_of_each_elve[elve_index] + calories
    end
  end

  def calc_the_total_calories_for_each_elve
    current_elve_index = 1
    
    File.readlines('day1_puzzle_1_input.txt').each do |line|
      elve_calorie_list_is_going_on = line.size > 2
      if elve_calorie_list_is_going_on
        fill_the_hash_with_the_calories(line.to_i, current_elve_index)
      else
        current_elve_index += 1
      end
    end

    return total_of_each_elve
  end

  def which_elve_has_the_most_calories?
    king_elve = calc_the_total_calories_for_each_elve.sort_by{|elve, calorie| calorie }.last
    "Elve #{king_elve[0]} has the most calories with #{king_elve[1]} calories"
  end
end

elve_calorie_counter = ElveCalorieCounter.new
puts elve_calorie_counter.which_elve_has_the_most_calories?

