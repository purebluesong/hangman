require 'restclient'
require 'json'


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


# ----------------------------the web process layer-----------------------------------
def postData data
  begin
    res = JSON.parse RestClient.post(@url,data.to_json,:content_type => :json,:accept => :json)
  rescue
    res = JSON.parse RestClient.post(@url,data.to_json,:content_type => :json,:accept => :json)
  end
  res.keys.each {|key| res[(key.to_sym rescue key) || key] = res.delete key}
  print res[@data]["totalWordCount"]," "#wired things, if delete it I will couldn't get the correct res
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

  @newwords += [word+'    '+@missingWord.to_s] if @currentBucket == []
end

def guessOnce letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  print 'guess',res[@wrongGuessNumberStr],'wrong times ',res[@word],' letter:',letter,"\n"
  [res[@wrongGuessNumberStr],res[@word]]
end

@lastWord = nil
def highestRemainLetterOf word
  if word==@lastWord
    getALetterFromHighestList
  else
    @lastWord = word = word.gsub('*','.').downcase
    getHighestAbilityLetterFrom Regexp.compile(word)
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
  puts 'words bucket init over'
end

def main()
  wordsBucketCreate
  res = progStartGame()
  @WordsNum = res[@numberOfWordsToGuess]
  @GuessNum = res[@numberOfGuessAllowedForEachWord]
  @WordsNum.times {|i|
    print "======================the ",i+1,"th guess=================\n"
    guessWord()
  }
  open("newwords.txt","at") {|f| @newwords.each {|word| f.puts word+"\n"}}
  puts progGetResult()
  p 'submit?(Y/n)'
  puts progSubmit(),'----' if ['y','Y'].include? gets.chomp
end

main
