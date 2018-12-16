require 'byebug'

class StepNode
  include Comparable

  def self.parse_instructions(file)
    steps = File.readlines(file)
    steps.map { |step| step.tr('^A-Z', '').split('').drop(1) }
  end

  def self.node_hash
    Hash.new { |h, k| h[k] = self.new(k) }
  end

  def self.build_step_graph(file)
    graph_map = node_hash
    steps = parse_instructions(file)

    steps.each do |par, ch|
      parent = graph_map[par]
      child = graph_map[ch]
      parent.add_child(child)
    end 

    graph_map
  end

  attr_reader :letter, :parents, :children, :time_left

  def initialize(letter)
    @letter = letter
    @parents = []
    @children = []
    @time_left = 60 + letter.ord % 64
    @done = false
    @assigned = false
  end

  def ready?
    parents.empty? || parents.all?(&:done?)
  end

  def done?
    @done || time_left <= 0
  end

  def add_child(node)
    node.parents << self 
    self.children << node
  end

  def progress
    @time_left -= 1
  end

  def execute
    @done = true
  end

  def <=>(node)
    self.letter <=> node.letter
  end 

  def inspect 
    print "Step #{letter} with #{time_left} seconds left."
  end
end

class StepQueue

  attr_reader :queue, :step_order, :graph_map

  def initialize(file)
    @graph_map = StepNode.build_step_graph(file)
    @queue = step_nodes.select(&:ready?).sort
    @step_order = []
  end

  def step_nodes
    graph_map.values
  end

  def execute_step(step)
    step.execute
    step_order << step.letter
    queue.concat(step.children.select(&:ready?))
    queue.sort!
  end

  def finish_step(step)
    step.execute
    queue.delete(step)
    step.children.each do |child|
      queue << child unless queue.include?(child) || child.done?
    end
    queue.sort!
  end

  def build_step_order
    until queue.empty?
      step = queue.shift 
      execute_step(step)
    end

    step_order.join
  end
end

class Worker

  attr_accessor :task

  def initialize
    @task = nil
  end

  def work 
    task.progress unless task.nil?
  end

  def idle
    task.nil? || task.done?
  end

  def busy? 
    !idle
  end

end

class Staff 

  attr_reader :staff, :job, :assignments
  attr_accessor :time_elapsed
  
  def initialize(num, steps)
    @staff = Array.new(num) { Worker.new }
    @job = StepQueue.new(steps)
    @assignments = {} 
    @time_elapsed = 0
  end

  def assign_work(task)
    worker = staff.find(&:idle)
    if worker
      worker.task = task 
      assignments[task.letter] = worker
    end
  end

  def next_task
    job.queue.find { |task| !assignee(task) && task.ready? } 
  end

  def finish_tasks
    finished = staff.select { |worker| worker.task && worker.task.done? }
    finished.each { |worker| job.finish_step(worker.task)}
  end

  def assignee(task)
    assignments[task.letter]
  end

  def do_job
    until job.queue.empty?
      on_deck = next_task
      until staff.all?(&:busy?) || !on_deck
        assign_work(on_deck)
        on_deck = next_task
      end

      staff.each(&:work)
      self.time_elapsed += 1
      puts time_elapsed
      finish_tasks
    end

    puts "Job finished in #{time_elapsed} seconds"
  end

end

sq = StepQueue.new('./input.txt')
p sq.build_step_order

staff = Staff.new(5, './input.txt')
staff.do_job

