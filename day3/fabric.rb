require 'byebug'

class Swatch 
  ATTRIBUTES = %i(id x y width height).freeze

  def self.build_params(str)
    data = str.tr("#@,:x", " ").split
    params = Hash.new
    for i in (0...data.length)
      params[ATTRIBUTES[i]] = data[i].to_i
    end 

    params
  end

  def self.build_swatches(file_name)
    data = File.readlines(file_name).map(&:chomp)
    data.map { |swatch_data| self.new(build_params(swatch_data))}
  end

  attr_reader :id

  def initialize(params)
    @id = params[:id]
    @x = params[:x]
    @y = params[:y]
    @width = params[:width]
    @height = params[:height]
  end

  def x_range
    (x..x + width - 1)
  end

  def y_range 
    (y..y + height - 1)
  end

  def area 
    width * height 
  end

  private 

  attr_reader :x, :y, :width, :height

end

class Bolt 

  def initialize(dimension)
     @area = Array.new(dimension) { Array.new(dimension) }
  end

  def [](pos)
    row, col = pos 
    area[row][col]
  end

  def []=(pos, val)
    row, col = pos 
    area[row][col] = val
  end

  def elf_overlaps
    overlap(swatches)
  end

  def no_overlaps
    claims, counts = Hash.new, Hash.new(0) 
    
    cross_cut(swatches)
    vals = area.flatten.reject { |inch| inch.nil? || inch == 'x' }
    
    swatches.each { |swatch| claims[swatch.id] = swatch.area }
    vals.each { |val| counts[val] += 1 }

    claims.keys.each do |id|
     return id if counts[id] == claims[id]
    end
  end

  private

  attr_reader :area

  def swatches(file = "./input.txt")
    @swatches ||= Swatch.build_swatches('./input.txt')
  end

  def cut(swatch)
 
    for x in swatch.x_range 
      for y in swatch.y_range 
        pos = [x, y]
        inch = self[pos]
        
        if inch.nil?
          self[pos] = swatch.id
        elsif inch.is_a?(Integer)  
          self[pos] = "x"
        end
      end  
    end 
  end

  def cross_cut(swatches)
    swatches.each do |swatch|
      cut(swatch)
    end
  end

  def overlap(swatches)
    cross_cut(swatches)
    area.flatten.count { |inch| inch == "x" }
  end

end

bolt1 = Bolt.new(1000)
bolt2 = Bolt.new(1000)
p bolt1.elf_overlaps
p bolt2.no_overlaps

