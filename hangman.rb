require 'restclient'
require 'json'

@url = 'https://strikingly-hangman.herokuapp.com/game/on'
@playerID = 'purebluesong@gmail.com'
@wordFileName = 'wordsEn.txt'

@startAction = 'startGame'
@nextWordAction = 'nextWord'
@guessWordAction = 'guessWord'
@getResultAction = 'getResult'
@submitAction = 'submitResult'
@data = :data
@message = :message
@word = :word
@firstGuessLetter = [
  'aaaeeeeeeeeeiiiiiiiiieei',
  'zseasssssiiieeeenetaaoia',
  'yoosaariissnnnntsnattrat',
  'xmiorrirrnnssssnetnnocss',
  'wntloiaaaaattttotseenatn',
]
@guessFollowSet = 'etaoinshrdlcumwfgypbvkjxqz'
@sessionID = nil
@WordsNum = nil
@GuessNum = nil
@wordBucket = []
@currentBucket = nil


# ---------------------------------------------------------------
def postData data
  puts data
  res = RestClient.post(url,data.to_json,:content_type => :json,:accept => :json)
end

def progStartGame
  res = postData({:playerID=>@playerID, :action=>@startAction}))
  puts res[@message] if res.has_key?(@message)
  @sessionID = res['sessionID']
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
def guessWord
  res = progNextWord
  @currentBucket = @wordBucket[res[@word].length]
  i = 0
  lastWord = nil
  @missingWord.clear
  while i< @GuessNum
    lastWord = guessOnce @firstGuessLetter[i][res[@word].length-1]
    break if (lastword.delete '*').length > 0
    print 'guess',i+=1,'times first letter'
  end

  while i<@GuessNum
    nowWord = guessOnce highestRemainLetterOf lastword
    break if !nowWord.include? '*'
    i+=1 if nowWord == lastword
  end
end

def highestRemainLetterOf word
  remainWords = []
  pattern = Regexp.compile(word.gsub('*','.'))
  for bucketWord in @currentBucket
    remainWords << bucketWord if pattern.match(word)
  end
  dict = statisticLetter remainWords
  getHighestLetterFrom dict
end

def statisticLetter wordsList
  dict = Hash.new { |hash, key| hash[key] = 0 }
  for word in wordsList
    word.each_char { |chr| statisticLetter[chr] += 1 if !@missingWord.include? chr }
  end
  dict
end

def getHighestLetterFrom dict
  
end

def guessOnce letter
  @missingWord << letter
  res = progGuessWord letter
  res[@word]
end

def wordsBucketCreate
  @wordBucket = Array.new(30,[])
  file  = File.open(@wordFileName)
  file.each {|line|
    @wordBucket[line.size] << line
  }
  puts 'words bucket init over'
end

def main()
  wordsBucketCreate
  res = progStartGame()
  @WordsNum = res[:numberOfWordsToGuess]
  @GuessNum = res[:numberOfGuessAllowedForEachWord]
  @WordsNum.times {|i|
    print "the ",i,"th guess\n"
    guessWord()
  }
  progGetResult()
  progSubmit()
end

main
