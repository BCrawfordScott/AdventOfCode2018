require 'byebug'

class ChronoBlob
  SYMBOLS = ("A".."Z").to_a.freeze

  attr_reader :sym, :coverage

  def self.gen_symbols(num)
    syms = []
    for i in 0...num 
      multi = i/26
      sym = SYMBOLS[i%26]
      multi.times { sym += sym }
      syms << sym.to_sym
    end
    syms
  end

  def initialize(sym, pos)
    @sym = sym
    @pos = pos
    @coverage = []
  end

  def x_val 
    pos[0]
  end

  def y_val 
    pos[1]
  end

  def pos
    @pos.dup
  end

  def sub_sym
    sym.to_s.downcase.to_sym
  end

  def size
    coverage.length 
  end 

  def add_coverage(pos)
    coverage << pos
  end

end

class ChronoMap

  def self.generate_blobs
    coords = parse_coordinates
    symbols = ChronoBlob.gen_symbols(coords.length)
    coords.map.with_index do |pos, i|
      ChronoBlob.new(symbols[i], pos)
    end
  end

  def initialize 
    @blobs = ChronoMap.generate_blobs
    @map = Array.new(height) { Array.new(width)}
    populate_blobs
  end

  def [](pos)
    x, y = pos 
    @map[x][y]
  end

  def []=(pos, val)
    x, y = pos 
    @map[x][y]= val
  end

  def analyze_blobs
    grow_blobs 
    biggest_finite_blob
  end

  private 
  
  attr_reader :blobs, :map

  def self.parse_coordinates(file = './input.txt')
    coordinates = File.readlines(file).map do |pair|
      pair.chomp.split(", ").map(&:to_i)
    end
  end
  
  def width 
    @width ||= blobs.map(&:y_val).max + 1
  end

  def height
    @height ||= blobs.map(&:x_val).max + 1
  end

  def populate_blobs
    @blobs.each do |blob|
      self[blob.pos] = blob.sym
    end
  end

  def tag_pos(pos, blob)
    if blob 
      self[pos] = blob.sub_sym
      blob.add_coverage(pos)
    else 
      self[pos] = "."
    end
  end

  def grow_blobs
    for i in 0...height 
      for j in 0...width 
        current = [i, j]
        blob = closest_blob(current)
        tag_pos(current, blob) 
      end 
    end
  end

  def biggest_finite_blob
    trim_infinite_blobs.map(&:size).max
  end

  def closest_blob(pos)
    distances = {}
    x1, y1 = pos 
    blobs.each do |blob|
      x2, y2 = blob.pos
      m_distance = (x1 - x2).abs + (y1 - y2).abs
      distances[m_distance] = blob
    end

    shortest = distances.keys.min
    distances.count(shortest == 1) ? distances[shortest] : nil
  end

  def trim_infinite_blobs
    blobs.reject do |blob|
      blobx, bloby = blob.pos
      x_coverage = blob.coverage.map { |pos| pos[0] }
      y_coverage = blob.coverage.map { |pos| pos [1] }

      blobx == 0 || bloby == 0 ||
      blobx == height || bloby == width ||
      x_coverage.include?(0) || 
      x_coverage.include?(height) || 
      y_coverage.include?(0) || 
      y_coverage.include?(width)
    end
  end

end

p ChronoMap.new.analyze_blobs
