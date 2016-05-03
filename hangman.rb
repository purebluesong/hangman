load 'mytool.rb'
load 'webLayer_hangman.rb'

#---------------------------config variable------------------------
WORD_FILE_NAME = 'dict/words.txt'
WORD_STR = "word"
SCORE_STR = "score"
NUMBER_OF_WORDS_TO_GUESS = "numberOfWordsToGuess"
NUMBER_OF_GUESS_ALLOWED_FOR_EACH_WORD = "numberOfGuessAllowedForEachWord"
WRONG_GUESS_NUMBER = "wrongGuessCountOfCurrentWord"
TOTAL_WORD_COUNT = "totalWordCount"

FIRST_LETTER_TABLE = [
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
  open(WORD_FILE_NAME,"rt").readlines.each {|line|
    line.chomp!
    @wordBucket[line.length] += [line]
  }
  puts 'words bucket init over'
end

#play the game once
@score = 1363
def play
  @newwordsBucket = readNewWords
  res = progStartGame
  wordsNum = res[NUMBER_OF_WORDS_TO_GUESS]
  @GuessNum = res[NUMBER_OF_GUESS_ALLOWED_FOR_EACH_WORD]

  wordCount = 0
  while wordCount < wordsNum
    print "="*25, "the ", wordCount+1, "th guess", "="*25, "\n"
    wordCount = guessWord
  end

  appendNewWords(@newwords.join "\n")
  clearNewWords
  appendRecords(res = progGetResult)

  if !res.nil? and res[SCORE_STR] > @score
    @score = res[SCORE_STR]
    puts progSubmit
  else
    puts res[SCORE_STR]
  end
end

#guess a word
def guessWord
  res = progNextWord
  res[WORD_STR].chomp!
  @currentBucket = @wordBucket[res[WORD_STR].length]
  @missingWord.clear
  wrongGuessNum = 0

  word = ''
  begin
    wrongGuessNum,word = guessLetter FIRST_LETTER_TABLE[wrongGuessNum][res[WORD_STR].length-1]
  end while '' == word.delete('*') and wrongGuessNum < @GuessNum
  puts '-'*50
  while wrongGuessNum < @GuessNum and word.include? '*'
    wrongGuessNum,word = guessLetter highestRemainLetterOf word
  end

  @newwords += [word] if @currentBucket == [] and word.length > 0 and !word.include? '*'
  res[TOTAL_WORD_COUNT]
end

#guess a letter
def guessLetter letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  print 'guess ',res[WRONG_GUESS_NUMBER],' wrong times ',res[WORD_STR],' letter:',letter,"\n"
  [res[WRONG_GUESS_NUMBER],res[WORD_STR]]
end

#find the highest ability remain letter of the word
def highestRemainLetterOf word
  word.gsub!('*','.').downcase!
  @incorrectWord = @missingWord - word.chars
  getHighestAbilityLetterFrom(Regexp.compile('^'+word+'$')).pop[0]
end

#match the pattern and reduce the remainWords,return a list
def getHighestAbilityLetterFrom pattern
  remainWords = []
  @currentBucket.each {|bucketWord|
    remainWords += [bucketWord] if pattern.match(bucketWord)
  }
  remainWords.each{|word|
    remainWords.delete word if (word.chars - @incorrectWord) != word.chars
  }
  remainWords = checkNewWords {|word| pattern.match(word)} if remainWords == []
  @currentBucket = remainWords

  dict = statisticLetter remainWords
  @missingWord.each {|letter| dict.delete letter}
  getSortListFrom dict
end

#search the word in newwords table if i cant find it in main wordsList
def checkNewWords
  @newwordsBucket.each {|bucketWord|
    bucketWord.chomp!
    if yield(bucketWord)
      print bucketWord, "---remainWords\n"
      return [bucketWord]
    end
    puts 'findnone'
  }
  []
end

#statistic Letters frequet and return the frequent dict
@alphabet = 'esiarntolcdupmghbyfvkwzxqj'
def statisticLetter wordsList
  dict = {}
  @alphabet.chars.shuffle.each { |chr| dict[chr] = 0 }
  wordsList.each {|word|
    word.delete('*').chars.uniq.each { |chr| dict[chr] += 1}
  }
  dict
end

#sort the dict list by asend
def getSortListFrom dict
  dict.to_a.sort {|x, y| x[1]<=>y[1]}
end
#----------------------------------------------------

if __FILE__ == $0
  createWordsBucket
  loop{play}
end
