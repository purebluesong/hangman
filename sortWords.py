filename = 'words.txt'
f = open(filename)
wordlist = f.read().split('\n')
# print len(wordlist)
f.close()
wordlist = sorted(wordlist, key=lambda x:len(x))
# print wordlist
s = "\n".join(wordlist)
print s
f = open(filename,'w')
f.write(s)
f.close()
