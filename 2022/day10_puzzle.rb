require 'pry'
class MiniComputer
  def initialize
    @x_register       = 1
    @cycle_number     = 1
    @signal_strengths = 0
    @output           = []
  end

  def cycle(arg, do_something = false)
    if [20, 60, 100, 140, 180, 220].include? @cycle_number
      @signal_strengths += @cycle_number * @x_register
    end

    if (@x_register - 1..@x_register + 1).include?((@cycle_number-1) % 40)
      @output << "🎊"
    else
      @output << "🎄"
    end

    if do_something && !arg.nil?
      @x_register += arg.to_i
    end

    @cycle_number += 1
  end

  def puzzle(input)
    input.each.with_index(1) do |line, index|
      command, arg = line.split(' ')
      cycle(arg)
      cycle(arg, true) if command == 'addx'
    end

    puts "Signal strengths: #{@signal_strengths}"
    puts @output.each_slice(40).map(&:join)
  end
end

input = File.read('day10_input.txt').split("\n")
MiniComputer.new.puzzle(input)