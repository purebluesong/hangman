# hangman

算是strinkly后端开发岗的笔试题？


具体的实现思路和[这里](https://ruby-china.org/topics/16256)的类似，也是动态词频统计，选择最有可能的字母去猜


第一个字母根据单词长度推断，这里我用sortWords.py处理字典文件之后用filterWords.py直接打出了同长度下最高频的10个字母，然后硬编码在代码里了……，时间短也没工夫去优化,这里其实是可以做到自动化处理字典文件的。

因为已经有已知的字母位置了，所以可以不断的用用正则去压缩备选单词列表，然后统计备选单词列表中最可能出现的字母，这里可以判断单词是否在字典之中，下一步优化工作是如果运气爆表猜出来了把该单词加入字典文件

中间做了一点小小的优化，就是同一个单词内每个字母只能被统计一次，因为一个字母也只能筛选出一个单词

以上内容可以直接在代码的命名中找到对应内容，虽然自我感觉代码可读性其实不太好，但是成块的理解起来还是蛮快的

-----------------
下面是一些坑：

感觉strinkly限制了访问频率，跑一次算上自己的时间稳稳的要10+分钟
一开始找了个100k的单词表，我勒个擦简直坑爹啊，各种单词找不到，不过就是后来换成170k单词的单词表以后还是有些词这个单词表里面没有，全靠蒙……

还好我的程序按照统一单词频率来蒙，还真蒙对几个，不过如果strinkly把字典文件开放出来我觉得效果会更好一些，或者按照上面的思路跑个十天八天的分数也能搞起去

--------------------
下面是一些吐槽:

周一收到邮件让玩这个，当时也没注意要周五收，正值手头实验室项目社团活动几个笔试忙的不可开交，直接推迟了两天

然后周三晚上检查邮件的时候才注意到周五收……尼玛……周五还有UID的考试，慌的很，急忙去图书馆抱了三本ruby捡起已经手生的很的ruby

就这样边准备预习考试变急忙的写这个游戏，还好大体思路是对的
中间查些ruby东西的时候查到了[@mvj3](https://github.com/mvj3/) 写的一篇[博文](https://ruby-china.org/topics/16256)，更加觉得自己思路没什么问题

然后周四晚上写完初稿以后就开始坑了，周五各种语法上和逻辑上的调节与被坑，
第一次成功测试发现自己正确率低的吓人只有不到一半的词猜出来了……

下午考完试连实验都不做了急忙回实验室赶工，把字典从100k的换成170k的比较全的那个，各种修改，然而终于还是没能在周五结束之前完成代码

要跪……

权当一次练习

算法上没什么难度，就是统计，代码里面各种one-line，大神们轻喷，毕竟两天的成果，还不太熟ruby的代码规范
