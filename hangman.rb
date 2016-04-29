load 'mytool.rb'
load 'webLayer_hangman.rb'

#---------------------------config variable------------------------
@wordFileName = 'words.txt'
@data = :data
@message = :message
@word = "word"
@numberOfWordsToGuess = "numberOfWordsToGuess"
@numberOfGuessAllowedForEachWord = "numberOfGuessAllowedForEachWord"
@wrongGuessNumberStr = "wrongGuessCountOfCurrentWord"

@firstGuessLetterTable = [
  'aaeseeeeeeeeeiiiieiieeeoe',
  'oeaesssssiiiieeeeieoitola',
  'eosaaaiiisssssssssoeoiret',
  'iiooriaaannnnnnnoosttoitl',
  'mtirirrrratttttttttssslic',
  'hslionnnntaaoooonnnnnnthr',
  'uurlloottrroaaaaarrarrcan',
  'npttnttoooorrrrrraaralapi',
  'srnntllllllllllllllllahnh',
  'ynuddddcccccccccccccccpmy',
]
@WordsNum = nil
@GuessNum = nil
@wordBucket = []
@currentBucket = nil
@newwords = []
@newwordsBucket = []
@missingWord = []
# -----------------------------------the core algo--------------------------------------
def guessWord
  res = progNextWord
  res[@word].delete! "\n"
  res[@word].delete! "\r"
  @currentBucket = @wordBucket[res[@word].length]
  @missingWord.clear
  i = 0
  begin
    i,word = guessLetter @firstGuessLetterTable[i][res[@word].length-1]
  end while (word.delete '*') == '' and i< @GuessNum

  while i<@GuessNum and word.include? '*'
    i,word = guessLetter highestRemainLetterOf word
  end
  missing = ""
  @missingWord.each {|letter| missing += letter}
  @newwords += [word + ' ' + missing] if @currentBucket == []
end

def guessLetter letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  print 'guess ',res[@wrongGuessNumberStr],' wrong times ',res[@word],' letter:',letter,"\n"
  [res[@wrongGuessNumberStr],res[@word]]
end

@lastWord = nil
def highestRemainLetterOf word
  if word!=@lastWord
    @lastWord = word = word.gsub('*','.').downcase
    @currentLetterOrder = getHighestAbilityLetterFrom Regexp.compile('^'+word+'$')
    @currentLetterOrder.each {|word| print word[0],word[1],' ' if word[1]>0}
  end
  @currentLetterOrder.pop[0]
end

def getHighestAbilityLetterFrom pattern
  remainWords = []
  @currentBucket.each {|bucketWord| remainWords += [bucketWord] if pattern.match(bucketWord)}
  @currentBucket = remainWords
  if remainWords == []
    @newwordsBucket.each {|bucketWord|
      word,missingWord = bucketWord.split(' ')
      if pattern.match(word)
        remainWords += [word]
        break if !word.include? '*'
        @missingWord = missingWord.split '' if !missingWord.nil?
      end
    }
  end
  dict = statisticLetter remainWords
  @missingWord.each {|letter| dict.delete letter}
  getSortListFrom dict
end

@alphabet = 'esiarntolcdupmghbyfvkwzxqj'
def statisticLetter wordsList
  dict = {}
  @alphabet.each_char { |chr| dict[chr] = 0 }
  wordsList.each {|word| word.delete('*').chars.uniq.each { |chr| dict[chr] += 1}}
  dict
end

def getSortListFrom dict
  dict.to_a.sort {|x,y| x[1]<=>y[1]}
end
#----------------------------------------------------

def createWordsBucket
  @wordBucket = Array.new(30,[])
  open(@wordFileName,"rt").readlines.each {|line|
    line.chomp!
    @wordBucket[line.length] += [line]
  }
  puts 'words bucket init over'
end

@score = 1360
def play()
  @newwordsBucket = readNewWords
  res = progStartGame()
  @WordsNum = res[@numberOfWordsToGuess]
  @GuessNum = res[@numberOfGuessAllowedForEachWord]
  @WordsNum.times {|i|
    print "======================the ",i+1,"th guess=================\n"
    guessWord()
  }
  appendNewWords @newwords.join "\n"
  clearNewWords
  puts res = progGetResult()
  if !res[@data].nil? and res[@data]["score"] > @score
    @score = res[@data]["score"]
    puts progSubmit()
  else
    puts "a low score--"
  end
end

if __FILE__ == $0
  createWordsBucket
  loop{play}
end
