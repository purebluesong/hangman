#!/usr/bin/env ruby
@newwordsFileName = "newwords.txt"
def clearNewWords
  somethingfuck =[]
  somethingfun = []
  open(@newwordsFileName,"rt") {|f|
    f.readlines.each {|line|
      if line.include? '*'
        somethingfun += [line.split(' ')[0]+" "+(line.split(' ')[1].delete '*')]
      else
        somethingfuck += [line.split(" ")[0]]
      end
    }
  }
  somethingfuck.uniq!
  somethingfuck.sort_by! {|x| x.size}

  somethingfun.uniq!
  somethingfun.sort_by! {|x| x.split(' ')[0].size}

  open(@newwordsFileName,"wt") {|f|
    somethingfuck.each {|word| f.write word+"\n"}
    somethingfun.each {|word| f.write word+"\n"}
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
