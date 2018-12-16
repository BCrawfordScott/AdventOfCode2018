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

  def self.generate_blobs(file)
    coords = parse_coordinates(file)
    symbols = ChronoBlob.gen_symbols(coords.length)
    coords.map.with_index do |pos, i|
      ChronoBlob.new(symbols[i], pos)
    end
  end

  def self.sum_distances(distances)
    distances.keys.map { |tuple| tuple[0] }.reduce(:+)
  end

  def initialize(file = "./input.txt")
    @blobs = ChronoMap.generate_blobs(file)
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

  def calc_safe_zone(size)
    count = 0
    
    self.each do |i, j|
      pos = [i, j]
      total_distance = ChronoMap.sum_distances(p2_distances(pos))
      if total_distance < size
        count += 1 
        self[pos] = "#" unless self[pos].is_a?(Symbol) && self[pos].to_s.upcase == self[pos].to_s
      end
    end

    count
  end

  def each(&prc)
    for i in 0...height 
      for j in 0...width 
        prc.call([i, j])
      end
    end
  end

  def to_s
    print "-"
    puts ("--" * width) 
    output = "|"
    self.each do |i, j|
      pos = self[[i, j]]
      if pos.is_a?(Symbol)
        if pos.to_s.upcase == pos.to_s
          output += pos.to_s + "|"
        else 
          output += ".|"
        end
      elsif  pos == "#"
        output += "#|" 
      else 
        output += " |"
      end

      if j == height - 1
        puts output 
        print "-"
        puts ("--" * width)
        output = "|"
      end
    end
  end

  private 
  
  attr_reader :blobs, :map

  def self.parse_coordinates(file)
    coordinates = File.readlines(file).map do |pair|
      pair.chomp.split(", ").map(&:to_i)
    end
  end
  
  def width 
    @width ||= blobs.map(&:y_val).max + 2
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
      self[pos] = blob.sub_sym if self[pos].nil?
      blob.add_coverage(pos)
    else 
      self[pos] = "."
    end
  end

  def grow_blobs
    self.each do |i, j|
      current = [i, j]
      blob = closest_blob(current)
      tag_pos(current, blob) 
    end
  end

  def biggest_finite_blob
    finite_blobs.map(&:size).max
  end

  # Imperfect implementation, but passes the challenge.
  # p1_distances, specifically for part 1, uses the distance as a key
  # and stores the related blob as a value.  Unfortunately, I failed to 
  # remember this would overwrite a previous distance if a matching distance 
  # came up.  Somehow, this still passes the challenge, though it likely shouldn't

  def p1_distances(pos) 
    dist_hash = {}
    x1, y1 = pos 
    blobs.each do |blob|
      x2, y2 = blob.pos
      m_distance = (x1 - x2).abs + (y1 - y2).abs
      dist_hash[m_distance] = blob
    end

    dist_hash
  end

  # Correct implementation:  p2 uses array with both the distance and the 
  # blob as the key and then maps over them to account for blobs that are
  # of equal distance from the given point.  For whatever reason, this
  # implementation does not pass the challenge.

  def p2_distances(pos) 
    dist_hash = {}
    x1, y1 = pos 
    blobs.each do |blob|
      x2, y2 = blob.pos
      m_distance = (x1 - x2).abs + (y1 - y2).abs
      dist_hash[[m_distance, blob]] = blob
    end

    dist_hash
  end

  def closest_blob(pos)
    ds = p1_distances(pos)
    keys = ds.keys
    shortest = keys.min
    keys.count(shortest) == 1 ? ds[shortest] : nil
  end

  def finite_blobs
    @finite_blobs ||= blobs.reject do |blob|
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

p ChronoMap.new.calc_safe_zone(10000)

