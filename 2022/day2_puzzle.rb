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
  def draw?(player1_shape, player2_shape)
    player1_shape == player2_shape
  end

  def player1_wins?(player1_shape, player2_shape)
    SHAPE_WINNING_RULES[player1_shape].to_sym == player2_shape
  end

  def player2_wins?(player1_shape, player2_shape)
    SHAPE_WINNING_RULES[player2_shape].to_sym == player1_shape
  end

  def points_for_puzzle_1(player1_shape_synonym, player2_shape_synonym)
    player1_shape = ROCK_PAPER_SCISSORS[player1_shape_synonym.to_sym].to_sym
    player2_shape = ROCK_PAPER_SCISSORS[player2_shape_synonym.to_sym].to_sym

    if draw?(player1_shape, player2_shape)
      current_points = 3
    elsif player1_wins?(player1_shape, player2_shape)
      current_points = 0
    elsif player2_wins?(player1_shape, player2_shape)
      current_points = 6
    end

    current_points += SHAPE_POINTS[player2_shape]
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

  def player1_wins?(instruction)
    instruction == INSTRUCTION_TO_LOSE
  end
  
  def player2_wins?(instruction)
    instruction == INSTRUCTION_TO_WIN
  end

  def points_for_puzzle_2(player1_shape_synonym, instruction)
    player1_shape = ROCK_PAPER_SCISSORS[player1_shape_synonym.to_sym]

    if draw?(instruction)
      current_points = 3
      player2_shape = player1_shape
    elsif player1_wins?(instruction)
      current_points = 0
      player2_shape = SHAPE_WINNING_RULES[player1_shape.to_sym]
    elsif player2_wins?(instruction)
      current_points = 6
      player2_shape = SHAPE_WINNING_RULES.invert[player1_shape]
    end

    current_points += SHAPE_POINTS[player2_shape.to_sym]
  end

  def calculate_points(puzzle = 'puzzle_2')
    super
  end
end

puts RockPaperScissorCounter1.new.calculate_points
puts RockPaperScissorCounter2.new.calculate_points