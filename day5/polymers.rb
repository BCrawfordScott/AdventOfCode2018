require 'byebug'

class Polymer

  attr_reader :polymer, :radical

  def self.radical_polymers 
    lower = ('a'..'z').to_a 
    lower.map do |l|
      new(l)
    end 
  end

  def self.shortest_radical(data)
    data.min_by { |k, v| v }
  end

  def self.analyze_radicals
    data = Hash.new
    radical_polymers.each do |poly|
      data[poly.radical] = poly.optimized_analysis
    end

    shortest_radical(data)[1]
  end

  def initialize(radical = '')
    @polymer = File.readlines('./input.txt').map(&:chomp)[0].split('')
    @radical = radical
  end

  def reaction(i)
    2.times do 
      polymer.delete_at(i) 
    end
    # polymer.delete_at(i)
  end

  def analyze
    i = 0
    while i < polymer.length - 1
      j = i + 1
      if polymer[i].downcase == polymer[j].downcase && polymer[i] != polymer[j]
        reaction(i)
        i -= 1 unless i == 0
      else  
        i += 1
      end
    end
  end 
  
  def analyzed_polymer
    analyze
    polymer.join('')
  end

  def analyzed_length 
    analyzed_polymer.length
  end

  def optimized_analysis
    remove_radicals
    analyzed_length
  end
  
  def remove_radicals
  
    @polymer.delete(@radical)
    @polymer.delete(@radical.upcase)
  
  end

end