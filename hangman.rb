load 'mytool.rb'
load 'webLayer_hangman.rb'

#---------------------------config variable------------------------
WordFileName = 'dict/words.txt'
Word = "word"
NumberOfWordsToGuess = "numberOfWordsToGuess"
NumberOfGuessAllowedForEachWord = "numberOfGuessAllowedForEachWord"
WrongGuessNumberStr = "wrongGuessCountOfCurrentWord"
TotalWordCount = "totalWordCount"

FirstGuessLetterTable = [
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
# -----------------------------------the core algo--------------------------------------
@wordBucket = []
@newwords = []
@newwordsBucket = []
@missingWord = []

def createWordsBucket
  @wordBucket = Array.new(30,[])
  open(WordFileName,"rt").readlines.each {|line|
    line.chomp!
    @wordBucket[line.length] += [line]
  }
  puts 'words bucket init over'
end

@score = 1363
def play
  @newwordsBucket = readNewWords
  res = progStartGame()
  wordsNum = res[NumberOfWordsToGuess]
  @GuessNum = res[NumberOfGuessAllowedForEachWord]
  wordCount = 0
  while wordCount < wordsNum
    print "="*25, "the ", wordCount+1, "th guess", "="*25, "\n"
    wordCount = guessWord()
  end

  appendNewWords @newwords.join "\n"
  clearNewWords
  appendRecords res = progGetResult()

  if !res.nil? and res["score"] > @score
    @score = res["score"]
    puts progSubmit()
  else
    puts res["score"]
  end
end

def guessWord
  res = progNextWord
  res[Word].chomp!
  @currentBucket = @wordBucket[res[Word].length]
  @missingWord.clear
  wrongGuessNum = 0

  word = ''
  begin
    wrongGuessNum,word = guessLetter FirstGuessLetterTable[wrongGuessNum][res[Word].length-1]
  end while (word.delete '*') == '' and wrongGuessNum < @GuessNum
  puts '-'*50
  while wrongGuessNum < @GuessNum and word.include? '*'
    wrongGuessNum,word = guessLetter highestRemainLetterOf word
  end

  @newwords += [word] if @currentBucket == [] and word.length > 0 and !word.include? '*'
  res[TotalWordCount]
end

def guessLetter letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  print 'guess ',res[WrongGuessNumberStr],' wrong times ',res[Word],' letter:',letter,"\n"
  [res[WrongGuessNumberStr],res[Word]]
end

def highestRemainLetterOf word
  word.gsub!('*','.').downcase!
  @incorrectWord = @missingWord - word.chars
  getHighestAbilityLetterFrom(Regexp.compile('^'+word+'$')).pop[0]
end

def getHighestAbilityLetterFrom pattern
  remainWords = []
  @currentBucket.each {|bucketWord|
    remainWords += [bucketWord] if pattern.match(bucketWord)
  }
  remainWords.each{|word|
    remainWords.delete word if (word.chars - @incorrectWord) != word.chars
  }
  remainWords = checkNewWords {|word| pattern.match(word.chomp)} if remainWords == []
  @currentBucket = remainWords

  dict = statisticLetter remainWords
  @missingWord.each {|letter|
    dict.delete letter
  }
  getSortListFrom dict
end

def checkNewWords
  @newwordsBucket.each {|bucketWord|
    if yield(bucketWord)
      print bucketWord, "---remainWords\n"
      return [bucketWord.chomp]
    end
  puts 'findnone'
}
  []
end

@alphabet = 'esiarntolcdupmghbyfvkwzxqj'
def statisticLetter wordsList
  dict = {}
  @alphabet.chars.shuffle.each { |chr| dict[chr] = 0 }
  wordsList.each {|word|
    word.delete('*').chars.uniq.each { |chr| dict[chr] += 1}
  }
  dict
end

def getSortListFrom dict
  dict.to_a.sort {|x, y| x[1]<=>y[1]}
end
#----------------------------------------------------

if __FILE__ == $0
  createWordsBucket
  loop{play}
end
