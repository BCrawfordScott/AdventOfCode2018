require 'byebug'

class NavNode

  attr_reader :child_count, :data_count, :children, :meta_data
  attr_writer :meta_data

  def initialize(data)
    @child_count, @data_count = data[0].to_i, data[1].to_i
    @children = []
    @meta_data = []
  end

end

class NavTree

  attr_reader :root, :node_stream
  attr_writer :node_stream

  def self.parse_stream(file)
    File.readlines(file)[0].split(' ')
  end

  def initialize(file) 
    @node_stream = NavTree.parse_stream(file)
    @root = NavNode.new(get_next_node)
  end

  def get_next_node 
    node_data = node_stream.take(2)
    trim_stream(2)
    node_data 
  end

  def trim_stream(num)
    self.node_stream = node_stream.drop(num)
  end

  def add_children(node)
    until node.children.length == node.child_count
      child_node = NavNode.new(get_next_node)
      add_children(child_node)
      node.children << child_node
    end 

    finish_node(node)
  end

  def finish_node(node)
    node.meta_data = node_stream.take(node.data_count)
    trim_stream(node.data_count)
  end

  def build_tree
    add_children(root)
  end

  def compile_meta_data(node)
    total = node.meta_data.map(&:to_i).reduce(:+) 

    node.children.each do |child|
      total += compile_meta_data(child)
    end

    total
  end

  def analyze
    build_tree
    compile_meta_data(root)
  end

end

p NavTree.new('./input.txt').analyze