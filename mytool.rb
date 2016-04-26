#!/usr/bin/env ruby
def clearNewWords
  @alphabet = "abcdefghijklmnopqrstuvwxyz"
  @somethingfuck =[]
  @somethingfun = []
  open("newwords.txt","rt") {|f|
    f.read.split("\n").each {|line|
      if line.include? '*'
        @somethingfun += [line]
      else
        @somethingfuck += [line.split(" ")[0]]
      end
    }
  }
  @somethingfuck.uniq!
  @somethingfuck.sort!
  @somethingfuck.sort_by! {|x| x.size}
  @somethingfuck.each {|word| puts word.downcase}

  @somethingfun.uniq!
  @somethingfun.sort!
  @somethingfun.sort_by! {|x| x.size}
  @somethingfun.each {|word| puts word.downcase,word.split(" ")[1].length}

  open("newwords.txt","wt") {|f|
    @somethingfuck.each {|word| f.write word+"\n"}
    @somethingfun.each {|word| f.write word+"\n"}
  }
end
