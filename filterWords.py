import heapq
f = open('words.txt','r+')
wordlist = f.read().split('\n')
f.close()
alphabet = list('abcdefghijklmnopqrstuvwxyz')
wordsDict = dict().fromkeys(alphabet,0)
anotherDict = dict().fromkeys(alphabet,0)
i=1
lines = []
for word in wordlist:
    if i != len(word):
        # print i-1
        l = heapq.nlargest(10,zip(wordsDict.values(),wordsDict.keys()))
        line = ''
        for item in l:
            line += str(item[1])
        lines += [line]
        for item in wordsDict:
            wordsDict[item] = 0
            i = len(word)
            zip(wordsDict.values(),wordsDict.keys())
    for letter in word:
        # print letter,wordsDict.get(letter)
        if wordsDict.get(letter)!=None:
            anotherDict[letter] += 1
            wordsDict[letter] += 1
newlines = ['']*10
for i in range(10):
    for line in lines:
        newlines[i] +=line[i]
for line in newlines:
    print line[2:]
allletters = sorted(anotherDict,key=lambda x:anotherDict[x])
line = ''
allletters.reverse()
for d in allletters:
    line  += d
print line
    # print wordsDict,word
    # raw_input()
# s = "\n".join(wordlist)
# print s
# f = open('newwords.txt','w+')
# f.write(s)
# f.close()
# sorted(wordlist, key=lambda x:len(x))
# for x in wordlist :
    # print x


# print f.read()
