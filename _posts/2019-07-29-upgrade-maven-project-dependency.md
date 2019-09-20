---
layout: post
title: Upgrade Maven Project Dependency
disqus: y
share: y
categories: [Database]
tags: [Postgres, Performance]
---

这个系统已经超过10年了，不像新项目直接拿个新框架就上，老系统修修补补，再迁移一下十分费劲。如果升级像是Java版本还好，只要不是用什么特殊技术，或者使用非openJDK的版本，通常向下兼容。但是大项目Maven project庞大的Jars就没这么方便了，儅更新了一个jar A，那么就得改Jar B，改了Jar B发现Jar C也不行了，无穷无尽。这里简单阐述下更新的方法。

假设我们要从springBoot 1.1.12.RELEASE升级到springBoot 2.0.9.RELEASE，全部过程靠两个工具，1是maven dependency tree（我用的intellij自带插件），还有[mvnrepository](https://mvnrepository.com)网站。  

1. 确定最低依赖要求  
在mvnrepository找到要升级的2.0.9.RELEASE的依赖，该网站提供了详细了Compile Dependencies列表，可以知道这个Jar的以来，比如2.0.9.RELEASE，就依赖了一堆其他Jar。比如要求spring-core 5.0.13.RELEASE啦，slf4j-api 1.7.26啦，这些都是最低要求，也就说必须满足这些依赖springBoot 2.0.9.RELEASE才能运行。通常的话都打包了，也有可能有些依赖没有打包的，就得自己添加了。

2. 统一全局依赖版本   
我们知道只要满足1，那么就可以升级了，但问题是如果是一个庞大的project，上下级之间有错综複杂的依赖关係，如果统一依赖是个大难题。通常上有父repo A，还有子repo B和C，如果他们都使用了Gson，这种情况我们要尽量使用统一的依赖，比如都使用2.8.5或者都使用2.8.4，如果选择版本号就可以看各自的dependency来定。如果实在不行，至少也得保证父子使用同样的版本号，因爲默认父jar版本号会传递给子Jar。可以单独为子配置版本，但是实在是一种灾难。

3. 解决Dependency冲突  
这一步是最难的，很多版本的冲突是隐形的，因爲他们存在于各个Jar包之内，也不能改Jar包里头的代码对吧。如果已经统一了全局依赖版本会好一些，不容易出错，否则只能一个个版本去试，简直要了亲命，因爲完全不在你的控制中，存粹是和找抗体一样的穷举试验。实在拼凑不出的话只能捨去一些Dependency了。 

4. 修復Code编译问题    
这一步很直观，就是因爲Jar包的变换，很多Function可能已经Deprecated了，需要修改为可用的方法。这里只能希望这个Jar包设计比较合理，最好有提供承上啓下的方法了。

5. 祈祷  
祈祷升级后好用吧，因爲即使前面都没问题，集成以后还是可能有问题。所以勤更新Dependency才能避免某一天不得不更新的冏境。

English Version
---------------
//TODO probably never do

Reference
----------
[Circular Dependencies in Spring](https://www.baeldung.com/circular-dependencies-in-spring)  
[Spring 5 MVC + Hibernate 5 Example](https://howtodoinjava.com/spring5/webmvc/spring5-mvc-hibernate5-example/)  
