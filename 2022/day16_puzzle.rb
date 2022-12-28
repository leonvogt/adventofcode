require 'pry'
require 'rspec/autorun'

class ValveOpener
  MAX_MINUTES = 30
  attr_accessor :valves, :current_minute, :current_pressure, :open_valves

  def initialize
    @valves = {}
    @current_minute = 1
    @current_pressure = 0
    @open_valves = []
  end

  def fill_valves(input)
    input.each do |line|
      valve_info, tunnel_info = line.split(';')
      
      valve, flow_rate = valve_info.scan(/Valve ([A-Z]{2}) has flow rate=([\d]+)/).flatten
      leads_to_tunnels = tunnel_info.scan(/[A-Z]{2}/)
      
      @valves[valve] = { flow_rate: flow_rate.to_i, leads_to_tunnels: leads_to_tunnels }
    end
  end

  def move_to_valve(valve)
    @current_minute += 1
  end

  def open_valve(valve)
    @current_minute += 1
    @open_valves << valve
    set_current_pressure(valve)
  end

  def set_current_pressure(valve)
    @current_pressure += @valves[valve][:flow_rate] * (MAX_MINUTES - @current_minute)
  end

  def print_debug_info(action, next_valve)
    case action
    when 'move'
      puts "== Minute #{@current_minute} =="
      if @open_valves.empty?
        puts "No valves are open."
      else
        puts "Valves #{@open_valves.join(', ')} are open"
      end
      puts "You move to valve #{next_valve}."
      puts
    when 'open'
      puts "== Minute #{@current_minute} =="
      if @open_valves.empty?
        puts "No valves are open."
      else
        puts "Valves #{@open_valves.join(', ')} are open"
      end
      puts "You open valve #{next_valve}." 
      puts
    end
  end

  def open_all_valves(current_valve:)
    while @current_minute <= MAX_MINUTES
      next_valve = find_next_biggest_valve(current_valve)
      break if @valves[next_valve].nil?
            
      print_debug_info('move', next_valve)
      move_to_valve(next_valve)
      #next_valve = find_next_biggest_valve(current_val ve)
      print_debug_info('open', next_valve)
      open_valve(next_valve)
      current_valve = next_valve
    end
  end

  # Check the leads_to_tunnels  and calc the flow rate for each of the leads_to_tunnels children
  def find_next_biggest_valve(current_valve, depth = 2)
    possible_valves = {}
    @valves[current_valve][:leads_to_tunnels].each do |valve|
      # go through each of the leads_to_tunnels and all of their leads_to_tunnels
      # sum the flow rate of each of the leads_to_tunnels
      find_next_biggest_valve(valve, depth - 1)

      possible_valves[valve] = @valves[valve][:flow_rate]
      @valves[valve][:leads_to_tunnels].each do |valve_two_away|
        possible_valves[valve] += @valves[valve_two_away][:flow_rate] # 2 because moving to the valve takes 2 minutes
      end
    end
    
    # Remove the valves that are already open or have a flow rate of 0
    possible_valves.reject! { |valve, flow_rate| @open_valves.include?(valve) || flow_rate == 0 }

    # Get the valve with the highest flow rate
    possible_valves.sort_by { |valve, flow_rate| flow_rate }.reverse.first&.first
  end

  def find_best_path(current_valve)
    paths_to_visit  = [[current_valve]]
    valid_paths     = []
    left_minutes    = 10_000_000
    while paths_to_visit.any?
      left_minutes -= 1
      
      current_path = paths_to_visit.shift
      current_valve = @valves[current_path.last]
      
      if current_valve.nil? || left_minutes <= 0 || current_path.size > 19
        break
      end
      max_pressure = 0
      seen_before = []
      current_path.each.with_index(1) do |valve, index|
        if !seen_before.include?(valve)
          seen_before << valve
          minute = MAX_MINUTES - index
          max_pressure += @valves[valve][:flow_rate] * minute
        end
      end
      valid_paths << { path: current_path, max_possible_flow_rate: max_pressure }

      current_valve[:leads_to_tunnels].each do |next_valve|
        paths_to_visit << current_path + [next_valve]
      end
    end
    binding.pry 
    valid_paths.sort_by { |path| path[:max_possible_flow_rate] }.reverse.first[:path]
  end

  def puzzle_1(input)
    #fill_valves(input)
    #open_all_valves(current_valve: @valves.keys.first)
    #find_best_path
    puts "Flow Rage: #{@current_pressure}"
    return @current_pressure
  end
end

#input = File.read('day16_input.txt').split("\n")
#ValveOpener.new.puzzle_1(input)



RSpec.describe ValveOpener do
  let(:input) { ['Valve AA has flow rate=0; tunnels lead to valves DD, II, BB',
                 'Valve BB has flow rate=13; tunnels lead to valves CC, AA',
                 'Valve CC has flow rate=2; tunnels lead to valves DD, BB',
                 'Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE',
                 'Valve EE has flow rate=3; tunnels lead to valves FF, DD',
                 'Valve FF has flow rate=0; tunnels lead to valves EE, GG',
                 'Valve GG has flow rate=0; tunnels lead to valves FF, HH',
                 'Valve HH has flow rate=22; tunnel leads to valve GG',
                 'Valve II has flow rate=0; tunnels lead to valves AA, JJ',
                 'Valve JJ has flow rate=21; tunnel leads to valve II'] }
  
  let(:simplified_input) { 
                ['Valve AA has flow rate=0; tunnels lead to valves DD, BB',
                 'Valve BB has flow rate=13; tunnels lead to valves CC, AA',
                 'Valve CC has flow rate=2; tunnels lead to valves DD, BB',
                 'Valve DD has flow rate=20; tunnels lead to valves CC, AA',] }
  describe '#puzzle_1' do
    it 'returns the correct answer' do
      #expect(described_class.new.puzzle_1(input)).to eq(1651)
    end
  end
  
  describe '#find_best_path' do
    it 'returns all possible path' do
      valve_opener = ValveOpener.new
      valve_opener.fill_valves(input)
      expect(valve_opener.find_best_path('AA')).to eq(["AA", "DD", "CC", "BB", "AA", "II", "JJ", "II", "AA", "DD", "EE", "FF", "GG", "HH", "GG", "FF", "EE", "DD", "CC"])
    end
  end
  # 
  # describe '#find_path' do
  #   valve_opener = ValveOpener.new
  #   valve_opener.fill_valves(input)
  #   it 'returns the correct path' do
  #     expect(valve_opener.find_path).to eq(['AA', 'DD', 'CC', 'BB', 'AA', 'II', 'JJ', 'II', 'AA', 'DD', 'EE', 'FF', 'GG', 'HH', 'GG', 'FF', 'EE', 'DD', 'CC'])
  #   end
  # end

  # describe '#set_current_pressure' do
  #   it 'returns the correct total amount of pressure' do
  #     valve_opener = ValveOpener.new
  #     valve_opener.fill_valves(input)
  #     valve_opener.current_minute = 2
  #     expect(valve_opener.set_current_pressure('BB')).to eq(364)
  #   end
  # end

  # describe '#find_next_biggest_valve' do
  #   valve_opener = ValveOpener.new
  #   valve_opener.fill_valves(input)
    
  #   it 'returns the correct valves' do
  #     expect(valve_opener.find_next_biggest_valve('AA')).to eq('DD')
  #     valve_opener.open_valves << 'DD'

  #     expect(valve_opener.find_next_biggest_valve('DD')).to eq('CC')
  #     valve_opener.open_valves << 'CC'

  #     expect(valve_opener.find_next_biggest_valve('CC')).to eq('BB')
  #   end 
  # end
end