require 'restclient'
require 'json'

@url = 'https://strikingly-hangman.herokuapp.com/game/on'
@playerID = 'purebluesong@gmail.com'
@wordFileName = 'words.txt'

@alphabet = 'abcdefghihjklmnopqrstuvwxyz'
@startAction = 'startGame'
@nextWordAction = 'nextWord'
@guessWordAction = 'guessWord'
@getResultAction = 'getResult'
@submitAction = 'submitResult'
@data = :data
@message = :message
@word = "word"
@firstGuessLetterTable = [
  'aaaeeeeeeeeeiiiiiiiiieei',
  'zseasssssiiieeeenetaaoia',
  'yoosaariissnnnntsnattrat',
  'xmiorrirrnnssssnetnnocss',
  'wntloiaaaaattttotseenatn',
  'vepiionnnrtaaaosoooletre',
  'ucstllttttrrooaaaarolnnr',
  'tiurtnlooooorrrrrlssrllm',
  'shnnntolllllllllcrlrcscl',
  'rtrdddddcccccccclcccsiph',
]
@sessionID = nil
@WordsNum = nil
@GuessNum = nil
@wordBucket = []
@currentBucket = nil


# ---------------------------------------------------------------
def postData data
  begin
    res = JSON.parse RestClient.post(@url,data.to_json,:content_type => :json,:accept => :json)
  rescue
    res = JSON.parse RestClient.post(@url,data.to_json,:content_type => :json,:accept => :json)
  end
  res.keys.each {|key| res[(key.to_sym rescue key) || key] = res.delete key}
  p res[@data]["totalWordCount"]
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
# -------------------------------------------------------------------------
@missingWord = []
@wrongGuessNumberStr = "wrongGuessCountOfCurrentWord"
def guessWord
  res = progNextWord
  @currentBucket = @wordBucket[res[@word].length+2]
  i = 0
  word = nil
  @missingWord.clear
  @missingWord += ["\r","\n"]
  while i< @GuessNum
    letter = @firstGuessLetterTable[i][res[@word].length-1]
    i,word = guessOnce letter
    break if (word.delete '*') != ''
    print 'guess',i,'times wrong first letter ',word,"\n"
  end

  while i<@GuessNum
    i,word = guessOnce highestRemainLetterOf word
    break if !word.include? '*'
    print 'guess',i,'wrong times ',word,"\n"
  end
end

def guessOnce letter
  p 'guess '+letter
  @missingWord += [letter]
  res = progGuessWord letter.upcase
  [res[@wrongGuessNumberStr],res[@word]]
end

@lastWord = nil
def highestRemainLetterOf word
  if word==@lastWord
    getALetterFromHighestList
  else
    getHighestAbilityLetterFrom @lastWord = word
  end
end

def getALetterFromHighestList
  letter = @currentLetterOrder[0][0]
  @currentLetterOrder.delete_at 0
  letter
end

def getHighestAbilityLetterFrom word
  remainWords = []
  pattern = Regexp.compile(word.gsub('*','.').downcase)
  @currentBucket.each {|bucketWord| remainWords += [bucketWord] if pattern.match(bucketWord)}
  dict = statisticLetter remainWords
  @missingWord.each {|letter| dict.delete letter}
  if !dict.nil?
    getHighestLetterFrom dict
  else
    print @missingWord
  end
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
  if !@currentLetterOrder.nil?
    @currentLetterOrder
  else
    print dict
  end
end

def wordsBucketCreate
  @wordBucket = Array.new(30,[])
  file  = File.open(@wordFileName)
  file.each {|line|
    @wordBucket[line.length] += [line]
  }
  puts 'words bucket init over'
end

def main()
  wordsBucketCreate
  res = progStartGame()
  @WordsNum = res["numberOfWordsToGuess"]
  @GuessNum = res["numberOfGuessAllowedForEachWord"]
  @WordsNum.times {|i|
    print "the ",i,"th guess\n"
    guessWord()
  }
  puts progGetResult()
  p 'submit?(Y/n)'
  puts progSubmit() if ['y','Y',"Y","y"].include? a=gets else a
end

main
