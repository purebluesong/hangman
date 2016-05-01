sum,i,max,min = 0,0,0,1600
open("records.txt","rt").readlines.each {|line|
  score = line.scan(/\d\d\d\d/)[0].to_i
  score = line.scan(/\d\d\d/)[1].to_i if score == 0
  sum += score
  max = score if score > max
  min = score if score < min
  i+=1
}
print 'there are ',i,' records.',"\n"
print 'average:',sum/i,"\n"
print 'highest:',max,"\n"
print 'lowest:',min,"\n"
