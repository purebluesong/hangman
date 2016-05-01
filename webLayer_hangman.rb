require 'restclient'
require 'json'
Url_req = 'https://strikingly-hangman.herokuapp.com/game/on'
PlayerID = 'purebluesong@gmail.com'
Message = :message
Data = :data
StartAction = 'startGame'
NextWordAction = 'nextWord'
GuessWordAction = 'guessWord'
GetResultAction = 'getResult'
SubmitAction = 'submitResult'

# ----------------------------the web process layer-----------------------------------
def postData data
  begin
    res = JSON.parse RestClient.post(Url_req,data.to_json,:content_type => :json,:accept => :json)
  rescue
    res = JSON.parse RestClient.post(Url_req,data.to_json,:content_type => :json,:accept => :json)
  end
  res.keys.each {|key| res[(key.to_sym rescue key) || key] = res.delete key}
  res[Data]#  "#wired things, if delete it I will couldn't get the correct res
  res
end

def progStartGame
  res = postData({:playerID=>PlayerID, :action=>StartAction})
  puts res[Message] if res.key? Message
  @sessionID = res[:sessionId]
  res[Data]
end

def progNextWord
  postData({:sessionID=>@sessionID, :action=>NextWordAction})[Data]
end

def progGuessWord word
  postData({:sessionID=>@sessionID, :action=>GuessWordAction, :guess=>word})[Data]
end

def progGetResult
  postData({:sessionID=>@sessionID, :action=>GetResultAction})[Data]
end

def progSubmit
  postData({:sessionID=>@sessionID, :action=>SubmitAction})[Data]
end
