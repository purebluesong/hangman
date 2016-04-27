require 'restclient'
require 'json'
@url = 'https://strikingly-hangman.herokuapp.com/game/on'
@playerID = 'purebluesong@gmail.com'
@sessionID = nil

@startAction = 'startGame'
@nextWordAction = 'nextWord'
@guessWordAction = 'guessWord'
@getResultAction = 'getResult'
@submitAction = 'submitResult'

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
