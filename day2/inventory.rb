def box_id_checksum
  box_ids = File.readlines('./input.txt').map(&:chomp)
  three_count = 0 
  two_count = 0

  box_ids.each do |box|
    letter_count = Hash.new(0)
    box.chars.each do |char|
      letter_count[char] += 1
    end
    three_count += 1 if letter_count.values.any?{|val| val == 3 }
    two_count += 1 if letter_count.values.any?{|val| val == 2 }
  end

  three_count * two_count
end

def diffs(str1, str2)
  count = 0
  index = nil
  for i in (0...str1.length)
    unless str1[i] == str2[i]
      count += 1 
      index = i  
    end
  end  
  count == 1 ? index : nil
end

def common_letters 
  box_ids = File.readlines('./input.txt').map(&:chomp)

  for i in (0...box_ids.length)
    for j in (i...box_ids.length)
      str1, str2 = box_ids[i], box_ids[j]
      delete_index = diffs(str1, str2)
      if delete_index 
        result = box_ids[i].chars
        result.delete_at(delete_index)
        return result.join
      end  
    end   
  end    
end

