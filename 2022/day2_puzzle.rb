require 'pry'
class RockPaperScissors 
  ROCK_PAPER_SCISSORS = {
    'A': 'rock',
    'X': 'rock',
    'B': 'paper',
    'Y': 'paper',
    'C': 'scissors',
    'Z': 'scissors'
  }

  SHAPE_WINNING_RULES = {
    'rock': 'scissors',
    'scissors': 'paper',
    'paper': 'rock'
  }

  SHAPE_POINTS = {
    'rock': 1,
    'paper': 2,
    'scissors': 3
  }

  def calculate_points(puzzle = 'puzzle_1')
    total_points = 0
    File.readlines('day2_input.txt').each do |line|
      points = line.split(' ')
      total_points += __send__("points_for_#{puzzle}", points.first, points.last)
    end
    total_points
  end
end

class RockPaperScissorCounter1 < RockPaperScissors
  def draw?(palyer_1_shape, palyer_2_shape)
    palyer_1_shape == palyer_2_shape
  end

  def palyer_1_wins?(palyer_1_shape, palyer_2_shape)
    SHAPE_WINNING_RULES[palyer_1_shape].to_sym == palyer_2_shape
  end

  def palyer_2_wins?(palyer_1_shape, palyer_2_shape)
    SHAPE_WINNING_RULES[palyer_2_shape].to_sym == palyer_1_shape
  end

  def points_for_puzzle_1(palyer_1_shape_synonym, palyer_2_shape_synonym)
    palyer_1_shape = ROCK_PAPER_SCISSORS[palyer_1_shape_synonym.to_sym].to_sym
    palyer_2_shape = ROCK_PAPER_SCISSORS[palyer_2_shape_synonym.to_sym].to_sym

    if draw?(palyer_1_shape, palyer_2_shape)
      current_points = 3
    elsif palyer_1_wins?(palyer_1_shape, palyer_2_shape)
      current_points = 0
    elsif palyer_2_wins?(palyer_1_shape, palyer_2_shape)
      current_points = 6
    end

    current_points += SHAPE_POINTS[palyer_2_shape]
  end

  def calculate_points(puzzle = 'puzzle_1')
    super
  end
end

class RockPaperScissorCounter2 < RockPaperScissors
  INSTRUCTION_TO_LOSE = "X"
  INSTRUCTION_TO_DRAW = "Y"
  INSTRUCTION_TO_WIN  = "Z"
  
  def draw?(instruction)
    instruction == INSTRUCTION_TO_DRAW
  end

  def palyer_1_wins?(instruction)
    instruction == INSTRUCTION_TO_LOSE
  end
  
  def palyer_2_wins?(instruction)
    instruction == INSTRUCTION_TO_WIN
  end

  def points_for_puzzle_2(palyer_1_shape_synonym, instruction)
    palyer_1_shape = ROCK_PAPER_SCISSORS[palyer_1_shape_synonym.to_sym]

    if draw?(instruction)
      current_points = 3
      palyer_2_shape = palyer_1_shape
    elsif palyer_1_wins?(instruction)
      current_points = 0
      palyer_2_shape = SHAPE_WINNING_RULES[palyer_1_shape.to_sym]
    elsif palyer_2_wins?(instruction)
      current_points = 6
      palyer_2_shape = SHAPE_WINNING_RULES.invert[palyer_1_shape]
    end

    current_points += SHAPE_POINTS[palyer_2_shape.to_sym]
  end

  def calculate_points(puzzle = 'puzzle_2')
    super
  end
end

puts RockPaperScissorCounter1.new.calculate_points
puts RockPaperScissorCounter2.new.calculate_points