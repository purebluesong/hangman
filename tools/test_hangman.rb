load 'hangman.rb'

def statisticLetter_test
  statisticLetter []
  dict = statisticLetter_test
  "asdfoiuy".split("").each {|letter| dict.delete letter}
  print getSortListFrom dict
end

def getSortListFrom_test
  print getSortListFrom statisticLetter []
  puts ''
  print getSortListFrom statisticLetter []
end
puts '-----------------------------------------'
# getSortListFrom_test
