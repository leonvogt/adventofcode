class MonkeyCatcher
  attr_accessor :monkeys, :current_monkey

  def initialize
    @monkeys = {}
  end

  def fill_monkeys(input)
    input.each do |command|
      case command
        when /Monkey/
          @current_monkey = "monkey_#{command.split(' ')[1].to_i}".to_sym
          monkeys[current_monkey] = {}
        when /Starting items/
          monkeys[current_monkey][:items] = command.split(': ')[1].split(', ').map(&:to_i)
        when /Operation/
          monkeys[current_monkey][:operation] = command.split('Operation: new = ')[1]
        when /Test/
          monkeys[current_monkey][:test] = command.split('Test: divisible by ')[1]
        when /If true/
          monkeys[current_monkey][:if_true_throw_to_monkey] = "monkey_#{command.split('monkey ')[1]}".to_sym
        when /If false/
          monkeys[current_monkey][:if_false_throw_to_monkey] = "monkey_#{command.split('monkey ')[1]}".to_sym
      end
    end
  end

  def play_a_round(wory_level)
    common_divisor = monkeys.map { |m, data| data[:test].to_i }.inject(&:*)

    monkeys.each do |monkey, data|
      data[:items].each do |item|
        data[:inspected_items] = (data[:inspected_items] || 0) + 1
        item = eval(data[:operation].gsub('old', item.to_s))
        if wory_level == :low
          item = item / 3 
        else
          item = item % common_divisor
        end
        is_divisible = eval("#{item} % #{data[:test]} == 0")
        if is_divisible
          monkeys[data[:if_true_throw_to_monkey]][:items] << item
        else
          monkeys[data[:if_false_throw_to_monkey]][:items] << item
        end
      end
      data[:items] = [] # remove item from current monkey, as it has been thrown to another monkey
    end
  end

  def puzzle(input, rounds_to_play:, wory_level:)
    fill_monkeys(input)
    rounds_to_play.times do |round|
      play_a_round(wory_level)
    end
  
    monkeys_with_most_inspected_items = monkeys.map { |monkey, data| data[:inspected_items] }.sort.last(2)
    puts "Monkey Business: #{monkeys_with_most_inspected_items.inject(:*)}"
  end
end

input = File.read('day11_input.txt').split("\n")
MonkeyCatcher.new.puzzle(input, rounds_to_play: 20, wory_level: :low)
MonkeyCatcher.new.puzzle(input, rounds_to_play: 10000, wory_level: :high)