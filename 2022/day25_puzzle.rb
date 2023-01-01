require 'pry'
require 'rspec/autorun'

class SNAFU
  def initialize(number)
    @number = number
  end

  def snafu_digit_to_decimal(digit)
    return digit.to_i if digit.to_i.to_s == digit # if digit is a number
    return -1 if digit == '-'
    return -2 if digit == '='
  end

  def to_i
    @number.split('').reverse.each_with_index.map do |digit, index|
      snafu_digit_to_decimal(digit) * (5 ** index)
    end.sum.to_i
  end
end

class NumberCruncher
  def initialize(input)
    @input = input
  end

  def puzzle_1
    @input.map do |number|
      SNAFU.new(number).to_i
    end.sum
  end
end

input = File.read('day25_input.txt').split("\n")
puts NumberCruncher.new(input).puzzle_1

RSpec.describe SNAFU do
  # Say you have the SNAFU number 2=-01.
    #      # 2 in the 625s place                 ==== (2 times 625)   === 1250
    # plus # = (double-minus) in the 125s place, ==== (-2 times 125)  === -250
    # plus # - (minus) in the 25s place          ==== (-1 times 25)   === -25
    # plus # 0 in the 5s place                   ==== (0 times 5)     === 0
    # plus # 1 in the 1s place                   ==== (1 times 1)     === 1
  # That's 1250 plus -250 plus -25 plus 0 plus 1 equals 976"
  it 'converts 2=-01 to decimal' do
    expect(SNAFU.new("2=-01").to_i).to eq(976)
  end

  it 'converts 1=-0-2 to decimal' do
    expect(SNAFU.new("1=-0-2").to_i).to eq(1747)
  end
end

RSpec.describe Numeric do
  #      Decimal          SNAFU
  #         1              1
  #         2              2
  #         3             1=
  #         4             1-
  #         5             10
  #         6             11
  #         7             12
  #         8             2=
  #         9             2-
  #        10             20
  #        15            1=0
  #        20            1-0
  #      2022         1=11-2
  #     12345        1-0---0
  # 314159265  1121-1110-1=0

  # it 'converts 8 to a SNAFU number' do
  #   expect(8.to_snafu).to eq('2=')
  # end

  # it 'converts 10 to a SNAFU number' do
  #   expect(10.to_snafu).to eq('20')
  # end

  # it 'converts 10 to a SNAFU number' do
  #   expect(15.to_snafu).to eq('1=0')
  # end

  # it 'converts 10 to a SNAFU number' do
  #   expect(20.to_snafu).to eq('1-0')
  # end

  # it 'converts 2022 to a SNAFU number' do
  #   expect(2022.to_snafu).to eq('1=11-2')
  # end

  # it 'converts 976 to a SNAFU number' do
  #   expect(4890.to_snafu).to eq('2=-01')
  # end

  # it 'converts 4890 to a SNAFU number' do
  #   expect(4890.to_snafu).to eq('2=-1=0')
  # end
end
