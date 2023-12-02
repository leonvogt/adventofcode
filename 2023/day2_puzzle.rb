require "pry"

class GameRound
  attr_accessor :blue_dice_played, :red_dice_played, :green_dice_played

  DICE_RESTRICTION = {
    "blue" => 14,
    "red" => 12,
    "green" => 13
  }

  def initialize
    @blue_dice_played = 0
    @red_dice_played = 0
    @green_dice_played = 0
  end

  def passes_restrictions?
    @blue_dice_played <= DICE_RESTRICTION["blue"] &&
    @red_dice_played <= DICE_RESTRICTION["red"] &&
    @green_dice_played <= DICE_RESTRICTION["green"]
  end
end

class Game
  attr_accessor :id, :rounds

  def initialize(id = 0, rounds = [])
    @id = id
    @rounds = rounds
  end

  def would_have_been_possible?
    @rounds.all? { |round| round.passes_restrictions? }
  end

  def power
    [
      rounds.map(&:blue_dice_played).max,
      rounds.map(&:red_dice_played).max,
      rounds.map(&:green_dice_played).max
    ].inject(:*)
  end
end

played_games = []
File.readlines("day2_input.txt").each do |line|
  game_id = line.match(/Game (\d+):/).captures.map(&:to_i).first
  game = Game.new(game_id)

  line.split(";").each do |game_round_data|
    game_round = GameRound.new
    game_round_data.scan(/(\d+) (blue|red|green)/).each do |dice_data|
      dice_name = dice_data.last
      dice_amount = dice_data.first.to_i
      game_round.send("#{dice_name}_dice_played=", dice_amount)
    end

    game.rounds << game_round
  end

  played_games << game
end

puts "Puzzle 1: #{played_games.select(&:would_have_been_possible?).map(&:id).sum}"
puts "Puzzle 2: #{played_games.map(&:power).sum}"
