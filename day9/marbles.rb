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

class MarbleGame

  def self.rules(file)
    File.readlines(file)[0].tr('A-z;', '').split(' ').map(&:to_i)
  end

  def self.build_players(num)
    players_hash = Hash.new { |h, k| h[k] = Player.new(k, [])}

    for i in (1..num)
      players_hash[i]
    end 

    players_hash
  end

  def self.build_marbles(num)
    @original_marbles ||= (0..num).to_a
    @original_marbles.dup
  end

  attr_reader :players, :marbles, :current_marble, :circle
  attr_writer :marbles, :current_marble, :circle

  def initialize(file)
    rules = MarbleGame.rules(file)
    @players = MarbleGame.build_players(rules[0])
    @marbles = MarbleGame.build_marbles(rules[1])
    @current_marble = [next_marble, 0]
    @circle = [current_marble[0]]
  end 

  def player_ids
    @player_ids ||= players.keys
  end

  def play_turn(id)
    current_player = players[id]
    result = play_marble(next_marble)
    current_player.add_marbles(result)
  end

  def next_marble
    @marbles.shift
  end

  def play_marble(marble)
    new_marbles = []
    if marble % 23 == 0 
      idx = (current_marble[1] - 7)
      next_idx = idx < 0 ? circle.length + idx : idx
      new_marbles += [marble, circle.delete_at(next_idx)]
      self.current_marble = [circle[next_idx], next_idx]
    else
      next_idx = (current_marble[1] + 2) % circle.length
      self.circle = circle.take(next_idx) + [marble] + circle.drop(next_idx)
      self.current_marble = [marble, next_idx]
    end

    new_marbles
  end

  def play
    i = 1
    total_players = player_ids.length
    until marbles.empty?
      play_turn(i)
      i = (i + 1) % total_players
    end

    high_score
  end

  def high_score
    players.values.map(&:score).max
  end

end

p MarbleGame.new('./input.txt').play

