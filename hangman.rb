require 'restclient'
require 'json'
load 'mytool.rb'

#---------------------------config variable------------------------
@url = 'https://strikingly-hangman.herokuapp.com/game/on'
@playerID = 'purebluesong@gmail.com'
@wordFileName = 'words.txt'

@alphabet = 'esiarntolcdupmghbyfvkwzxqj'
@startAction = 'startGame'
@nextWordAction = 'nextWord'
@guessWordAction = 'guessWord'
@getResultAction = 'getResult'
@submitAction = 'submitResult'
@data = :data
@message = :message
@word = "word"
@numberOfWordsToGuess = "numberOfWordsToGuess"
@numberOfGuessAllowedForEachWord = "numberOfGuessAllowedForEachWord"

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
@sessionID = nil
@WordsNum = nil
@GuessNum = nil
@wordBucket = []
@currentBucket = nil
@newwords = []
@newwordsBucket = []


# ----------------------------the web process layer-----------------------------------
def postData data
  begin
    res = JSON.parse RestClient.post(@url,data.to_json,:content_type => :json,:accept => :json)
  rescue
    res = JSON.parse RestClient.post(@url,data.to_json,:content_type => :json,:accept => :json)
  end
  res.keys.each {|key| res[(key.to_sym rescue key) || key] = res.delete key}
  res[@data]#  "#wired things, if delete it I will couldn't get the correct res
  res
end

def progStartGame
  res = postData({:playerID=>@playerID, :action=>@startAction})
  puts res[@message] if res.key? @message
  @sessionID = res[:sessionId]
  res[@data]
end

def progNextWord
  postData({:sessionID=>@sessionID, :action=>@nextWordAction})[@data]
end

def progGuessWord word
  postData({:sessionID=>@sessionID, :action=>@guessWordAction, :guess=>word})[@data]
end

def progGetResult
  postData({:sessionID=>@sessionID, :action=>@getResultAction})[@data]
end

def progSubmit
  postData({:sessionID=>@sessionID, :action=>@submitAction})[@data]
end
# -----------------------------------the core algo--------------------------------------
@missingWord = []
@wrongGuessNumberStr = "wrongGuessCountOfCurrentWord"
def guessWord
  res = progNextWord
  res[@word].delete! "\n"
  res[@word].delete! "\r"
  @currentBucket = @wordBucket[res[@word].length]
  i = 0
  word = nil
  @missingWord.clear
  begin
    letter = @firstGuessLetterTable[i][res[@word].length-1]
    i,word = guessOnce letter
  end while (word.delete '*') == '' and i< @GuessNum

  while i<@GuessNum and word.include? '*'
    i,word = guessOnce highestRemainLetterOf word
  end
  missing = ""
  @missingWord.each {|letter| missing+=letter}
  @newwords += [word + ' ' + missing] if @currentBucket == []
end

def guessOnce letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  print 'guess ',res[@wrongGuessNumberStr],' wrong times ',res[@word],' letter:',letter,"\n"
  [res[@wrongGuessNumberStr],res[@word]]
end

@lastWord = nil
def highestRemainLetterOf word
  if word==@lastWord
    getALetterFromHighestList
  else
    @lastWord = word = word.gsub('*','.').downcase
    getHighestAbilityLetterFrom Regexp.compile('^'+word+'$')
  end
end

def getALetterFromHighestList
  letter = @currentLetterOrder[0][0]
  @currentLetterOrder.delete_at 0
  letter
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
        @missingWord = missingWord.split '' if !missingWord.nil?
        break if !word.include? '*'
      end
    }
  end
  dict = statisticLetter remainWords
  @missingWord.each {|letter| dict.delete letter}
  getHighestLetterFrom dict
end

def statisticLetter wordsList
  dict = Hash.new { |hash, key| hash[key] = 0 }
  @alphabet.each_char { |chr| dict[chr] = 0 }
  wordsList.each {|word| word.chars.uniq.each { |chr| dict[chr] += 1}}
  dict
end

def getHighestLetterFrom dict
  letter = (getSortListFrom dict)[0][0]
  @currentLetterOrder.delete_at 0
  letter
end

@currentLetterOrder = nil
def getSortListFrom dict
  @currentLetterOrder = dict.to_a.sort {|x,y| y[1]<=>x[1]}
end

#----------------------------------------------------

def wordsBucketCreate
  @wordBucket = Array.new(30,[])
  file  = File.open(@wordFileName)
  file.each {|line|
    line.delete! "\n"
    line.delete! "\r"
    @wordBucket[line.length] += [line]
  }
  puts 'words bucket init ove r'
end

@score = 1360
def gameing()
  open("newwords.txt","rt") {|f| @newwordsBucket=f.read.split("\n")}
  res = progStartGame()
  @WordsNum = res[@numberOfWordsToGuess]
  @GuessNum = res[@numberOfGuessAllowedForEachWord]
  @WordsNum.times {|i|
    print "======================the ",i+1,"th guess=================\n"
    guessWord()
  }
  open("newwords.txt","at") {|f| @newwords.each {|word| f.puts word.downcase+"\n"}}
  clearNewWords
  res = progGetResult()
  puts res
  if !res[@data].nil? and res[@data]["score"] > @score
    print 'submit--'
    puts progSubmit()
  else
    puts "a low score--"
  end
end

wordsBucketCreate
loop{gameing}
