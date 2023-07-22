# !/usr/bin/env ruby
begin
  require "tty-prompt"
rescue LoadError
  puts "gem tty-prompt is not installed. Please run `gem install tty-prompt`"
  exit
end

class ScriptTemplateGenerator
  def initialize(year, day)
    @year = year
    @day = day
  end

  def create_files!
    system "touch #{puzzle_path}"
    system "touch #{input_path}"
  end

  def populate_files!
    script = <<~SCRIPT
      require "pry"

      File.readlines("day#{@day}_input.txt").each do |line|
        puts line
      end

      puts "Puzzle 1: "
      puts "Puzzle 2: "
    SCRIPT
    system "echo '#{script}' > #{puzzle_path}"
  end

  private

  def puzzle_path
    "#{@year}/day#{@day}_puzzle.rb"
  end

  def input_path
    "#{@year}/day#{@day}_input.txt"
  end
end

existing_years = Dir.glob("*").select { |f| File.directory? f }
choosen_year = TTY::Prompt.new.select("For which year?", existing_years, filter: true)
choosen_day = TTY::Prompt.new.select("For which day?", (1..31).to_a, filter: true, per_page: 20)

generator = ScriptTemplateGenerator.new(choosen_year, choosen_day)
generator.create_files!
generator.populate_files!
