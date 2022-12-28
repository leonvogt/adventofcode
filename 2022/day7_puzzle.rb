class Directory
  attr_accessor :name, :children, :parent, :sum, :path

  def initialize(name, parent = nil, path = nil)
    @name     = name
    @parent   = parent
    @path     = path
    @sum      = 0
    @children = []
  end
end

class DOS
  attr_accessor :root_dir, :current_dir, :all_directories
  TOTAL_SPACE  = 70_000_000
  NEEDED_SPACE = 30_000_000

  def initialize
    @root_dir        = Directory.new('root', nil, '')
    @current_dir     = root_dir
    @all_directories = {}
  end

  def save_sum_per_directory
    File.read('day7_input.txt').split("\n").each.with_index(1) do |command, index|
      next if index == 1
      if command.include? 'cd ..'
        @current_dir = current_dir.parent
      elsif command.include? 'cd '
        directory_name = command.split('cd ').last
        freshly_entered_dir = Directory.new(directory_name, current_dir, "#{current_dir.path}/#{directory_name}")
        
        # map the new directory as child to the current directory
        current_dir.children << freshly_entered_dir

        # set new current directory
        @current_dir = freshly_entered_dir
      elsif command[0] =~ /[0-9]/
        current_dir.sum += command.split(' ')[0].to_i
      end
    end
  end

  def calc_total_sum(directory, sum = 0)
    directory.children.each do |child|
      sum += calc_total_sum(child)
    end
    sum += directory.sum
  end

  def map_all_directories(directory = root_dir)
    all_directories[directory.path] = calc_total_sum(directory)

    directory.children.each do |child|
      map_all_directories(child)
    end
  end

  def needed_space
    used_space = all_directories[""]
    free_space = DOS::TOTAL_SPACE - used_space
    DOS::NEEDED_SPACE - free_space
  end
end

dos = DOS.new
dos.save_sum_per_directory
dos.map_all_directories

puts "Puzzle 1 #{dos.all_directories.select { |dir, sum| sum <= 100_000 }.sum { |dir, sum| sum }}"
puts "Puzzle 2 #{dos.all_directories.select { |dir, sum| sum >= dos.needed_space }.values.min}"