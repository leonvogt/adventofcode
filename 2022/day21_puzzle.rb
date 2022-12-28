require 'pry'
class MonkeyNumberResolver
  def initialize
    @monkeys = {}
  end

  def find_number_for_monkey(monkey_name)
    monkey_number = @monkeys[monkey_name]

    # if number is already resolved
    return monkey_number if monkey_number.to_i.to_s == monkey_number

    monkey_name_1, operator, monkey_name_2 = monkey_number.match(/(\w+) (\+|\-|\/|\*) (\w+)/).captures
    monkey_number_1 = find_number_for_monkey(monkey_name_1)
    monkey_number_2 = find_number_for_monkey(monkey_name_2)
    return eval("#{monkey_number_1} #{operator} #{monkey_number_2}").to_s
  end

  def fill_monkeys(input)
    input.each do |line|
      monkey_name, monkey_number = line.split(':')
      @monkeys[monkey_name] = monkey_number.strip
    end
  end

  def puzzle_1(input)
    fill_monkeys(input)

    @monkeys.each do |monkey_name, monkey_number|
      @monkeys[monkey_name] = find_number_for_monkey(monkey_name)
    end
    return @monkeys['root']
  end
end

input = File.read('day21_input.txt').split("\n")
puts "Part 1: #{MonkeyNumberResolver.new.puzzle_1(input)}"
