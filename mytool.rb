#!/usr/bin/env ruby
@newwordsFileName = "dict/newwords.txt"
def clearNewWords
  somethingfuck =[]
  open(@newwordsFileName,"rt").readlines.each {|line|
    somethingfuck += [line.chomp]
  }
  somethingfuck.uniq!
  somethingfuck.sort_by! {|x| x.size}

  open(@newwordsFileName,"wt") {|f|
    somethingfuck.each {|word| f.write word.downcase+"\n"}
  }
end

def readNewWords
  open(@newwordsFileName,"rt").readlines
end

def appendNewWords words
  open(@newwordsFileName,"at").puts words.downcase
end

def appendRecords record
  open("records.txt","at").puts record.to_s
end

if __FILE__ == $0
  clearNewWords
end
