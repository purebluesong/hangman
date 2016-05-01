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
  'aaaseeeeeeeiiiiiiiiiteeeeeee',
  'oeeeaiiiiiieeeeeeeeeesssssss',
  'eooaiaaaoooooarrassssiiiiiii',
  'iiioooooaaaasssssaaaiaaaaaaa',
  'uuuiuuuuusrsaraarrrrarrrrrrr',
  'myyusssssrsrrnnnnnnnrnnnnnnn',
  'shsyyrrrrnnnntttttttnttttttt',
  'bsrtrnnnnttttooooooooooooooo',
  'rrtrnttttlllllllllllllllllll',
  'ncnntllllccccccccccccccccccc',
]
@wordBucket = []
@newwords = []
@newwordsBucket = []
@missingWord = []
# -----------------------------------the core algo--------------------------------------
def guessWord
  res = progNextWord
  res[@word].chomp!
  @currentBucket = @wordBucket[res[@word].length]
  @missingWord.clear
  wrongGuessNum = 0
  word = ''
  begin
    wrongGuessNum,word = guessLetter @firstGuessLetterTable[wrongGuessNum][res[@word].length-1]
  end while (word.delete '*') == '' and wrongGuessNum< @GuessNum
  puts '-'*50
  while wrongGuessNum<@GuessNum and word.include? '*'
    wrongGuessNum,word = guessLetter highestRemainLetterOf word
  end

  @newwords += [word] if @currentBucket == [] and word.length>0 and !word.include? '*'
end

def guessLetter letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  print 'guess ',res[@wrongGuessNumberStr],' wrong times ',res[@word],' letter:',letter,"\n"
  # print @missingWord.join(''),' ',@currentBucket.length,' ',letter,"\n"
  # print @currentLetterOrder.join(''),"\n" if !@currentLetterOrder.nil?
  [res[@wrongGuessNumberStr],res[@word]]
end

@lastWord = nil
def highestRemainLetterOf word
  if word!=@lastWord
    @lastWord = word = word.gsub('*','.').downcase
    @incorrectWord = @missingWord-word.chars
    @currentLetterOrder = getHighestAbilityLetterFrom Regexp.compile('^'+word+'$')
  end
  @currentLetterOrder.pop[0]
end

def getHighestAbilityLetterFrom pattern
  remainWords = []
  @currentBucket.each {|bucketWord| remainWords += [bucketWord] if pattern.match(bucketWord)}
  remainWords.each{|word| remainWords.delete word if (word.chars-@incorrectWord)!=word.chars}
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
  @alphabet.chars.shuffle.each { |chr| dict[chr] = 0 }
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
    print "="*25,"the ",i+1,"th guess","="*25,"\n"
    guessWord()
  }
  appendNewWords @newwords.join "\n"
  clearNewWords
  appendRecords res = progGetResult()
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
