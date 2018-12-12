require 'Set'
require 'byebug'

def recalibrate
  changes = File.readlines('./input.txt').map(&:chomp).map(&:to_i)
  changes.reduce(:+)
end

def recalibrate2 
  changes = File.readlines('./input.txt').map(&:chomp).map(&:to_i)
  # changes = [3, 3, 4, -2, -4]
  total = 0
  history = Set.new
  i = 0
  while true 
    # debugger
    i = 0 if i == changes.length
    total += changes[i]
    return total if history.include?(total)
    history.add(total)
    i += 1
  end
end