class Polymer

  attr_reader :polymer

  def initialize
    @polymer = File.readlines('./input.txt').map(&:chomp)[0].split('')
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

end