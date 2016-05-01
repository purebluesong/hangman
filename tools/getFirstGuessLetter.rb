@wordBucket = Array.new(30,[])
open("../dict/words.txt","rt").readlines.each {|line|
  line.chomp!
  @wordBucket[line.length] += [line]
}
@dict = {}
@alphabet = 'esiarntolcdupmghbyfvkwzxqj'
@lines = []

@wordBucket.each {|bucket|
  @currentBucket = bucket
  line = ""
  10.times {
    if @currentBucket!=[]
      @alphabet.each_char{|chr| @dict[chr] = 0}
      @currentBucket.each {|word| word.chars.uniq.each {|chr| @dict[chr]+=1}}
      s = @dict.to_a.max {|x,y| x[1]<=>y[1]}[0]
      remainWords = []
      @currentBucket.each{|word| remainWords+= [word] if !word.include? s}
      @currentBucket = remainWords
    else
      s=''
      @alphabet.each_char{|letter| (s=letter;break) if !line.include? letter}
    end
    line += s
  }
  puts line
  @lines += [line]
}
@lines.delete_at 0
@lines.delete_at 0
10.times{|i|
  print "\'"
  @lines.each{|line| print line[i]}
  print "\',\n"
}

# @lines.each {|line| puts line}
