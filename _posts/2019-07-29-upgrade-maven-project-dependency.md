---
layout: post
title: Upgrade Maven Project Dependency
disqus: y
share: y
categories: [Database]
tags: [Postgres, Performance]
---

這個系統已經超過10年了，不像新項目直接拿個新框架就上，老系統修修補補，再遷移一下十分費勁。如果升級像是Java版本還好，只要不是用什麽特殊技術，或者使用非openJDK的版本，通常向下兼容。但是大項目Maven project龐大的Jars就沒這麽方便了，儅更新了一個jar A，那麽就得改Jar B，改了Jar B發現Jar C也不行了，無窮無盡。這裏簡單闡述下更新的方法。

假設我們要從springBoot 1.1.12.RELEASE升級到springBoot 2.0.9.RELEASE，全部過程靠兩個工具，1是maven dependency tree（我用的intellij自帶插件），還有[mvnrepository](https://mvnrepository.com)網站。  

1. 確定最低依賴要求  
在mvnrepository找到要升級的2.0.9.RELEASE的依賴，該網站提供了詳細了Compile Dependencies列表，可以知道這個Jar的以來，比如2.0.9.RELEASE，就依賴了一堆其他Jar。比如要求spring-core 5.0.13.RELEASE啦，slf4j-api 1.7.26啦，這些都是最低要求，也就說必須滿足這些依賴springBoot 2.0.9.RELEASE才能運行。通常的話都打包了，也有可能有些依賴沒有打包的，就得自己添加了。

2. 統一全局依賴版本   我們知道只要滿足1，那麽就可以升級了，但問題是如果是一個龐大的project，上下級之間有錯綜複雜的依賴關係，如果統一依賴是個大難題。通常上有父repo A，還有子repo B和C，如果他們都使用了Gson，這種情況我們要盡量使用統一的依賴，比如都使用2.8.5或者都使用2.8.4，如果選擇版本號就可以看各自的dependency來定。如果實在不行，至少也得保證父子使用同樣的版本號，因爲默認父jar版本號會傳遞給子Jar。可以單獨為子配置版本，但是實在是一種災難。

3. 解決Dependency衝突  
這一步是最難的，很多版本的衝突是隱形的，因爲他們存在於各個Jar包之内，也不能改Jar包裏頭的代碼對吧。如果已經統一了全局依賴版本會好一些，不容易出錯，否則只能一個個版本去試，簡直要了親命，因爲完全不在你的控制中，存粹是和找抗體一樣的窮舉試驗。實在拼凑不出的話只能捨去一些Dependency了。 

4. 修復Code編譯問題    
這一步很直觀，就是因爲Jar包的變換，很多Function可能已經Deprecated了，需要修改為可用的方法。這裏只能希望這個Jar包設計比較合理，最好有提供承上啓下的方法了。

5. 祈禱  
祈禱升級後好用吧，因爲即使前面都沒問題，集成以後還是可能有問題。所以勤更新Dependency才能避免某一天不得不更新的冏境。

English Version
---------------
//TODO probably never do

Reference
----------
1. [Circular Dependencies in Spring](https://www.baeldung.com/circular-dependencies-in-spring)  
2. [Spring 5 MVC + Hibernate 5 Example](https://howtodoinjava.com/spring5/webmvc/spring5-mvc-hibernate5-example/)  
