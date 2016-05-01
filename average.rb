sum,i = 0,0
open("records.txt","rt").readlines.each {|line|
  sum += line.scan(/\d\d\d\d/)[0].to_i
  i+=1
}
puts sum/i
