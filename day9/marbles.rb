# str.tr('A-z;', '').split(' ')
require 'byebug'
Player = Struct.new(:id, :marbles) do
  def score
    marbles.reduce(0) { |acc, el| acc += el }
  end

  def add_marbles(new_marbles)
    marbles.concat(new_marbles)
  end
end

class Marble 

  attr_accessor :prev, :next
  attr_reader :value

  def initialize(val)
    @value = val
    @prev = self 
    @next = self
  end
  
end

class MarbleCircle

  attr_accessor :current_marble

  def initialize(marble)
    @current_marble = Marble.new(marble)
  end

  def insert(marble)
    new_marble = Marble.new(marble)

    new_prev = current_marble.next
    new_next = current_marble.next.next 

    new_prev.next = new_marble 
    new_next.prev = new_marble 

    new_marble.next = new_next 
    new_marble.prev = new_prev

    self.current_marble = new_marble
  end

  def remove(marble)
    old_prev = marble.prev
    old_next = marble.next 

    old_prev.next = old_next  
    old_next.prev = old_prev

    marble.next = nil 
    marble.prev = nil 

    self.current_marble = old_next 
    marble
  end

  def rotate_back
    # debugger
    7.times do 
      self.current_marble = current_marble.prev
    end
  end
  
end

class MarbleGame

  def self.rules(file)
    File.readlines(file)[0].tr('A-z;', '').split(' ').map(&:to_i)
  end

  attr_reader :players, :marbles, :circle, :player_count

  def initialize(file)
    rules = MarbleGame.rules(file)
    @player_count = rules[0]
    @marbles = rules[1]
    @circle = MarbleCircle.new(0)
  end 

  def players
    @players ||= Hash.new { |h, k| h[k] = Player.new(k, [])}
  end

  def play_turn(id)
    result = play_marble(next_marble)
    players[id].add_marbles(result) if result
  end

  def next_marble
    @marble += 1
  end

  def marble
    @marble ||= 0
  end

  def play_marble(marble)
    if marble % 23 == 0 
      new_marbles = []
      new_marbles << marble
      circle.rotate_back
      new_marbles << circle.remove(circle.current_marble).value
      return new_marbles
    else
      circle.insert(marble)
      return nil
    end
  end

  def play
    i = 1
    until marble > marbles
      play_turn(i)
      i = (i + 1) % player_count
    end

    high_score
  end

  def high_score
    players.values.map(&:score).max
  end

end

p MarbleGame.new('./input.txt').play
p MarbleGame.new('./input2.txt').play

