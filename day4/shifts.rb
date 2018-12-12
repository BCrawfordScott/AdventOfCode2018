require 'Time'
require 'byebug'

class Guard

  attr_reader :sleeptime, :id, :sleep_schedule

  def initialize(id)
    @id = id  
    @sleeptime = 0
    @sleep_schedule = Hash.new(0)
  end 

  def add_sleep(start_time, end_time)
    new_sleep = (end_time - start_time)/60
    @sleeptime += new_sleep
    update_mins((start_time...end_time))
  end

  def update_mins(time_range)
    current_time = time_range.first
    until current_time == time_range.last
      @sleep_schedule[current_time.min] += 1 if current_time.hour == 0
      current_time += 60
    end
  end

  def sleepiest_min
    @sleep_schedule.max_by { |k, v| v }[0]
  end

end

class Journal

  def self.parse_entry(entry)
    entry.tr("[", "").split("]")
  end

  def insert_entries(file = "./input.txt")
    data = File.readlines(file).map(&:chomp)
    data.each do |entry|
      parsed = Journal.parse_entry(entry)
      date = Time.parse(parsed[0])
      @journal[date] = parsed[1]
    end
  end

  def initialize
    @journal = Hash.new
    insert_entries
  end

  def dates
    @dates ||= @journal.keys.sort
  end

  def [](date)
    @journal[date]
  end

end

class SleepLedger

  attr_reader :ledger

  def initialize 
    @ledger = Hash.new { |h, k| h[k] = Guard.new(k) }
  end

  def journal
    @journal ||= Journal.new
  end

  def record_sleep
    for i in 0...journal.dates.length
      date = journal.dates[i]
      case journal[date].split(" ")[0]
      when "Guard"
        @current_id = journal[date].split(" ")[1].tr("#", "").to_i
      when "falls"
        @fall_time = date 
      when "wakes"
        ledger[@current_id].add_sleep(@fall_time, date)
      end
    end
  end

  def choose_guard
    record_sleep 
    ledger.max_by { |k, v| v.sleeptime }[1]
  end

  def sleepy_multiply
    sleepiest = choose_guard
    sleepiest.sleepiest_min * sleepiest.id
  end

  def guards 
    ledger.values
  end

  def most_regular_sleeper 
    record_sleep 
    sleepiest_time = nil
    guards.each do |guard|
      min = guard.sleep_schedule.max_by { |k, v| v }
      
      if sleepiest_time.nil? || sleepiest_time[1][1] < min[1]
        sleepiest_time = [guard.id, min]
      end 
    end
    
    sleepiest_time[0] * sleepiest_time[1][0]
  end
  
end

s1 = SleepLedger.new
p s1.sleepy_multiply
s2 = SleepLedger.new
p s2.most_regular_sleeper